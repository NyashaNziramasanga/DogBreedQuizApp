//
//  ContentView.swift
//  DogBreedQuiz
//
//  Created by Nyasha Nziramasanga on 3/9/2025.
//

import SwiftUI

class DogQuizViewModel: ObservableObject {
    @Published var dogImageURL: String = ""
    @Published var options: [String] = []
    @Published var correctAnswer: String = ""
    @Published var feedback: String?
    
    func loadNewQuestion() {
        DogAPI.fetchRandomDogImage { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    self?.dogImageURL = imageURL
                    self?.setupQuestion(from: imageURL)
                case .failure:
                    self?.feedback = "Failed to load dog image."
                }
            }
        }
    }
    
    private func setupQuestion(from imageURL: String) {
        guard let breed = extractBreed(from: imageURL) else { return }
        correctAnswer = breed.capitalized
        
        // Dummy wrong answers for now (you can improve later by pulling breed list)
        let wrongAnswers = ["Beagle", "Poodle", "Labrador"].shuffled()
        options = ([correctAnswer] + wrongAnswers).shuffled()
    }
    
    private func extractBreed(from url: String) -> String? {
        let components = url.split(separator: "/")
        guard let breedIndex = components.firstIndex(of: Substring("breeds"))?.advanced(by: 1) else {
            return nil
        }
        return String(components[breedIndex]).replacingOccurrences(of: "-", with: " ")
    }
    
    func checkAnswer(_ answer: String) {
        feedback = (answer == correctAnswer) ? "✅ Correct!" : "❌ Wrong! It's \(correctAnswer)."
    }
}


struct ContentView: View {
    @StateObject private var viewModel = DogQuizViewModel()
    
    var body: some View {
        VStack {
            if let url = URL(string: viewModel.dogImageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(12)
                } placeholder: {
                    ProgressView()
                }
            }
            
            Spacer()
            
            Text("What breed is this?")
                .font(.headline)
                .padding()
            
            ForEach(viewModel.options, id: \.self) { option in
                Button(action: { viewModel.checkAnswer(option) }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            if let feedback = viewModel.feedback {
                Text(feedback)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Next Dog") {
                    viewModel.loadNewQuestion()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.loadNewQuestion()
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
