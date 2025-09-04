//
//  ContentView.swift
//  DogBreedQuiz
//
//  Created by Nyasha Nziramasanga on 3/9/2025.
//

import SwiftUI
import AVFoundation

// MARK: - DogQuizViewModel
class DogQuizViewModel: ObservableObject {
    @Published var dogImageURL: String = ""
    @Published var options: [String] = []
    @Published var correctAnswer: String = ""
    @Published var answeredOption: String?
    @Published var score: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var isTimeUp: Bool = false
    private var allBreeds: [String] = []
    private var autoProgressTimer: Timer?
    private var questionTimer: Timer?
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    // Audio players for feedback sounds
    private var correctSound: AVAudioPlayer?
    private var wrongSound: AVAudioPlayer?
    
    init() {
        setupSounds()
    }
    
    private func setupSounds() {
        if let correctPath = Bundle.main.path(forResource: "correct", ofType: "mp3") {
            do {
                correctSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: correctPath))
                correctSound?.prepareToPlay()
            } catch {
                print("Error loading correct sound: \(error)")
            }
        }
        
        if let wrongPath = Bundle.main.path(forResource: "wrong", ofType: "mp3") {
            do {
                wrongSound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: wrongPath))
                wrongSound?.prepareToPlay()
            } catch {
                print("Error loading wrong sound: \(error)")
            }
        }
    }
    
    private func startQuestionTimer() {
        timeRemaining = 10
        isTimeUp = false
        questionTimer?.invalidate()
        
        questionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.questionTimer?.invalidate()
                self.timeUp()
            }
        }
    }
    
    private func timeUp() {
        isTimeUp = true
        wrongSound?.play()
        totalQuestions += 1
        
        // Auto-progress after showing correct answer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.loadNewQuestion()
            self?.answeredOption = nil
            self?.isTimeUp = false
        }
    }
    
    func loadNewQuestion() {
        DogAPI.fetchRandomDogImage { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    self?.dogImageURL = imageURL
                    self?.setupQuestion(from: imageURL)
                    self?.startQuestionTimer()
                case .failure:
                    print("Failed to load dog image.")
                }
            }
        }
    }
    
    private func setupQuestion(from imageURL: String) {
        guard let breed = extractBreed(from: imageURL) else { return }
        correctAnswer = breed.capitalized
        
        // If we don't have breeds yet, fetch them
        if allBreeds.isEmpty {
            DogAPI.fetchAllBreeds { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let breeds):
                        self?.allBreeds = breeds
                        self?.setupOptions()
                    case .failure:
                        // Fallback to dummy answers if fetch fails
                        self?.setupDummyOptions()
                    }
                }
            }
        } else {
            setupOptions()
        }
    }
    
    private func setupOptions() {
        // Filter out the correct answer from available breeds
        let availableBreeds = allBreeds.filter { $0 != correctAnswer }
        // Get 3 random wrong answers
        let wrongAnswers = Array(availableBreeds.shuffled().prefix(3))
        options = ([correctAnswer] + wrongAnswers).shuffled()
    }
    
    private func setupDummyOptions() {
        // Fallback dummy wrong answers
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
        answeredOption = answer
        let isCorrect = answer == correctAnswer
        totalQuestions += 1
        if isCorrect {
            score += 1
        }
        
        // Provide haptic feedback
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
        
        // Play appropriate sound
        if isCorrect {
            correctSound?.play()
        } else {
            wrongSound?.play()
        }
        
        // Cancel any existing timer
        autoProgressTimer?.invalidate()
        
        // Set up new timer for auto-progression
        autoProgressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadNewQuestion()
                self?.answeredOption = nil
            }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var viewModel = DogQuizViewModel()
    
    var body: some View {
        VStack (spacing:16){
            // Score Display
            HStack {
                // Score
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)/\(viewModel.totalQuestions)")
                        .font(.headline)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .blue)
                    Text("\(viewModel.timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .primary)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .animation(.default, value: viewModel.timeRemaining)
            }
            
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
            
            // QUESTION
            Text("What breed is this ?")
                         .font(.title2)
                         .fontWeight(.bold)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
            
            // ANSWER OPTIONS
              LazyVGrid(columns: [
                  GridItem(.flexible(), spacing: 8),
                  GridItem(.flexible(), spacing: 8)
              ], spacing: 8) {
                  ForEach(viewModel.options, id: \.self) { option in
                      AnswerButton(
                          option: option,
                          action: { viewModel.checkAnswer(option) },
                          isCorrect: (viewModel.answeredOption == option || viewModel.isTimeUp) ? (option == viewModel.correctAnswer) : nil
                      )
                  }
              }
              .padding(8)
              .animation(.spring(response: 0.3), value: viewModel.answeredOption)
            
        }
        .onAppear {
            viewModel.loadNewQuestion()
        }
        .padding()
    }
}


// MARK: - Answer Button
struct AnswerButton: View {
    let option: String
    let action: () -> Void
    let isCorrect: Bool?
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: action) {
                ZStack(alignment: .topTrailing) {
                    Text(option)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .background(backgroundColor)
                        .cornerRadius(10)
                    
                    if let isCorrect = isCorrect {
                        Text(isCorrect ? "✅" : "❌")
                            .font(.title2)
                            .padding(8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .disabled(isCorrect != nil)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var backgroundColor: Color {
        guard let isCorrect = isCorrect else {
            return Color.blue.opacity(0.2)
        }
        return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
    }
}

#Preview {
    ContentView()
}
