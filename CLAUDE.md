# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Analyze code for issues
- `flutter clean` - Clean build artifacts

### Project-Specific Commands
- `./clean.sh` - Full clean and dependency update (includes Flutter clean, pub get, iOS pod install)
- `fvm flutter [command]` - This project uses Flutter Version Management (FVM)

### Linting and Code Quality
- Uses `package:lint/strict.yaml` for strict linting rules
- Analysis options configured in `analysis_options.yaml`
- `sort_pub_dependencies` rule is disabled

## High-Level Architecture

### Application Structure
**CrossWordia** is a Greek crossword puzzle game built with Flutter, similar to "Words of Wonders". It's structured as a thesis project with sophisticated word scoring algorithms and crossword generation.

### Core Components

#### 1. Crossword Board System (`lib/screens/board/`)
- **CrosswordBoardController**: Main game logic controller managing board state, word placement, and game progression
- **Word Placement Algorithm**: Complex algorithm for arranging words on a 12x12 crossword grid
- **Letter Management**: Handles letter positioning, visibility, and revealing mechanics

#### 2. Word Scoring System (`lib/core/constants/letter_frequencies.dart`)
- Implements frequency-based scoring using Greek letter frequencies
- Formula: `Score = Σ(1/frequency) + (10 × word_length)`
- Rare letters (Ψ, Ζ, Ξ) score significantly higher than common letters (Α, Ο, Ι)

#### 3. Data Layer
- **Supabase Integration**: Backend database for user management and level progression
- **LevelsService**: Manages level data, CRUD operations for crossword levels
- **PlayerStatusService**: Handles user progress, coins, and achievements

#### 4. Game Mechanics
- **Word Validation**: Checks created words against predefined word sets
- **Letter Revealing**: Coin-based system for revealing letters (cost based on letter rarity)
- **Progress Tracking**: Persistent user progress across levels

### Key Models
- **Word**: Represents a word with description and calculated score
- **Level**: Contains word sets and letter arrangements for each level
- **WordPlacementData**: Data structure for crossword placement algorithms

### State Management
- Uses **Riverpod** for state management
- Controllers extend `ChangeNotifier` for reactive UI updates

### Backend Integration
- **Supabase**: PostgreSQL database with real-time features
- Authentication and user management
- Level progression and statistics tracking

### Greek Language Processing
- Specialized handling of Greek text (diacritics, case conversion)
- Greek letter frequency analysis for scoring
- Word validation against Greek dictionary sets

### Assets and Resources
- Custom fonts: Arima Regular/Bold
- PDF dictionary resource: `assets/babiniotis.pdf`
- Background and UI assets in `assets/`

## Development Notes

### Platform Support
- Android, iOS, macOS, and Web builds supported
- Uses platform-specific configurations for each target

### Testing Strategy
- Unit tests should focus on word scoring algorithms and placement logic
- Integration tests for Supabase operations
- Widget tests for UI components

### Code Organization
- Feature-based organization under `lib/screens/`
- Shared utilities in `lib/core/`
- Services layer for data operations
- Separation of concerns between UI, business logic, and data layers