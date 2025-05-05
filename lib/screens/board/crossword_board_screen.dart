import 'package:crosswordia/constants/constants.dart';
import 'package:crosswordia/constants/letter_frequencies.dart';
import 'package:crosswordia/extensions/map_extensions.dart';
import 'package:crosswordia/find_word_groups.dart';
import 'package:crosswordia/scraper.dart';
import 'package:crosswordia/screens/board/helpers/horizontal_check.dart';
import 'package:crosswordia/screens/board/helpers/vertical_check.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';

// void saveTextToFile(String text) async {
//   final directory = await getApplicationDocumentsDirectory();
//   final file = File('/storage/emulated/0/Download/greek_words.txt');
//   final res = await file.writeAsString(text);
//   print(res);
// }

class CrosswordBoardScreen extends StatefulWidget {
  const CrosswordBoardScreen({
    required this.words,
    required this.foundWords,
    required this.level,
    required this.playerStatus,
    required this.userId,
    super.key,
  });

  final Set<String> words;
  final Set<String> foundWords;
  final int level;
  final PlayerStatus playerStatus;
  final String userId;
  @override
  State<CrosswordBoardScreen> createState() => _CrosswordBoardScreenState();
}

class _CrosswordBoardScreenState extends State<CrosswordBoardScreen> {
  final int boardRows = 12;
  List<List<String>> board = [];
  Set<String> placedWords = {};

  List<String> lettersForTheBoard = [];
  Set<String> revealedLetterPositions = {};

  Map<String, List<String>> letterPositions = {};
  Map<String, List<String>> foundLetterPositions = {};
  Map<String, List<String>> wordPositions = {};

  Map<String, Set<String>> groupedWords = {};

  Set<String> foundWords = {};

  PlayerStatus? playerStatus;

  final LettersController _controller = LettersController();

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

    // .where((element) => element.hasUniqueCharacters())
    // .toList()
    ..sort((a, b) => b.length.compareTo(a.length));

// ΑΑΙΛΜΣ
  // Set<String> testWords = {
  //   "σαλάμι",
  //   "σάμαλι",
  //   "μασάλι",
  //   "σαλμί",
  //   "μασιά",
  //   "λάμια",
  //   "λαιμά",
  //   "σάλια",
  //   "μάλια",
  //   "σιμά",
  //   "σάλι",
  //   "σάλα",
  //   "μιλα",
  //   "άμια",
  //   "μαία",
  //   "αίμα",
  //   "άλας",
  //   "άλμα",
  //   "μάσα",
  //   "λίμα",
  //   "λάμα",
  //   "σαλα",
  //   "άσμα",
  //   "ίσα",
  //   "άμα",
  //   "μια",
  //   "μις",
  //   "αλί",
  //   "αλά",
  //   "μία",
  //   "μας",
  // };

  void _placeWord({
    required String row,
    required String col,
    required String word,
    required bool isHorizontal,
    required int startingPoint,
  }) {
    kLog.i('adding word $word ${isHorizontal ? 'horizontally' : 'vertically'}\n'
        'starting at $row, $col');
    placedWords.add(word);
    //kLog.i('Added word $word');
    final int rowInt = int.parse(row);
    final int colInt = int.parse(col);

    wordPositions[word] = [];

    int startPoint = startingPoint;
    for (final String letter in word.split('')) {
      if (isHorizontal) {
        if (letterPositions[letter] == null) {
          wordPositions[word]?.add('$rowInt.$startPoint');
          letterPositions[letter] = ['$rowInt.$startPoint'];
        } else {
          wordPositions[word]?.add('$rowInt.$startPoint');
          letterPositions[letter]!.add('$rowInt.$startPoint');
        }
      } else if (letterPositions[letter] == null) {
        wordPositions[word]?.add('$startPoint.$colInt');
        letterPositions[letter] = ['$startPoint.$colInt'];
      } else {
        wordPositions[word]?.add('$startPoint.$colInt');
        letterPositions[letter]!.add('$startPoint.$colInt');
      }
      startPoint++;
    }
  }

  late List<String> sortedWords = widget.words
      .map(
        (e) => e.toGreekUpperCase(),
      )
      .toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  List<String> words = [];

