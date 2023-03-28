import 'dart:io';

import 'package:crosswordia/board/helpers/horizontal_check.dart';
import 'package:crosswordia/board/helpers/vertical_check.dart';
import 'package:crosswordia/board/letter_connector.dart';
import 'package:crosswordia/constants.dart';
import 'package:crosswordia/helper.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:string_extensions/string_extensions.dart';

void saveTextToFile(String text) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('/storage/emulated/0/Download/greek_words.txt');
  final res = await file.writeAsString(text);
  print(res);
}

extension Misc on String {
  bool hasUniqueCharacters() {
    final word = this;
    final wordSplit = word.toGreekUpperCase()!.split('').toSet();
    return word.length == wordSplit.length;
  }

  String findCommonCharacters(String otherString) {
    final Set<String> commonLettersSet = {};
    final Set<String> otherStringSet = otherString.split('').toSet();

    for (final letter in split('')) {
      if (otherStringSet.contains(letter)) {
        commonLettersSet.add(letter);
      }
    }

    final List<String> commonLettersList = commonLettersSet.toList();
    commonLettersList.sort();

    return commonLettersList.join('');
  }

  int countUncommonCharacters(String other) {
    final thisSet = getCharSet(this);
    final otherSet = getCharSet(other);

    final uncommonSet = thisSet.length > otherSet.length
        ? (thisSet.difference(otherSet))
        : (otherSet.difference(thisSet));

    return uncommonSet.length;
  }

  Set<String> getUncommonCharacters(String other) {
    final thisSet = getCharSet(this);
    final otherSet = getCharSet(other);

    final uncommonSet = (thisSet.difference(otherSet));

    return uncommonSet;
  }

  /// Returns the unique letters of the word
  Set<String> getCharSet(String str) {
    final set = <String>{};
    for (final char in str.split('')..sort()) {
      set.add(char);
    }
    return set;
  }

  /// Returns true if the String contains all the characters of the wordToCheck
  bool containsAllCharacters(
      String wordUpperAndSorted, String wordToCheckUpperAndSortedJoined) {
    final Map<String, int> letterCounts = {};

    wordUpperAndSorted.split('').forEach((letter) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    });

    for (final letter in wordToCheckUpperAndSortedJoined.split('')) {
      if (letterCounts[letter] == null || letterCounts[letter]! <= 0) {
        return false;
      }
      letterCounts[letter] = letterCounts[letter]! - 1;
    }

    return true;
  }
}

class CrossWordBoard extends StatefulWidget {
  const CrossWordBoard({
    super.key,
  });

  @override
  State<CrossWordBoard> createState() => _CrossWordBoardState();
}

class _CrossWordBoardState extends State<CrossWordBoard> {
  List<List<String>> board = [];
  Set<String> placedWords = {};

  List<String> lettersForTheBoard = [];
  Set<String> revealedLetterPositions = {};

  Map<String, List<String>> letterPositions = {};
  Map<String, List<String>> foundLetterPositions = {};
  Map<String, List<String>> wordPositions = {};

  Map<String, Set<String>> groupedWords = {};

