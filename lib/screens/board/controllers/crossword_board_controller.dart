import 'package:crosswordia/core/constants/constants.dart';
import 'package:crosswordia/core/constants/letter_frequencies.dart';
import 'package:crosswordia/core/extensions/map_extensions.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/screens/board/helpers/horizontal_check.dart';
import 'package:crosswordia/screens/board/helpers/vertical_check.dart';
import 'package:crosswordia/services/models/word_placement_data.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';

class CrosswordBoardController extends ChangeNotifier {
  CrosswordBoardController({
    required Set<String> words,
    required Set<String> foundWords,
    required int level,
    required PlayerStatus playerStatus,
    required String userId,
  })  : _inputWords = words,
        _inputFoundWords = foundWords,
        _level = level,
        _playerStatus = playerStatus,
        _userId = userId;

  // Constants
  static const int boardRows = 12;

  // Input parameters
  final Set<String> _inputWords;
  final Set<String> _inputFoundWords;
  final int _level;
  PlayerStatus _playerStatus;
  final String _userId;

  // Game state
  final Set<String> _allPlacedWords = {};
  final Set<String> _foundPlacedWords = {};

  List<String> _lettersForTheBoard = [];
  final Set<String> _revealedLetterPositions = {};
  Map<String, List<String>> _letterPositions = {};
  final Map<String, List<String>> _foundLetterPositions = {};
  final Map<String, List<String>> _wordPositions = {};
  Set<String> _totalFoundWordsOLevel = {};
  String _currentlyCreatedWord = '';
  late List<String> _sortedWords;
  final List<String> _words = []; // Working list for board generation

  // Getters
  Set<String> get allPlacedWords => _allPlacedWords;
  List<String> get lettersForTheBoard => _lettersForTheBoard;
  Set<String> get revealedLetterPositions => _revealedLetterPositions;
  Map<String, List<String>> get letterPositions => _letterPositions;
  Map<String, List<String>> get foundLetterPositions => _foundLetterPositions;
  Map<String, List<String>> get wordPositions => _wordPositions;
  String get currentlyCreatedWord => _currentlyCreatedWord;
  PlayerStatus get playerStatus => _playerStatus;
  int get level => _level;
  String get userId => _userId;
  Set<String> get totalWordsOfLevel => _inputWords;
  Set<String> get totalFoundWordsOfLevel => _totalFoundWordsOLevel;

  // Word list for lookup this is for testing purposes
  final wordsToLook = words1
    ..addAll(words2)
    ..addAll(words3)
    ..addAll(words4)
    ..addAll(words5)
    ..addAll(words6)
    ..addAll(words7)
    ..addAll(words8)
    ..addAll(words9)
    ..addAll(words10)
    ..addAll(words11)
    ..addAll(words12)
    ..addAll(words13)
    ..addAll(words14)
    ..addAll(words15)
    ..addAll(words16)
    ..addAll(words17)
    ..addAll(words18)
    ..addAll(words19)
    ..addAll(words20)
    ..sort((a, b) => b.length.compareTo(a.length));

  void initialize() {
    _totalFoundWordsOLevel = _inputFoundWords;
    _sortedWords = _inputWords.map((e) => e.toGreekUpperCase()).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    _generateBoard();
  }

  void updateCurrentWord(String word) {
    _currentlyCreatedWord = word;
    notifyListeners();
  }

  void addLetterToCurrentWord(String letter) {
    _currentlyCreatedWord += letter;
    notifyListeners();
  }

  void removeLastLetterFromCurrentWord() {
    if (_currentlyCreatedWord.isNotEmpty) {
      _currentlyCreatedWord =
          _currentlyCreatedWord.substring(0, _currentlyCreatedWord.length - 1);
      notifyListeners();
    }
  }

  void clearCurrentWord() {
    _currentlyCreatedWord = '';
    notifyListeners();
  }

  void shuffleLetters() {
    _lettersForTheBoard.shuffle();
    notifyListeners();
  }

