import 'package:crosswordia/core/constants/constants.dart';
import 'package:crosswordia/core/helpers/find_possible_words.dart';
import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';

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
  late CrosswordBoardController _controller;
  final LettersController _lettersController = LettersController();

  @override
  void initState() {
    super.initState();
    _controller = CrosswordBoardController(
      words: widget.words,
      foundWords: widget.foundWords,
      level: widget.level,
      playerStatus: widget.playerStatus,
      userId: widget.userId,
    );
    _controller.addListener(_onControllerChange);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkCreatedWord(List<String> word) async {
    final success = await _controller.checkCreatedWord(word);

    if (success) {
      _lettersController.triggerSuccessAnimation();
      // Add delay for animation
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.shuffleLetters();
      });
    } else {
      _lettersController.triggerErrorShake();
    }
  }

  Future<void> _onLetterTap(String position) async {
    if (_controller.canRevealLetter(position)) {
      await _controller.revealLetter(position);
    }
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
                    'Level ${_controller.level}\nScore ${_controller.playerStatus.coins}',
                    style: kStyle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                TextButton(
                  onPressed: () {
                    findPossibleWords('εφημερίδα', _controller.wordsToLook);
                  },
                  child: const Text('try'),
                ),
                _buildGameBoard(),
                _buildLetterConnector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: SizedBox(
        width: 420,
        height: MediaQuery.of(context).size.height / 1.9,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          key: ValueKey(_controller.foundLetterPositions.hashCode),
          padding: const EdgeInsets.all(10),
          itemCount: CrosswordBoardController.boardRows *
              CrosswordBoardController.boardRows,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: CrosswordBoardController.boardRows,
          ),
          itemBuilder: (BuildContext context, int index) {
            final int row = (index ~/ CrosswordBoardController.boardRows) + 1;
            final int col = (index % CrosswordBoardController.boardRows) + 1;
            final currentPosition = '$row.$col';

            return _buildBoardCell(row, col, currentPosition);
          },
        ),
      ),
    );
  }

  Widget _buildBoardCell(int row, int col, String position) {
    final letter = _controller.getLetterAtPosition(position);
    final canReveal = _controller.canRevealLetter(position);
    final isVisible = _controller.isLetterVisible(position);
    final isRevealed = _controller.isLetterRevealed(position);

    return GestureDetector(
      onTap: canReveal ? () => _onLetterTap(position) : null,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: letter != null
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: letter != null
                ? Border.all(
                    color: Colors.blue.withValues(alpha: 0.4),
                    width: 2,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              letter != null
                  ? isVisible
                      ? letter
                      : ""
                  : "$row|$col\n${(row - 1) * CrosswordBoardController.boardRows + col}",
              style: kStyle.copyWith(
                color: letter != null
                    ? isRevealed
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black
                    : Colors.transparent,
                fontSize: letter != null ? 20 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterConnector() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 30 + MediaQuery.of(context).padding.bottom,
          top: 10,
        ),
        child: Stack(
          children: [
            if (_controller.lettersForTheBoard.isNotEmpty)
              Center(
                child: LetterConnector(
                  controller: _lettersController,
                  distanceOfLetters: 100,
                  letterSize: 40,
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
                    _controller.addLetterToCurrentWord(letterPosition.letter);
                  },
                  onUnsnap: (letterPosition) {
                    _controller.removeLastLetterFromCurrentWord();
                  },
                  onCompleted: (word) {
                    _checkCreatedWord(word);
                  },
                  letters: _controller.lettersForTheBoard,
                  key: ValueKey(
                    _controller.lettersForTheBoard.isNotEmpty
                        ? '${_controller.lettersForTheBoard.last}'
                            '${_controller.lettersForTheBoard.first}'
                            '${_controller.lettersForTheBoard.length > 1 ? _controller.lettersForTheBoard[1] : ""}'
                        : 'empty',
                  ),
                ),
              ),
            _buildShuffleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShuffleButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _controller.shuffleLetters();
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
    );
  }
}