  /// Checks if the List a is a subset of List b
  bool isSubset(List<String> a, List<String> b) {
    int i = 0, j = 0;

    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
      }
      j++;
    }

    return i == a.length;
  }

  void filterWords() {
    groupedWords = {};
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

    for (final word in wordsToLook) {
      if (word.length >= 3 && word.length <= 5) {
        final wordSlicedAndSorted = word.toGreekUpperCase()!.split('')..sort();
        final String wordUpperAndSorted = wordSlicedAndSorted.join();

        groupedWords.putIfAbsent(wordUpperAndSorted, () => <String>{});
        groupedWords[wordUpperAndSorted]!.add(word);
      }
    }

    for (final key in groupedWords.keys) {
      final keyChars = key.split('');
      for (final wordToCheck in wordsToLook) {
        if (wordToCheck.length >= 3 && wordToCheck.length <= 6) {
          final wordToCheckSlicedAndSorted =
              wordToCheck.toGreekUpperCase()!.split('')..sort();
          final String wordToCheckUpperAndSorted =
              wordToCheckSlicedAndSorted.join();

          if (isSubset(wordToCheckUpperAndSorted.split(''), keyChars)) {
            groupedWords[key]!.add(wordToCheck);
          }
        }
      }
    }
    // for (final word in wordsToLook) {
    //   if (word.length >= 3 && word.length <= 7) {
    //     final wordSlicedAndSorted = word.toGreekUpperCase()!.split('')..sort();
    //     final String wordUpperAndSorted = wordSlicedAndSorted.join();

    //     groupedWords.putIfAbsent(wordUpperAndSorted, () => <String>{});
    //     groupedWords[wordUpperAndSorted]!.add(word);

    //     for (final wordToCheck in wordsToLook) {
    //       if (wordToCheck.length >= 3 && wordToCheck.length <= 6) {
    //         final wordToCheckSlicedAndSorted =
    //             wordToCheck.toGreekUpperCase()!.split('')..sort();
    //         final String wordToCheckUpperAndSorted =
    //             wordToCheckSlicedAndSorted.join();

    //         if (wordUpperAndSorted
    //             .containsAll(wordToCheckUpperAndSorted.split(''))) {
    //           groupedWords[wordUpperAndSorted]!.add(wordToCheck);
    //         }
    //       }
    //     }
    //   }
    // }
    kLog.wtf(groupedWords);
  }

  Set<String> testWords = {
    "τσίμα",
    "τσάι",
    "τάσι",
    "στια",
    "σιμά",
    "ματς",
    "μάτι",
    "τιμ",
    "άτι",
    "ίσα",
    "σία",
    "ματ",
    "μις",
    "μία",
    "στα",
    "μας"
  };

  void _placeWord({
    required String row,
    required String col,
    required String word,
    required bool isHorizontal,
    required int startingPoint,
  }) {
    kLog.i('adding word $word ${isHorizontal ? 'horizontally' : 'vertically'}');
    placedWords.add(word);
    int rowInt = int.parse(row);
    int colInt = int.parse(col);

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

  // Generate board based on [words]
  void _generatedBoard() {
    // find longest word in [words]
    List<String> sortedWords = testWords
        .toSet()
        .where((element) => element.length <= 10 && element.length >= 3)
        .map(
          (e) => e.toGreekUpperCase()!,
        )
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    letterPositions = {};

    List<String> words = [];
    // while (words.length < 4) {
    //   final int random = Random().nextInt(sortedWords.length);

    //   if (words.contains(sortedWords[random])) {
    //     continue;
    //   }
    //   words.add(sortedWords[random]);
    // }

    words.addAll(sortedWords);

    kLog.wtf(words);

    words.sort((a, b) => b.length.compareTo(a.length));
    for (var i = 0; i < words.length; i++) {
      if (i == 0) {
        // We calculate the approxiate middle of the board to put the first word
        int startAfter = (((10 - words[i].length) / 2) + 1).ceil();
        _placeWord(
          row: '6',
          col: '$startAfter',
          word: words[i],
          isHorizontal: true,
          startingPoint: startAfter,
        );
      } else {
        final wordSplit = words[i].split('');
        final word = words[i];
        letterLoop:
        for (int i = 0; i < wordSplit.length; i++) {
          final foundLocations = letterPositions[wordSplit[i]];
          final letter = wordSplit[i];
          // if (word == 'ΑΦΕ')
          //   kLog.wtf('letter $letter\nFound locations $foundLocations');
          // If we found an intersection
          if (foundLocations != null) {
            for (final location in foundLocations) {
              // The row and column of the found letter
              final String row = location.before('.')!;
              final String col = location.after('.')!;

              final int rowInt = int.parse(row);
              final int colInt = int.parse(col);

              // Those are the spaces from the found letter to the edge of the board
              // We use them to check if the word can be placed, ignoring if there are other words
              final spaceFromLeft = colInt;
              final spaceFromRight = 10 - colInt;
              final spaceFromTop = rowInt;
              final spaceFromBottom = 10 - rowInt;

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

              if (word == 'ΤΡΙΟ' &&
                  actualVerticalStartingLocationIfAvailable == '8.3') {
                kLog.wtf('''
distance from left of letter $distanceFromLeftOfLetter
distance from right of letter $distanceFromRightOfLetter
distance from top of letter $dinstanceFromTopOfLetter
distance from bottom of letter $distanceFromBottomOfLetter
space from left $spaceFromLeft
space from right $spaceFromRight
space from top $spaceFromTop
space from bottom $spaceFromBottom
''');
              }

              // final actualHorizontalBeforeStartingLocationIfAvailable =
              //     '$rowInt.${colInt - distanceFromLeftOfLetter - 1}';

              // final actualHorizontalAfterEndingLocationIfAvailable =
              //     '$rowInt.${colInt + distanceFromRightOfLetter + 1}';

              // Check if the word can be placed vertically
              final bool canStartVerticallyWithThatLetter = canStartVertically(
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
                      .before('.')!
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
                      .after('.')!
                      .toInt()!,
                );
                break letterLoop;
              }
            }
          }
        }
      }
    }
    // kLog.wtf(placedWords);

    _generateLettersForConnector();
  }

  /// Generates the letters for the connector
  /// keeps the max number of repeated letters in the words
  /// for example if a word has 3 "A" three "A"s will be present in the connector
  void _generateLettersForConnector() {
    // find repeated letters and their count
    Map<String, int> repeatedLetters = {};

    List<String> extraLettersToAdd = [];

    for (final word in placedWords) {
      // kLog.i('Char occurences for word $word\n${word.charOccurences}');
      for (Map<String, int> charOcc in word.charOccurences) {
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
      ...extraLettersToAdd
    ]..shuffle();
  }

  String createdWord = '';
  @override
  void initState() {
    super.initState();

    _generatedBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: SizedBox(
                width: 350,
                height: MediaQuery.of(context).size.height / 1.9,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  key: ValueKey(foundLetterPositions.hashCode),
                  padding: const EdgeInsets.all(10),
                  itemCount: 10 * 10,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    int row = (index ~/ 10) + 1;
                    int col = (index % 10) + 1;

                    final currentPosition = '$row.$col';

                    final Map<String, dynamic> letterFound =
                        letterPositions.whereValue(
                            (letters) => letters.contains(currentPosition));

                    return GestureDetector(
                      onTap: () {
                        if (letterFound.isNotEmpty) {
                          setState(() {
                            revealedLetterPositions.add(currentPosition);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: letterFound.isNotEmpty
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: letterFound.isNotEmpty
                                ? Border.all(
                                    color: Colors.black,
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
                                  ? foundLetterPositions.values.any((element) =>
                                              element.contains("$row.$col")) ||
                                          revealedLetterPositions
                                              .contains("$row.$col")
                                      ? letterFound.keys.first.toUpperCase()
                                      : ""
                                  : "$row|$col\n${index + 1}",
                              style: TextStyle(
                                color: letterFound.isNotEmpty
                                    ? Colors.black
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
            TextButton(
              onPressed: () {
                //  kLog.wtf('Αγία'.hasUniqueCharacters());
                //   filterWords();
                // kLog.wtf(words2
                //     .where((element) =>
                //         element.toGreekUpperCase()!.hasUniqueCharacters())
                //     .toList());
                // kLog.wtf(groupedWords);
                // kLog.wtf(mergeMap(groupedWords));
                // kLog.wtf('abcd'.countUncommonLetters('abcdeef'));
                // kLog.wtf(
                //   filterWords(
                //     allWs.map((e) => e.toGreekUpperCase()!).toList(),
                //     ['Α', 'Τ', 'Ε', 'Σ', 'Ο', 'Ρ'],
                //   ),
                // );
              },
              child: Text('try'),
            ),
            Text(
              'WORD: $createdWord',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 10 + MediaQuery.of(context).padding.bottom,
                top: 10,
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  children: [
                    Center(
                      child: LetterConnector(
                        letterStyle: LetterStyle.circle,
                        distanceOfLetters: 80,
                        onLetterSelected: (letter) {
                          setState(() {
                            createdWord += letter;
                          });
                        },
                        onUnsnap: () {
                          setState(() {
                            createdWord = createdWord.removeLast(1)!;
                          });
                        },
                        onCompleted: (word) {
                          setState(() {
                            createdWord = '';
                          });
                          final joinedWord = word.join();
                          kLog.wtf('$word joined word: $joinedWord');
                          // Search for the word in the wordPositions map
                          final MapEntry<String, List<String>> wordFound =
                              wordPositions.entries.firstWhere(
                            (element) => element.key == joinedWord,
                            orElse: () => const MapEntry(
                              '',
                              [],
                            ),
                          );

                          kLog.wtf('word found ? ${wordFound.key != ''}');
                          setState(() {
                            createdWord = '';
                            if (wordFound.key != '') {
                              foundLetterPositions.addAll(
                                Map.fromEntries([wordFound]),
                              );

                              kLog.wtf(foundLetterPositions);
                            }
                          });
                        },
                        letters: lettersForTheBoard,
                        key: ValueKey(lettersForTheBoard.last +
                            lettersForTheBoard.first +
                            lettersForTheBoard[1]),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            lettersForTheBoard.shuffle();
                          });
                        },
                        child: Icon(
                          Icons.shuffle,
                          size: 50,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
