# 🐕 Dog Breed Quiz App

An interactive iOS quiz game inspired by [kahoot](https://kahoot.com/) that tests your knowledge of dog breeds. The app fetches random dog images and challenges players to identify the correct breed from multiple choices.

|||||
|:--:|:--:|:--:|:--:|
|![Demo Video](Media/demo.gif) |![Start Game](Media/start-game.png) |![Select Breed](Media/select-breed.png) |![End Game](Media/end-game.png)|

## ✨ Features

- 🎮 Customizable quiz length (5, 10, 15, or 20 questions)
- 🎯 Multiple choice quiz format with 4 options
- ⏱️ 10-second timer with visual countdown
- 🎵 Background music with toggle control
- 🔊 Sound effects for correct/wrong answers
- 📊 Progress bar showing quiz completion
- ✅ Immediate visual feedback on answers
- 💪 Haptic feedback for enhanced UX
- 🏆 Performance-based emoji ratings
- 🎯 Score tracking with running total

## 🎮 How to Play

1. Launch the app
2. Choose the number of breeds you want to guess (5-20)
3. For each question:
   - You have 10 seconds to identify the breed
   - Select from four possible answers
   - Get immediate feedback on your choice
4. After completing all questions:
   - View your final score
   - See your performance rating (emoji based)
   - Option to play again

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/NyashaNziramasanga/DogBreedQuizApp.git
```

2. Open the project in Xcode:
```bash
cd DogBreedQuizApp
open DogBreedQuiz.xcodeproj
```

3. Build and run the project in Xcode using ⌘R or the play button.

## 📱 App Structure

### Views
- `ContentView.swift` - Main game interface and layout management
  - `gameView` - Core game interface with progress bar, controls, and answer grid
  - `StartDialog` - Game configuration with question count picker
  - `ScoreDialog` - End game performance display with emoji rating
  - `AnswerButton` - Custom button with state-based styling

### View Model
- `DogQuizViewModel` - Game logic and state management
  - State management for game progress
  - Timer handling and auto-progression
  - Sound effects and background music
  - Score tracking and game flow
  - Answer validation and feedback

### Networking
- `DogAPI.swift` - Dog breed data fetching
  - Random dog image retrieval
  - Breed list management
  - API response handling

## 🛠️ Built With

- **[SwiftUI](https://developer.apple.com/swiftui/)** - Modern declarative UI framework
- **[AVFoundation](https://developer.apple.com/av-foundation/)** - Audio playback and effects
- **[Dog CEO API](https://dog.ceo/dog-api/)** - Dog image and breed data
- **[Combine](https://developer.apple.com/documentation/combine)** - Reactive programming
- **[Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)** - Async/await for network calls