  /// Checks if the word is in the wordPositions map
  Future<void> _checkCreatedWord(List<String> word) async {
    void resetCreatedWord() {
      setState(() {
        currentlyCreatedWord = '';
      });
    }

    if (word.isEmpty || word.length < 3) {
      _controller.triggerErrorShake();
      resetCreatedWord();
      return;
    }

    final joinedWord = word.join();

    final bool createdWordExists =
        widget.words.any((word) => word.toGreekUpperCase() == joinedWord);

    kLog.f(
      '$word joined word: $joinedWord created word exists: $createdWordExists',
    );

    // If the word exists and is not in the found words list save it
    if (createdWordExists && !foundWords.contains(joinedWord)) {
      _controller.triggerSuccessAnimation();
      resetCreatedWord();

      // We add a delay so the animation finished playing
      Future.delayed(const Duration(milliseconds: 300), () {
        lettersForTheBoard.shuffle();
      });

      kLog.f('Adding $joinedWord to found words');
      foundWords.add(joinedWord);
      final levelId =
          await PlayerStatusService.instance.getLevelId(widget.level);
      final userId = PlayerStatusService.instance.getUserId();
      if (userId != null && levelId != null) {
        PlayerStatusService.instance
            .addWordInLevelProgress(userId, widget.level, joinedWord);
      }
    } else {
      _controller.triggerErrorShake();
      resetCreatedWord();
      return;
    }
    // Search for the word in the wordPositions map
    final MapEntry<String, List<String>> wordFound =
        wordPositions.entries.firstWhere(
      (wordPosition) => wordPosition.key == joinedWord,
      orElse: () => const MapEntry(
        '',
        [],
      ),
    );

    kLog.f('word found ? ${wordFound.key != ''}');

    final bool wordExistsOnBoard = wordFound.key != '';

    // Remove any letter positions from revealedLetters positions that are in the found word
    revealedLetterPositions.removeWhere((position) {
      return wordFound.value.contains(position);
    });

    if (wordExistsOnBoard) {
      setState(() {
        currentlyCreatedWord = '';
        foundLetterPositions.addAll(
          Map.fromEntries([wordFound]),
        );

        kLog.f(foundLetterPositions);
      });
    }
  }

  /// Maps the positions of each letter in the found words to the foundLetterPositions map.
  void _mapFoundWordLetterPositions() {
    for (final word in foundWords) {
      final MapEntry<String, List<String>> wordFound =
          wordPositions.entries.firstWhere(
        (element) => element.key == word,
        orElse: () => const MapEntry(
          '',
          [],
        ),
      );

      if (wordFound.key != '') {
        foundLetterPositions.addAll(
          Map.fromEntries([wordFound]),
        );
      }
    }
  }

