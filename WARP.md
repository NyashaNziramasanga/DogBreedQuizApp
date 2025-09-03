# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

DogBreedQuiz is a SwiftUI-based iOS application targeting iOS 18.2+. The project uses Xcode 16.2 and Swift 5.0, built with a standard iOS app architecture using SwiftUI for the user interface.

## Architecture

- **App Entry Point**: `DogBreedQuizApp.swift` - Main app struct using `@main` and SwiftUI `App` protocol
- **Main View**: `ContentView.swift` - Root view controller containing the primary UI
- **Assets**: Standard iOS asset catalog structure with app icons and accent colors
- **Testing**: Dual testing approach with unit tests (Swift Testing framework) and UI tests (XCTest)

The project follows standard iOS development patterns with:
- SwiftUI for declarative UI
- Modern Swift Testing framework for unit tests
- XCTest framework for UI testing
- Automatic code signing
- Support for both iPhone and iPad (universal app)

## Common Commands

### Building and Running
```bash
# Build the project
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuiz -configuration Debug build

# Build for release
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuiz -configuration Release build

# Run in iOS Simulator (requires Simulator to be open)
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuiz -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug build

# Clean build folder
xcodebuild -project DogBreedQuiz.xcodeproj clean
```

### Testing
```bash
# Run all tests
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuiz test -destination 'platform=iOS Simulator,name=iPhone 15'

# Run only unit tests
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuizTests test -destination 'platform=iOS Simulator,name=iPhone 15'

# Run only UI tests
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuizUITests test -destination 'platform=iOS Simulator,name=iPhone 15'

# Run a specific test
xcodebuild -project DogBreedQuiz.xcodeproj -scheme DogBreedQuizTests -only-testing:DogBreedQuizTests/example test -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Analysis
```bash
# SwiftLint (if added to project)
swiftlint

# SwiftFormat (if added to project)
swiftformat .
```

## Development Notes

### Project Structure
- Main app code lives in `DogBreedQuiz/` directory
- Unit tests use the modern Swift Testing framework in `DogBreedQuizTests/`
- UI tests use XCTest framework in `DogBreedQuizUITests/`
- Assets are managed through Xcode asset catalogs in `DogBreedQuiz/Assets.xcassets/`

### Testing Framework
- Unit tests use `@Test` attribute from Swift Testing framework (not XCTest)
- UI tests continue to use XCTest with `XCUIApplication`
- Launch performance tests are included for measuring app startup time

### Build Configuration
- **Deployment Target**: iOS 18.2+
- **Swift Version**: 5.0
- **Device Support**: Universal (iPhone and iPad)
- **Bundle Identifier**: com.DogBreedQuiz
- **Code Signing**: Automatic

### Key Development Considerations
- The app uses SwiftUI Previews (`#Preview`) for rapid UI development
- No external dependencies are currently configured (no SPM, CocoaPods, or Carthage)
- Asset catalogs are used for app icons and colors with automatic symbol generation enabled
- The project is configured for modern iOS development with the latest SDK features