  /// Places a word on the board and updates the letter positions
  void _placeWord({
    required String row,
    required String col,
    required String word,
    required bool isHorizontal,
    required int startingPoint,
  }) {
    // kLog.i('adding word $word ${isHorizontal ? 'horizontally' : 'vertically'}\n'
    //     'starting at $row, $col');
    _allPlacedWords.add(word);

    final int rowInt = int.parse(row);
    final int colInt = int.parse(col);

    _wordPositions[word] = [];

    int startPoint = startingPoint;
    for (final String letter in word.split('')) {
      if (isHorizontal) {
        if (_letterPositions[letter] == null) {
          _wordPositions[word]?.add('$rowInt.$startPoint');
          _letterPositions[letter] = ['$rowInt.$startPoint'];
        } else {
          _wordPositions[word]?.add('$rowInt.$startPoint');
          _letterPositions[letter]!.add('$rowInt.$startPoint');
        }
      } else if (_letterPositions[letter] == null) {
        _wordPositions[word]?.add('$startPoint.$colInt');
        _letterPositions[letter] = ['$startPoint.$colInt'];
      } else {
        _wordPositions[word]?.add('$startPoint.$colInt');
        _letterPositions[letter]!.add('$startPoint.$colInt');
      }
      startPoint++;
    }
  }

  /// Validates and processes a created word
  Future<bool> checkCreatedWord(List<String> word) async {
    if (word.isEmpty || word.length < 3) {
      clearCurrentWord();
      return false;
    }

    final joinedWord = word.join();
    final bool createdWordExists =
        _inputWords.any((word) => word.toGreekUpperCase() == joinedWord);

    // kLog.f(
    //   '$word joined word: $joinedWord created word exists: $createdWordExists',
    // );

    // If the word exists and is not in the found words list save it
    if (createdWordExists && !_totalFoundWordsOLevel.contains(joinedWord)) {
      clearCurrentWord();

      // kLog.f('Adding $joinedWord to found words');
      _totalFoundWordsOLevel.add(joinedWord);

      final levelId = await PlayerStatusService.instance.getLevelId(_level);
      final userId = PlayerStatusService.instance.getUserId();
      if (userId != null && levelId != null) {
        PlayerStatusService.instance
            .addWordInLevelProgress(userId, _level, joinedWord);
      }

      // Search for the word in the wordPositions map
      final MapEntry<String, List<String>> wordFound =
          _wordPositions.entries.firstWhere(
        (wordPosition) => wordPosition.key == joinedWord,
        orElse: () => const MapEntry('', []),
      );

      // kLog.f('word found ? ${wordFound.key != ''}');

      final bool wordExistsOnBoard = wordFound.key != '';

      // Remove any letter positions from revealedLetters positions that are in the found word
      _revealedLetterPositions.removeWhere((position) {
        return wordFound.value.contains(position);
      });

      if (wordExistsOnBoard) {
        _foundLetterPositions.addAll(
          Map.fromEntries([wordFound]),
        );
        // kLog.f(_foundLetterPositions);
        notifyListeners();
      }

      return true;
    } else {
      clearCurrentWord();
      return false;
    }
  }

  /// Maps the positions of each letter in the found words to the foundLetterPositions map.
  void _mapFoundWordLetterPositions() {
    for (final word in _totalFoundWordsOLevel) {
      final MapEntry<String, List<String>> wordFound =
          _wordPositions.entries.firstWhere(
        (element) => element.key == word,
        orElse: () => const MapEntry('', []),
      );

      if (wordFound.key != '') {
        _foundLetterPositions.addAll(
          Map.fromEntries([wordFound]),
        );
      }
    }
  }

  /// Generates the crossword board by placing words
  void _generateBoard() {
    _letterPositions = {};
    _totalFoundWordsOLevel = _inputFoundWords;

    _words.addAll(_sortedWords);
    _words.sort((a, b) => b.length.compareTo(a.length));

    _arrangeWords(_words);

    final List<String> notPlacedWords =
        _words.where((w) => !_allPlacedWords.contains(w)).toList();

    if (notPlacedWords.isNotEmpty) {
      //    kLog.d('Trying to add not placed words $notPlacedWords');
      _arrangeWords(notPlacedWords);
    }

    kLog.f(
      'all words $_words\nplaced words $_allPlacedWords\nnot placed words $notPlacedWords',
    );

    _generateLettersForConnector();
    _mapFoundWordLetterPositions();
    notifyListeners();
  }

