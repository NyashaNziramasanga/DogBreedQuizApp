//
//  DogAPI.swift
//  DogBreedQuiz
//
//  Created by Nyasha Nziramasanga on 3/9/2025.
//

import Foundation

struct DogAPI {
    static let randomImageURL = URL(string: "https://dog.ceo/api/breeds/image/random")!
    
    struct DogImageResponse: Codable {
        let message: String
        let status: String
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
