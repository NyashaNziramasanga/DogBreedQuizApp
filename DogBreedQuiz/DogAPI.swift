//
//  DogAPI.swift
//  DogBreedQuiz
//
//  Created by Nyasha Nziramasanga on 3/9/2025.
//

import Foundation

struct DogAPI {
    static let randomImageURL = URL(string: "https://dog.ceo/api/breeds/image/random")!
    static let allBreedsURL = URL(string: "https://dog.ceo/api/breeds/list/all")!
    
    struct DogImageResponse: Codable {
        let message: String
        let status: String
    }
    
    struct AllBreedsResponse: Codable {
        let message: [String: [String]]
        let status: String
    }
    
    static func fetchAllBreeds(completion: @escaping (Result<[String], Error>) -> Void) {
        URLSession.shared.dataTask(with: allBreedsURL) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(AllBreedsResponse.self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }
            
            // Get main breeds only (not sub-breeds)
            let breeds = Array(decoded.message.keys).map { $0.capitalized }
            completion(.success(breeds))
        }.resume()
    }
    
    static func fetchRandomDogImage(completion: @escaping (Result<String, Error>) -> Void) {
        URLSession.shared.dataTask(with: randomImageURL) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(DogImageResponse.self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }
            
            completion(.success(decoded.message))
        }.resume()
    }
}
