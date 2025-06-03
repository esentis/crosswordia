import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NOTE:
/// ▸ This file completely replaces your previous [CrosswordBoardScreen]
///   and brings a fresh, animated look using gradients, glass‑morphism,
///   expressive typography and micro‑interactions.
/// ▸ Requires **google_fonts** (already imported) and — optionally —
///   **lottie** if you want a confetti burst when a word is found.
/// ▸ Wherever you see the comment `// ✦` you can tweak colours / durations
///   to taste.

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

class _CrosswordBoardScreenState extends State<CrosswordBoardScreen>
    with TickerProviderStateMixin {
  late final CrosswordBoardController _controller;
  final LettersController _lettersController = LettersController();

  /// Animation that rotates the shuffle button each time it is pressed.
  late final AnimationController _shuffleSpin;

  @override
  void initState() {
    super.initState();

    _controller = CrosswordBoardController(
      words: widget.words,
      foundWords: widget.foundWords,
      level: widget.level,
      playerStatus: widget.playerStatus,
      userId: widget.userId,
    )
      ..addListener(_onControllerChange)
      ..initialize();

    _shuffleSpin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // ✦
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChange)
      ..dispose();
    _shuffleSpin.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _checkCreatedWord(List<String> word) async {
    final success = await _controller.checkCreatedWord(word);
    if (success) {
      _lettersController.triggerSuccessAnimation();

      // Optional: trigger confetti or haptic
      // HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 350)); // ✦
      _controller.shuffleLetters();
    } else {
      _lettersController.triggerErrorShake();
    }
  }

  Future<void> _onLetterTap(String position) async {
    if (_controller.canRevealLetter(position)) {
      await _controller.revealLetter(position);
    }
  }

  // ---------------------------------------------------------------------------
  //  BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0f2027), // ✦ dark blue‑black
              Color(0xFF203a43),
              Color(0xFF2c5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _BackgroundGlow(size: size),
              _buildBackButton(context),
              _buildTopBar(),
              _buildMainColumn(size),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      left: 16,
      top: 0,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTopBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 70,
              width: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  width: 1.2,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  'Level ${_controller.level}  •  Coins ${_controller.playerStatus.coins}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 5,
                          color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _buildGameBoard(),
        ),
        _buildLetterConnector(size),
      ],
    );
  }

  // ---------------- Game Board ----------------
  Widget _buildGameBoard() {
    return Center(
      child: SizedBox(
        width: 420,
        height: MediaQuery.of(context).size.height / 1.9,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          key: ValueKey(_controller.foundLetterPositions.hashCode),
          padding: const EdgeInsets.all(12),
          itemCount: CrosswordBoardController.boardRows *
              CrosswordBoardController.boardRows,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: CrosswordBoardController.boardRows,
          ),
          itemBuilder: (BuildContext context, int index) {
            final int row = (index ~/ CrosswordBoardController.boardRows) + 1;
            final int col = (index % CrosswordBoardController.boardRows) + 1;
            final currentPosition = '$row.$col';
            return _BoardCell(
              row: row,
              col: col,
              position: currentPosition,
              controller: _controller,
              onTap: _onLetterTap,
            );
          },
        ),
      ),
    );
  }

  // ---------------- Letter Connector ----------------

  Widget _buildLetterConnector(Size size) {
    return SizedBox(
      height: size.height * 0.26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_controller.lettersForTheBoard.isNotEmpty)
            LetterConnector(
              controller: _lettersController,
              distanceOfLetters: 92, // ✦
              letterSize: 42,
              borderColor: Colors.white.withValues(alpha: 0.7),
              selectedColor: const Color(0xFFffc93c),
              unselectedColor: const Color(0xFFFFE9A0),
              lineColor: Colors.black,
              textStyle: GoogleFonts.karla(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 1),
                    blurRadius: 5,
                  ),
                ],
              ),
              onSnap: (letterPosition) {
                _controller.addLetterToCurrentWord(letterPosition.letter);
              },
              onUnsnap: (letterPosition) {
                _controller.removeLastLetterFromCurrentWord();
              },
              onCompleted: _checkCreatedWord,
              letters: _controller.lettersForTheBoard,
              key: ValueKey(
                _controller.lettersForTheBoard.isNotEmpty
                    ? '${_controller.lettersForTheBoard.last}'
                        '${_controller.lettersForTheBoard.first}'
                        '${_controller.lettersForTheBoard.length > 1 ? _controller.lettersForTheBoard[1] : ""}'
                    : 'empty',
              ),
            ),
          _buildShuffleButton(),
        ],
      ),
    );
  }

  // ---------------- Shuffle Button ----------------
  Widget _buildShuffleButton() {
    return GestureDetector(
      onTap: () {
        _shuffleSpin
          ..reset()
          ..forward();
        _controller.shuffleLetters();
      },
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _shuffleSpin, curve: Curves.easeOutBack),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFffb338), Color(0xFFff7746)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              const Icon(Icons.shuffle_rounded, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

// ===========================================================================
//  PRIVATE WIDGETS
// ===========================================================================

/// A soft glowing radial gradient behind the content for subtle depth.
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GlowPainter(size),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.size);
  final Size size;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // Top left glow
    paint.color = const Color(0xFF00c6ff).withValues(alpha: 0.25); // ✦
    canvas.drawCircle(
        Offset(this.size.width * 0.1, this.size.height * 0.1), 140, paint);

    // Bottom right glow
    paint.color = const Color(0xFFff9a9e).withValues(alpha: 0.24); // ✦
    canvas.drawCircle(
        Offset(this.size.width * 0.9, this.size.height * 0.9), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
//  BOARD CELL
// ---------------------------------------------------------------------------
class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.row,
    required this.col,
    required this.position,
    required this.controller,
    required this.onTap,
  });

  final int row;
  final int col;
  final String position;
  final CrosswordBoardController controller;
  final Future<void> Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final String? letter = controller.getLetterAtPosition(position);
    final bool canReveal = controller.canRevealLetter(position);
    final bool isVisible = controller.isLetterVisible(position);
    final bool isRevealed = controller.isLetterRevealed(position);

    return GestureDetector(
      onTap: canReveal ? () => onTap(position) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // ✦
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: letter != null
              ? Colors.white.withValues(alpha: isRevealed ? 0.28 : 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: letter != null
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            scale: isVisible ? 1 : 0,
            child: Text(
              letter ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.firaMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: isRevealed ? 0.4 : 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
