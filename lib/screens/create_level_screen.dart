import 'package:crosswordia/core/constants/constants.dart';
import 'package:crosswordia/core/helpers/find_possible_words.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/services/levels_service.dart';
import 'package:flutter/material.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:uuid/uuid.dart';

class TestWordFindingAlgorithScreen extends StatefulWidget {
  const TestWordFindingAlgorithScreen({super.key});

  @override
  State<TestWordFindingAlgorithScreen> createState() =>
      _TestWordFindingAlgorithScreenState();
}

class _TestWordFindingAlgorithScreenState
    extends State<TestWordFindingAlgorithScreen> {
  Set<String> foundWords = {};
  final TextEditingController _charactersTextController =
      TextEditingController();

  final TextEditingController _levelNumberController = TextEditingController();

  LevelsService levelsService = LevelsService.instance;
  final uuid = const Uuid();

  Future<void> addLevel() async {
    final latestLevelId = await levelsService.getLatestLevelNumber();
    final level = Level(
      id: latestLevelId + 1,
      level: _levelNumberController.text.toInt()!,
      words: foundWords,
      letters: _charactersTextController.text.split(''),
    );

    kLog.f(level.toJson());
    levelsService.addLevel(level);

    kLog.i('Latest level id: $latestLevelId');
    // if (_levelNumberController.text.isEmpty) {
    //   kLog.e('Level number is empty');
    //   return Future.value();
    // }
    // if (_charactersTextController.text.isEmpty) {
    //   kLog.e('Characters are empty');
    //   return Future.value();
    // }
    // if (foundWords.isEmpty) {
    //   kLog.e('No words found');
    //   return Future.value();
    // }
    // return levelsService.addLevel(Level(
    //     level: _levelNumberController.text,
    //     words: foundWords.toList(),
    //     letters: _charactersTextController.text.split('').toList()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Create Level',
          style: kStyle,
        ),
      ),
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: kStyle.copyWith(
                      fontWeight: FontWeight.w100,
                      fontSize: 23,
                    ),
                    controller: _charactersTextController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      labelText: 'Enter characters',
                      labelStyle: kStyle.copyWith(
                        fontWeight: FontWeight.w100,
                        fontSize: 18,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final characters = _charactersTextController.text;
                      if (characters.isNotEmpty) {
                        // Find possible words using the characters
                        foundWords = findPossibleWords(characters, allWords);
                        kLog.f(
                            'Found ${foundWords.length} words for "$characters"');
                      }

                      setState(() {});
                    },
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Search in ',
                    style: kStyle.copyWith(
                      fontWeight: FontWeight.w100,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                          text: '${allWords.length} ',
                          style: kStyle.copyWith(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          )),
                      const TextSpan(
                          text: 'words the combination of characters')
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                Wrap(
                  children: foundWords.map((word) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Chip(
                        label: Text(
                          word,
                          style: kStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (foundWords.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Start typing characters to find words!',
                textAlign: TextAlign.center,
                style: kStyle.copyWith(
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 4.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Found words:  ',
                              style: kStyle,
                              children: [
                                TextSpan(
                                  text: foundWords.length.toString(),
                                  style: kStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Characters length:  ',
                              style: kStyle,
                              children: [
                                TextSpan(
                                  text: _charactersTextController.text.length
                                      .toString(),
                                  style: kStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          if (_charactersTextController.text.isNotEmpty)
                            RichText(
                              text: TextSpan(
                                text: 'Characters:  ',
                                style: kStyle,
                                children: [
                                  TextSpan(
                                    text: _charactersTextController.text
                                        .split('')
                                        .join(', '),
                                    style: kStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _levelNumberController,
                              onChanged: (v) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hint: Text(
                                  'The number of the level is required',
                                  style: kStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                kLog.i('Create level with these words');
                                addLevel();
                              },
                              child: Container(
                                width: 300,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: !_levelNumberController.text.isNumber
                                      ? Colors.grey[400]
                                      : Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    'Create level',
                                    textAlign: TextAlign.center,
                                    style: kStyle.copyWith(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
