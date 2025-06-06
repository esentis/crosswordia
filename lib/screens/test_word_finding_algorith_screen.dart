import 'package:crosswordia/core/constants/constants.dart';
import 'package:crosswordia/core/helpers/find_possible_words.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Word Finding Algorithm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _charactersTextController,
                    decoration: const InputDecoration(
                      labelText: 'Enter characters',
                      border: OutlineInputBorder(),
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
                Wrap(
                  children: foundWords.map((word) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Chip(
                        label: Text(word),
                      ),
                    );
                  }).toList(),
                ),
                if (foundWords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Start typing characters to find words!',
                      style: kStyle,
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Found words: ',
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: [
                        TextSpan(
                          text: foundWords.length.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Characters length: ',
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: [
                        TextSpan(
                          text:
                              _charactersTextController.text.length.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (_charactersTextController.text.isNotEmpty)
                    RichText(
                      text: TextSpan(
                        text: 'Characters: ',
                        style: Theme.of(context).textTheme.headlineMedium,
                        children: [
                          TextSpan(
                            text: _charactersTextController.text
                                .split('')
                                .join(', '),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