  /// Arranges words on the board
  void _arrangeWords(List<String> wordsForArrangement) {
    for (var i = 0; i < wordsForArrangement.length; i++) {
      if (i == 0 && _allPlacedWords.isEmpty) {
        // We calculate the approximate middle of the board to put the first word
        final int startAfter =
            (((boardRows - wordsForArrangement[i].length) / 2) + 1).ceil();
        _placeWord(
          row: '6',
          col: '$startAfter',
          word: wordsForArrangement[i],
          isHorizontal: true,
          startingPoint: startAfter,
        );
      } else {
        final wordSplit = wordsForArrangement[i].split('');
        final word = wordsForArrangement[i];
        letterLoop:
        for (int i = 0; i < wordSplit.length; i++) {
          final foundLocations = _letterPositions[wordSplit[i]];
          final letter = wordSplit[i];

          // If we found an intersection
          if (foundLocations != null) {
            for (final location in foundLocations) {
              // The row and column of the found letter
              final String row = location.before('.');
              final String col = location.after('.');

              final int rowInt = int.parse(row);
              final int colInt = int.parse(col);

              // Those are the spaces from the found letter to the edge of the board
              final spaceFromLeft = colInt;
              final spaceFromRight = boardRows - colInt;
              final spaceFromTop = rowInt;
              final spaceFromBottom = boardRows - rowInt;

              // Those are the distances from the found letter to the edge of the word
              final distanceFromLeftOfLetter = i;
              final distanceFromRightOfLetter = wordSplit.length - i - 1;

              final distanceFromTopOfLetter = rowInt - i;
              final distanceFromBottomOfLetter = wordSplit.length - i - 1;

              // Starting and ending positions for horizontal placement
              final actualHorizontalStartingLocationIfAvailable =
                  '$rowInt.${colInt - distanceFromLeftOfLetter}';
              final actualHorizontalEndingLocationIfAvailable =
                  '$rowInt.${colInt + distanceFromRightOfLetter}';

              // Starting and ending positions for vertical placement
              final actualVerticalStartingLocationIfAvailable =
                  '${rowInt - distanceFromLeftOfLetter}.$colInt';
              final actualVerticalEndingLocationIfAvailable =
                  '${rowInt + distanceFromRightOfLetter}.$colInt';

              final actualVerticalBeforeStartingLocationIfAvailable =
                  '${rowInt - distanceFromLeftOfLetter - 1}.$colInt';

              final actualVerticalAfterEndingLocationIfAvailable =
                  '${rowInt + distanceFromRightOfLetter + 1}.$colInt';
              // Check if the word can be placed vertically
              final bool canStartVerticallyWithThatLetter = canStartVertically(
                WordPlacementData(
                  distanceFromTopOfLetter: distanceFromTopOfLetter,
                  distanceFromBottomOfLetter: distanceFromBottomOfLetter,
                  spaceFromTop: spaceFromTop,
                  spaceFromBottom: spaceFromBottom,
                  actualVerticalStartingLocationIfAvailable:
                      actualVerticalStartingLocationIfAvailable,
                  actualVerticalEndingLocationIfAvailable:
                      actualVerticalEndingLocationIfAvailable,
                  word: word,
                  col: col,
                  location: location,
                  actualVerticalBeforeStartingLocationIfAvailable:
                      actualVerticalBeforeStartingLocationIfAvailable,
                  actualVerticalAfterEndingLocationIfAvailable:
                      actualVerticalAfterEndingLocationIfAvailable,
                  rowInt: rowInt,
                  colInt: colInt,
                  letterPositions: _letterPositions,
                  letter: letter,
                  letterIndex: i,
                  foundLocations: foundLocations,
                  boardRows: boardRows,
                ),
              );

              final bool canStartHorizontallyWithThatLetter =
                  canStartHorizontally(
                distanceFromRightOfLetter: distanceFromRightOfLetter,
                distanceFromLeftOfLetter: distanceFromLeftOfLetter,
                spaceFromLeft: spaceFromLeft,
                spaceFromRight: spaceFromRight,
                word: word,
                col: col,
                location: location,
                actualHorizontalStartingLocationIfAvailable:
                    actualHorizontalStartingLocationIfAvailable,
                actualHorizontalEndingLocationIfAvailable:
                    actualHorizontalEndingLocationIfAvailable,
                actualVerticalBeforeStartingLocationIfAvailable:
                    actualVerticalBeforeStartingLocationIfAvailable,
                actualVerticalAfterEndingLocationIfAvailable:
                    actualVerticalAfterEndingLocationIfAvailable,
                rowInt: rowInt,
                colInt: colInt,
                letterIndex: i,
                letterPositions: _letterPositions,
                letter: letter,
                foundLocations: foundLocations,
                boardRows: boardRows,
              );

              if (canStartVerticallyWithThatLetter) {
                _placeWord(
                  row: row,
                  col: col,
                  word: word,
                  isHorizontal: false,
                  startingPoint: actualVerticalStartingLocationIfAvailable
                      .before('.')
                      .toInt()!,
                );
                break letterLoop;
              } else if (canStartHorizontallyWithThatLetter) {
                _placeWord(
                  row: row,
                  col: col,
                  word: word,
                  isHorizontal: true,
                  startingPoint: actualHorizontalStartingLocationIfAvailable
                      .after('.')
                      .toInt()!,
                );
                break letterLoop;
              }
            }
          }
        }
      }
    }
  }

