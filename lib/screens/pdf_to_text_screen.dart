import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfConverterScreen extends StatefulWidget {
  const PdfConverterScreen({super.key});

  @override
  State<PdfConverterScreen> createState() => _PdfConverterScreenState();
}

class _PdfConverterScreenState extends State<PdfConverterScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  String _status = 'Ready to convert PDF';
  String _extractedText = '';
  String? _savedFilePath;
  double _progress = 0.0;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isCancelled = false;
  DateTime? _startTime;
  String _estimatedTimeRemaining = '';
  List<String> _wordList = [];
  String? _wordListFilePath;
  late TabController _tabController;
  bool _showUniqueWords = true;
  List<String> _allWords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _convertPdfToTxt() async {
    setState(() {
      _isProcessing = true;
      _status = 'Loading PDF from assets...';
      _extractedText = '';
      _savedFilePath = null;
      _progress = 0.0;
      _currentPage = 0;
      _totalPages = 0;
      _isCancelled = false;
      _estimatedTimeRemaining = '';
      _wordList = [];
      _allWords = [];
      _wordListFilePath = null;
    });

    try {
      // Load PDF from assets
      final ByteData data = await rootBundle.load('assets/babiniotis.pdf');
      final Uint8List bytes = data.buffer.asUint8List();

      setState(() {
        _status = 'Opening PDF document...';
      });

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      setState(() {
        _totalPages = document.pages.count;
        _status = 'Starting text extraction from $_totalPages pages...';
        _startTime = DateTime.now();
      });

      // Extract text line by line
      final StringBuffer textBuffer = StringBuffer();
      final List<String> allLines = [];

      // Iterate through all pages
      for (int i = 0; i < document.pages.count; i++) {
        // Check if cancelled
        if (_isCancelled) {
          document.dispose();
          setState(() {
            _isProcessing = false;
            _status = 'Conversion cancelled';
            _progress = 0.0;
            _estimatedTimeRemaining = '';
          });
          return;
        }

        setState(() {
          _currentPage = i + 1;
          _progress = (i + 1) / document.pages.count;
          _status = 'Processing page $_currentPage of $_totalPages...';

          // Calculate estimated time remaining
          if (_startTime != null && i > 0) {
            final elapsed = DateTime.now().difference(_startTime!);
            final avgTimePerPage = elapsed.inMilliseconds / (i + 1);
            final remainingPages = document.pages.count - (i + 1);
            final remainingMs = (avgTimePerPage * remainingPages).round();
            final remainingDuration = Duration(milliseconds: remainingMs);

            if (remainingDuration.inMinutes > 0) {
              _estimatedTimeRemaining =
                  '${remainingDuration.inMinutes}m ${remainingDuration.inSeconds % 60}s remaining';
            } else {
              _estimatedTimeRemaining =
                  '${remainingDuration.inSeconds}s remaining';
            }
          }
        });

        // Extract text from the page
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText =
            extractor.extractText(startPageIndex: i, endPageIndex: i);

        // Split into lines and add to our list
        final List<String> pageLines = pageText.split('\n');
        for (final String line in pageLines) {
          final String trimmedLine = line.trim();
          if (trimmedLine.isNotEmpty) {
            allLines.add(trimmedLine);
            textBuffer.writeln(trimmedLine);
          }
        }

        // Add a small delay to allow UI to update
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Update extracted text for preview
      setState(() {
        _extractedText = textBuffer.toString();
        _status = 'Extracting Greek words...';
      });

      // Extract all words
      _wordList = _extractWords(textBuffer.toString());

      setState(() {
        _status = 'Saving files...';
      });

      // Get the documents directory
      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Save full text file
      final String textFileName = 'extracted_text_$timestamp.txt';
      final File textFile = File('${directory.path}/$textFileName');
      await textFile.writeAsString(textBuffer.toString());

      // Save word list file with Dart List format
      final String wordListFileName = 'greek_word_list_$timestamp.txt';
      final File wordListFile = File('${directory.path}/$wordListFileName');

      // Format as Dart List<String>
      final String uniqueWordsAsDartList =
          _formatAsDartList(_wordList, 'uniqueGreekWords');
      final String allWordsAsDartList =
          _formatAsDartList(_allWords, 'allGreekWords');

      await wordListFile.writeAsString(
          'UNIQUE GREEK WORDS AS DART LIST (${_wordList.length} words):\n\n$uniqueWordsAsDartList\n\n${'=' * 80}\n\nALL GREEK WORDS AS DART LIST (${_allWords.length} words):\n\n$allWordsAsDartList');

      // Dispose the document
      document.dispose();

      setState(() {
        _isProcessing = false;
        _status = 'Conversion complete!';
        _savedFilePath = textFile.path;
        _wordListFilePath = wordListFile.path;
        _estimatedTimeRemaining = '';
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Extracted ${_allWords.length} Greek words (${_wordList.length} unique)'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
        _estimatedTimeRemaining = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _cancelConversion() {
    setState(() {
      _isCancelled = true;
    });
  }

  List<String> _extractWords(String text) {
    // Clear previous words
    _allWords.clear();

    // First, clean the text and split into potential words
    // Using multiple delimiters for better word separation
    final List<String> potentialWords = text
        .replaceAll(RegExp('[0-9]+'), ' ') // Remove numbers
        .replaceAll(RegExp(r'[^\u0370-\u03FF\u1F00-\u1FFF\s]+'),
            ' ') // Keep only Greek chars and spaces
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim()
        .split(' ');

    // Process each potential word
    for (final String word in potentialWords) {
      // Clean the word by keeping only Greek characters
      final String cleanWord =
          word.replaceAll(RegExp(r'[^\u0370-\u03FF\u1F00-\u1FFF]'), '').trim();

      // Skip if the cleaned word is too short
      if (cleanWord.length < 3) continue;

      // Add to all words list
      _allWords.add(cleanWord);
    }

    // Create unique words list while preserving order
    final Set<String> uniqueWords = {};
    final List<String> orderedUniqueWords = [];

    for (final String word in _allWords) {
      if (uniqueWords.add(word)) {
        orderedUniqueWords.add(word);
      }
    }

    return orderedUniqueWords;
  }

  String _formatAsDartList(List<String> words, String variableName) {
    if (words.isEmpty) {
      return 'final List<String> $variableName = [];';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('final List<String> $variableName = [');

    for (int i = 0; i < words.length; i++) {
      final String word = words[i];
      final String escapedWord =
          word.replaceAll("'", "\\'").replaceAll('\\', '\\\\');

      if (i == words.length - 1) {
        buffer.writeln("  '$escapedWord',");
      } else {
        buffer.writeln("  '$escapedWord',");
      }
    }

    buffer.writeln('];');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to TXT Converter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isProcessing
                          ? Icons.hourglass_empty
                          : Icons.picture_as_pdf,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (_isProcessing && _totalPages > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_progress * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (_estimatedTimeRemaining.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Text(
                              _estimatedTimeRemaining,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (_savedFilePath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Text saved to: ${_savedFilePath!.split('/').last}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      if (_wordListFilePath != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Greek words saved to: ${_wordListFilePath!.split('/').last}',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar:
                              const Icon(Icons.format_list_numbered, size: 18),
                          label: Text(
                              '${_wordList.length} unique Greek words found'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _convertPdfToTxt,
              icon: const Icon(Icons.transform),
              label:
                  Text(_isProcessing ? 'Processing...' : 'Convert PDF to TXT'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _cancelConversion,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_extractedText.isNotEmpty) ...[
              TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Extracted Text'),
                  Tab(text: 'Greek Words (${_allWords.length})'),
                  const Tab(text: 'Dart List Format'), // New tab
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Text preview tab
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _extractedText,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
                    // Word list tab
                    Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Greek Words: ${_allWords.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      'Unique Greek Words: ${_wordList.length}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SegmentedButton<bool>(
                                      segments: const [
                                        ButtonSegment<bool>(
                                          value: true,
                                          label: Text('Unique'),
                                        ),
                                        ButtonSegment<bool>(
                                          value: false,
                                          label: Text('All'),
                                        ),
                                      ],
                                      selected: {_showUniqueWords},
                                      onSelectionChanged:
                                          (Set<bool> newSelection) {
                                        setState(() {
                                          _showUniqueWords = newSelection.first;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children:
                                      (_showUniqueWords ? _wordList : _allWords)
                                          .map((word) => Chip(
                                                label: Text(word),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ))
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
