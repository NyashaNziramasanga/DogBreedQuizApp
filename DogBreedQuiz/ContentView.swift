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
    @Published var isGameStarted: Bool = false
    @Published var selectedNumberOfQuestions: Int = 10
    @Published var remainingQuestions: Int = 10  // Initialize with default value
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
    
    func startGame(with numberOfQuestions: Int) {
        selectedNumberOfQuestions = numberOfQuestions
        remainingQuestions = numberOfQuestions
        score = 0
        totalQuestions = 0
        isGameStarted = true
        loadNewQuestion()
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
        
        // Check if this was the last question
        if remainingQuestions == 0 {
            // Show correct answer for 2 seconds then end game
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.endGame()
            }
        } else {
            // Auto-progress after showing correct answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.loadNewQuestion()
                self?.answeredOption = nil
                self?.isTimeUp = false
            }
        }
    }
    
    private func endGame() {
        // Stop all timers
        questionTimer?.invalidate()
        autoProgressTimer?.invalidate()
        
        // Reset states
        timeRemaining = 0
        isTimeUp = false
        isGameStarted = false
    }
    
    func loadNewQuestion() {
        guard remainingQuestions > 0 else {
            // Game is finished
            endGame()
            return
        }
        
        remainingQuestions -= 1
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
        
        // Check if this was the last question
        if remainingQuestions == 0 {
            // Show result for 2 seconds then end game
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.endGame()
            }
        } else {
            // Set up new timer for auto-progression
            autoProgressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadNewQuestion()
                    self?.answeredOption = nil
                }
            }
        }
    }
}

// MARK: - Score Dialog
struct ScoreDialog: View {
    let score: Int
    let totalQuestions: Int
    let onPlayAgain: () -> Void
    
    private var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int(Double(score) / Double(totalQuestions) * 100)
    }
    
    private var emoji: String {
        switch percentage {
        case 90...100: return "🏆"
        case 70...89: return "🌟"
        case 50...69: return "👍"
        default: return "🎯"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(emoji)
                .font(.system(size: 50))
            
            Text("Quiz Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                Text("Your Score:")
                    .font(.headline)
                Text("\(percentage)%")
                    .font(.system(size: 40, weight: .bold))
                Text("\(score) out of \(totalQuestions) correct")
                    .foregroundColor(.secondary)
            }
            
            Button(action: onPlayAgain) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - Start Dialog
struct StartDialog: View {
    @Binding var isPresented: Bool
    let onStart: (Int) -> Void
    @State private var selectedQuestions = 10
    
    let questionOptions = [5, 10, 15, 20]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🐕 Dog Breed Quiz")
                .font(.title)
                .fontWeight(.bold)
            
            Text("How many breeds would you like to guess?")
                .font(.headline)
            
            Picker("Number of Questions", selection: $selectedQuestions) {
                ForEach(questionOptions, id: \.self) { number in
                    Text("\(number) breeds").tag(number)
                }
            }
            .pickerStyle(.wheel)
            
            Button(action: {
                onStart(selectedQuestions)
                isPresented = false
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var viewModel = DogQuizViewModel()
    @State private var showStartDialog = true
    @State private var showScoreDialog = false
    
    var body: some View {
        ZStack {
            if viewModel.isGameStarted {
                gameView
            }
            
            if showStartDialog {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                StartDialog(isPresented: $showStartDialog) { numberOfQuestions in
                    viewModel.startGame(with: numberOfQuestions)
                }
                .padding()
            }
            
            if showScoreDialog {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                ScoreDialog(
                    score: viewModel.score,
                    totalQuestions: viewModel.totalQuestions
                ) {
                    showScoreDialog = false
                    showStartDialog = true
                }
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: viewModel.isGameStarted) { isStarted in
            if !isStarted && !showStartDialog {
                withAnimation {
                    showScoreDialog = true
                }
            }
        }
    }
    
    private var gameView: some View {
        VStack (spacing:16){
            // SCORE & TIMER
            HStack {
                // SCORE
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)/\(viewModel.selectedNumberOfQuestions)")
                        .font(.headline)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                // TIMER
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