  /// Generates the letters for the connector
  void _generateLettersForConnector() {
    // find repeated letters and their count
    final Map<String, int> repeatedLetters = {};
    final List<String> extraLettersToAdd = [];

    for (final word in _allPlacedWords) {
      for (final Map<String, int> charOcc in word.charOccurences) {
        if (charOcc.values.first > 1) {
          // If the occurrence of the letter is greater than the one already in the map
          if (repeatedLetters[charOcc.keys.first] == null ||
              repeatedLetters[charOcc.keys.first]! < charOcc.values.first) {
            repeatedLetters[charOcc.keys.first] = charOcc.values.first;
          }
        }
      }
    }

    repeatedLetters.forEach((key, value) {
      for (var i = 0; i < value; i++) {
        extraLettersToAdd.add(key);
      }
    });

    _lettersForTheBoard = [
      ..._allPlacedWords
          .join()
          .split('')
          .toSet()
          .where((value) => !value.isIn(repeatedLetters.keys)),
      ...extraLettersToAdd,
    ]..shuffle();
  }

  /// Reveals a letter by spending coins
  Future<bool> revealLetter(String position) async {
    final Map<String, dynamic> letterFound = _letterPositions.whereValue(
      (letters) => letters.contains(position),
    );

    if (letterFound.keys.isEmpty) return false;

    final num letterFreq =
        letterFrequencies[letterFound.keys.first.toGreekUpperCase()] ?? 0.0;
    final letterScore = letterFreq == 0 ? 0 : (1 / letterFreq).round();

    if (_playerStatus.coins >= letterScore) {
      await PlayerStatusService.instance.updatePlayerStatus(
        _playerStatus.copyWith(
          coins: _playerStatus.coins - letterScore,
        ),
      );

      final updatedStatus =
          await PlayerStatusService.instance.getPlayerStatus(_userId);
      if (updatedStatus != null) {
        _playerStatus = updatedStatus;
      }

      _revealedLetterPositions.add(position);
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Checks if a letter at a position can be revealed
  bool canRevealLetter(String position) {
    final Map<String, dynamic> letterFound = _letterPositions.whereValue(
      (letters) => letters.contains(position),
    );

    final bool letterFoundIsNotAlreadyRevealed =
        !_revealedLetterPositions.contains(position);

    final letterIsAlreadyFound = _foundLetterPositions.anyValue(
      (value) => value.contains(position),
    );

    return letterFound.keys.isNotEmpty &&
        letterFoundIsNotAlreadyRevealed &&
        letterIsAlreadyFound == false;
  }

  /// Gets the letter at a specific position
  String? getLetterAtPosition(String position) {
    final Map<String, dynamic> letterFound = _letterPositions.whereValue(
      (letters) => letters.contains(position),
    );

    return letterFound.keys.isNotEmpty
        ? letterFound.keys.first.toUpperCase()
        : null;
  }

  /// Checks if a letter should be visible at a position
  bool isLetterVisible(String position) {
    return _foundLetterPositions.values.any(
          (element) => element.contains(position),
        ) ||
        _revealedLetterPositions.contains(position);
  }

  /// Checks if a letter is revealed (dimmed)
  bool isLetterRevealed(String position) {
    return _revealedLetterPositions.contains(position);
  }
}