  /// * Convert all words to uppercase and sort them based on their length in descending order.
  /// * Initialize an empty letterPositions map to store the positions of each letter in the placed words.
  /// * Place the longest word (first word in the sorted list) horizontally in the middle of the board.
  /// * For each remaining word in the sorted list, attempt to place it on the board by finding an intersection with already placed words:
  ///     * Check if any letters of the current word are present in the placed words on the board.
  ///     * For each found intersection, calculate the available space and determine if the word can be placed horizontally or vertically.
  ///     * If the word can be placed, update the letterPositions map with the new word's letter positions.
  void _generateBoard() {
    letterPositions = {};
    foundWords = widget.foundWords;

    words.addAll(sortedWords);

    words.sort((a, b) => b.length.compareTo(a.length));

    void arrangeWords(List<String> wordsForArrangement) {
      for (var i = 0; i < wordsForArrangement.length; i++) {
        if (i == 0 && placedWords.isEmpty) {
          // We calculate the approxiate middle of the board to put the first word
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
            final foundLocations = letterPositions[wordSplit[i]];
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
                // We use them to check if the word can be placed, ignoring if there are other words
                final spaceFromLeft = colInt;
                final spaceFromRight = boardRows - colInt;
                final spaceFromTop = rowInt;
                final spaceFromBottom = boardRows - rowInt;

                // Those are the distances from the found letter to the edge of the word
                // We will use them to check if the word can be placed
                final distanceFromLeftOfLetter = i;
                final distanceFromRightOfLetter = wordSplit.length - i - 1;

                final dinstanceFromTopOfLetter = rowInt - i;
                final distanceFromBottomOfLetter = wordSplit.length - i - 1;

                // This is the starting point of the word IF it can be placed
                // horizontally, takes into consideration the distance from the found letter
                final actualHorizontalStartingLocationIfAvailable =
                    '$rowInt.${colInt - distanceFromLeftOfLetter}';
                final actualHorizontalEndingLocationIfAvailable =
                    '$rowInt.${colInt + distanceFromRightOfLetter}';

                final actualVerticalStartingLocationIfAvailable =
                    '${rowInt - distanceFromLeftOfLetter}.$colInt';
                final actualVerticalEndingLocationIfAvailable =
                    '${rowInt + distanceFromRightOfLetter}.$colInt';

                final actualVerticalBeforeStartingLocationIfAvailable =
                    '${rowInt - distanceFromLeftOfLetter - 1}.$colInt';

                final actualVerticalAfterEndingLocationIfAvailable =
                    '${rowInt + distanceFromRightOfLetter + 1}.$colInt';

                // Check if the word can be placed vertically
                final bool canStartVerticallyWithThatLetter =
                    canStartVertically(
                  actualVerticalStartingLocationIfAvailable:
                      actualVerticalStartingLocationIfAvailable,
                  actualVerticalEndingLocationIfAvailable:
                      actualVerticalEndingLocationIfAvailable,
                  distanceFromTopOfLetter: dinstanceFromTopOfLetter,
                  distanceFromBottomtOfLetter: distanceFromBottomOfLetter,
                  rowInt: rowInt,
                  colInt: colInt,
                  col: col,
                  actualVerticalAfterEndingLocationIfAvailable:
                      actualVerticalAfterEndingLocationIfAvailable,
                  actualVerticalBeforeStartingLocationIfAvailable:
                      actualVerticalBeforeStartingLocationIfAvailable,
                  location: location,
                  spaceFromBottom: spaceFromBottom,
                  spaceFromTop: spaceFromTop,
                  word: word,
                  letterPositions: letterPositions,
                  letter: letter,
                  letterIndex: i,
                  foundLocations: foundLocations,
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
                  letterPositions: letterPositions,
                  letter: letter,
                  foundLocations: foundLocations,
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
                } else {
                  // kLog.e('Cannot place word $word at $row.$col');
                }
              }
            }
          }
        }
      }
    }

    // Initial placement of the words
    arrangeWords(words);

    final List<String> notPlacedWords =
        words.where((w) => !placedWords.contains(w)).toList();

    if (notPlacedWords.isNotEmpty) {
      kLog.d('Trying to add not placed words $notPlacedWords');
      arrangeWords(notPlacedWords);
    }
    kLog.f(
      'all words $words\nplaced words $placedWords\nnot placed words $notPlacedWords',
    );

    _generateLettersForConnector();
    _mapFoundWordLetterPositions();
  }

  /// Generates the letters for the connector
  /// keeps the max number of repeated letters in the words
  /// for example if a word has 3 "A" three "A"s will be present in the connector
  void _generateLettersForConnector() {
    // find repeated letters and their count
    final Map<String, int> repeatedLetters = {};

    final List<String> extraLettersToAdd = [];

    for (final word in placedWords) {
      // kLog.i('Char occurences for word $word\n${word.charOccurences}');
      for (final Map<String, int> charOcc in word.charOccurences) {
        if (charOcc.values.first > 1) {
          // If the occurence of the letter is greater than the one already in the map
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

    lettersForTheBoard = [
      ...placedWords
          .join()
          .split('')
          .toSet()
          .where((value) => !value.isIn(repeatedLetters.keys)),
      ...extraLettersToAdd,
    ]..shuffle();
  }

  String currentlyCreatedWord = '';
  @override
  void initState() {
    super.initState();
    playerStatus = widget.playerStatus;
    kLog.i('Found words are $foundWords');
    _generateBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.webp',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withValues(alpha: 0.6),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: Alignment.topCenter,
              child: BlurContainer(
                height: 60,
                width: 200,
                color: Colors.blue,
                borderColor: Colors.blue,
                child: Center(
                  child: Text(
                    'Level ${widget.level}\nScore ${playerStatus?.coins}',
                    style: kStyle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                TextButton(
                  onPressed: () {
                    //  kLog.f('Αγία'.hasUniqueCharacters());
                    filterWords(wordsToLook);
                    // kLog.f(words2
                    //     .where((element) =>
                    //         element.toGreekUpperCase()!.hasUniqueCharacters())
                    //     .toList());
                    // kLog.f(groupedWords);
                    // kLog.f(mergeMap(groupedWords));
                    // kLog.f('abcd'.countUncommonLetters('abcdeef'));
                    // kLog.f(
                    //   filterWords(
                    //     allWs.map((e) => e.toGreekUpperCase()!).toList(),
                    //     ['Α', 'Τ', 'Ε', 'Σ', 'Ο', 'Ρ'],
                    //   ),
                    // );
                  },
                  child: Text('try'),
                ),
                Center(
                  child: SizedBox(
                    width: 420,
                    height: MediaQuery.of(context).size.height / 1.9,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      key: ValueKey(foundLetterPositions.hashCode),
                      padding: const EdgeInsets.all(10),
                      itemCount: boardRows * boardRows,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: boardRows,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final int row = (index ~/ boardRows) + 1;
                        final int col = (index % boardRows) + 1;

                        final currentPosition = '$row.$col';

                        final Map<String, dynamic> letterFound =
                            letterPositions.whereValue(
                          (letters) => letters.contains(currentPosition),
                        );
                        final bool letterFoundIsNotAlreadyRevealed =
                            !revealedLetterPositions.contains(currentPosition);

                        final letterIsAlreadyFound =
                            foundLetterPositions.anyValue(
                          (value) => value.contains(currentPosition),
                        );

                        return GestureDetector(
                          onTap: letterFound.keys.isNotEmpty &&
                                  letterFoundIsNotAlreadyRevealed &&
                                  letterIsAlreadyFound == false
                              ? () async {
                                  final num letterFreq = letterFrequencies[
                                          letterFound.keys.first
                                              .toGreekUpperCase()] ??
                                      0.0;
                                  final letterScore = letterFreq == 0
                                      ? 0
                                      : (1 / letterFreq).round();
                                  if (letterFound.isNotEmpty &&
                                      playerStatus != null) {
                                    await PlayerStatusService.instance
                                        .updatePlayerStatus(
                                      playerStatus!.copyWith(
                                        coins:
                                            playerStatus!.coins - letterScore,
                                      ),
                                    );
                                    playerStatus = await PlayerStatusService
                                        .instance
                                        .getPlayerStatus(widget.userId);
                                    setState(() {
                                      revealedLetterPositions
                                          .add(currentPosition);
                                    });
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: letterFound.isNotEmpty
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: letterFound.isNotEmpty
                                    ? Border.all(
                                        color:
                                            Colors.blue.withValues(alpha: 0.4),
                                        width: 2,
                                      )
                                    : Border.all(color: Colors.transparent),
                              ),
                              // child: Center(
                              //   child: Text(
                              //     letterFound.isNotEmpty
                              //         ? letterFound.keys.first.toUpperCase()
                              //         : "$row|$col\n${index + 1}",
                              //     style: TextStyle(
                              //       color: letterFound.isNotEmpty
                              //           ? Colors.black
                              //           : Colors.black,
                              //       fontSize: letterFound.isNotEmpty ? 20 : 10,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              child: Center(
                                child: Text(
                                  letterFound.isNotEmpty
                                      ? foundLetterPositions.values.any(
                                                (element) => element
                                                    .contains("$row.$col"),
                                              ) ||
                                              revealedLetterPositions
                                                  .contains("$row.$col")
                                          ? letterFound.keys.first.toUpperCase()
                                          : ""
                                      : "$row|$col\n${index + 1}",
                                  style: kStyle.copyWith(
                                    color: letterFound.isNotEmpty
                                        ? revealedLetterPositions
                                                .contains("$row.$col")
                                            ? Colors.black
                                                .withValues(alpha: 0.3)
                                            : Colors.black
                                        : Colors.transparent,
                                    fontSize: letterFound.isNotEmpty ? 20 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // BlurContainer(
                //   color: Colors.blue,
                //   borderColor: Colors.blue,
                //   opacity: 0.2,
                //   height: 60,
                //   child: Center(
                //     child: Text(
                //       currentlyCreatedWord,
                //       style: kStyle.copyWith(
                //         fontSize: 35,
                //         fontWeight: FontWeight.w700,
                //         color: Colors.black,
                //       ),
                //     ),
                //   ),
                // ),
// This is how you would modify your CrosswordBoardScreen to use the improved LetterConnector

// Find this section in the build method and replace it
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 30 + MediaQuery.of(context).padding.bottom,
                      top: 10,
                    ),
                    child: Stack(
                      children: [
                        if (lettersForTheBoard.isNotEmpty)
                          Center(
                            child: LetterConnector(
                              controller: _controller,
                              distanceOfLetters:
                                  100, // Adjusted for wooden circle style
                              letterSize:
                                  40, // Significantly increased for better touch detection
                              borderColor: Colors.white,
                              selectedColor: Colors.blue.shade500,
                              unselectedColor: Colors.blue.shade200,
                              lineColor: Colors.blue.shade600,
                              textStyle: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                              onSnap: (letterPosition) {
                                setState(() {
                                  currentlyCreatedWord += letterPosition.letter;
                                });
                                // You could add HapticFeedback.lightImpact() here if needed
                              },
                              onUnsnap: (letterPosition) {
                                setState(() {
                                  currentlyCreatedWord =
                                      currentlyCreatedWord.removeLast(1);
                                });
                              },
                              onCompleted: (word) {
                                _checkCreatedWord(word);
                              },
                              letters: lettersForTheBoard,
                              key: ValueKey(
                                lettersForTheBoard.last +
                                    lettersForTheBoard.first +
                                    lettersForTheBoard[1],
                              ),
                            ),
                          ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                lettersForTheBoard.shuffle();
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shuffle,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
