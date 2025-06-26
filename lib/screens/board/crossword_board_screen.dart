import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  /// Animation for found words overlay
  late final AnimationController _overlayController;
  late final Animation<double> _overlayAnimation;
  bool _showFoundWords = false;

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
    
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChange)
      ..dispose();
    _shuffleSpin.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }
  
  void _toggleFoundWordsOverlay() {
    setState(() {
      _showFoundWords = !_showFoundWords;
    });
    
    if (_showFoundWords) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
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
              _FloatingParticles(size: size),
              _buildBackButton(context),
              _buildTopBar(),
              _buildMainColumn(size),
              if (_showFoundWords) _buildFoundWordsOverlay(),
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
        child: GestureDetector(
          onTap: _toggleFoundWordsOverlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_showFoundWords ? 1.05 : 1.0),
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
                      colors: _showFoundWords
                          ? [
                              const Color(0xFFffc93c).withValues(alpha: 0.3),
                              const Color(0xFFffc93c).withValues(alpha: 0.1),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      width: 1.2,
                      color: _showFoundWords
                          ? const Color(0xFFffc93c).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                    boxShadow: _showFoundWords
                        ? [
                            BoxShadow(
                              color: const Color(0xFFffc93c).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
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
                            const SizedBox(width: 8),
                            Icon(
                              _showFoundWords ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _toggleFoundWordsOverlay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _showFoundWords
                                  ? const Color(0xFFffc93c).withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                                '${_controller.totalFoundWordsOfLevel.length} of ${_controller.allPlacedWords.length} placed words • ${_controller.totalWordsOfLevel.length} total',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.karla(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _showFoundWords ? Colors.white : Colors.white70,
                                )),
                          ),
                        ),
                      ],
                    ),
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
      child: Container(
        width: 420,
        height: MediaQuery.of(context).size.height / 1.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                key: ValueKey(_controller.foundLetterPositions.hashCode),
                padding: const EdgeInsets.all(16),
                itemCount: CrosswordBoardController.boardRows *
                    CrosswordBoardController.boardRows,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: CrosswordBoardController.boardRows,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final int row =
                      (index ~/ CrosswordBoardController.boardRows) + 1;
                  final int col =
                      (index % CrosswordBoardController.boardRows) + 1;
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
          ),
        ),
      ),
    );
  }

  // ---------------- Letter Connector ----------------

  Widget _buildLetterConnector(Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: 17.0 + MediaQuery.paddingOf(context).bottom),
      child: SizedBox(
        height: size.height * 0.26,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (_controller.lettersForTheBoard.isNotEmpty)
              LetterConnector(
                controller: _lettersController,
                letterStyle: LetterStyle.circle,
                distanceOfLetters: 92,
                letterSize: 42,
                borderColor: Colors.white.withValues(alpha: 0.7),
                selectedColor: const Color(0xFFffc93c),
                unselectedColor: const Color(0xFFFFE9A0),
                lineColor: const Color(0xFFffc93c),
                textStyle: GoogleFonts.karla(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2c5364),
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

  Widget _buildFoundWordsOverlay() {
    final foundPlacedWords = _controller.totalFoundWordsOfLevel
        .where((word) => _controller.allPlacedWords.contains(word))
        .toList();
    final foundOtherWords = _controller.totalFoundWordsOfLevel
        .where((word) => !_controller.allPlacedWords.contains(word))
        .toList();
    
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Positioned(
          top: 85 + (20 * (1 - _overlayAnimation.value)),
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Transform.scale(
            scale: 0.8 + (0.2 * _overlayAnimation.value),
            child: Opacity(
              opacity: _overlayAnimation.value,
              child: GestureDetector(
                onTap: _toggleFoundWordsOverlay,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.15),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFffc93c).withValues(alpha: 0.3),
                                  const Color(0xFFffc93c).withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Found Words',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        const Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  '${_controller.totalFoundWordsOfLevel.length}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFffc93c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Content
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (foundPlacedWords.isNotEmpty) ...[
                                    _buildWordSection(
                                      'Placed on Board',
                                      foundPlacedWords,
                                      const Color(0xFF4CAF50),
                                      Icons.grid_on,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (foundOtherWords.isNotEmpty) 
                                    _buildWordSection(
                                      'Bonus Words',
                                      foundOtherWords,
                                      const Color(0xFF2196F3),
                                      Icons.star_outline,
                                    ),
                                  if (_controller.totalFoundWordsOfLevel.isEmpty)
                                    Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            size: 48,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No words found yet',
                                            style: GoogleFonts.karla(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Tap anywhere to close',
                              style: GoogleFonts.karla(
                                fontSize: 12,
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildWordSection(String title, List<String> words, Color accentColor, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${words.length}',
                style: GoogleFonts.karla(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.map((word) => _buildWordChip(word, accentColor)).toList(),
        ),
      ],
    );
  }
  
  Widget _buildWordChip(String word, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        word,
        style: GoogleFonts.karla(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
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

/// Subtle floating particles for ambient animation
class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles({required this.size});
  final Size size;

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  static const int particleCount = 8;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      particleCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 8000 + (index * 500)),
        vsync: this,
      ),
    );

    _animations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Tween<Offset>(
        begin: Offset(
          (index * 0.15) * widget.size.width,
          widget.size.height + 20,
        ),
        end: Offset(
          (index * 0.15) * widget.size.width + 50,
          -50,
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 1000), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: _animations.asMap().entries.map((entry) {
            final index = entry.key;
            final animation = entry.value;
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Positioned(
                  left: animation.value.dx,
                  top: animation.value.dy,
                  child: Container(
                    width: 4 + (index % 3),
                    height: 4 + (index % 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: 0.1 + (index % 2) * 0.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  BOARD CELL
// ---------------------------------------------------------------------------
class _BoardCell extends StatefulWidget {
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
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final String? letter =
        widget.controller.getLetterAtPosition(widget.position);
    final bool canReveal = widget.controller.canRevealLetter(widget.position);
    final bool isVisible = widget.controller.isLetterVisible(widget.position);
    final bool isRevealed = widget.controller.isLetterRevealed(widget.position);
    final bool hasLetter = letter != null;

    // Start pulsing animation for revealable letters
    if (canReveal && !isVisible) {
      _startPulse();
    } else {
      _stopPulse();
    }

    return GestureDetector(
      onTapDown: canReveal ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: canReveal ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: canReveal ? () => setState(() => _isPressed = false) : null,
      onTap: canReveal ? () => widget.onTap(widget.position) : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : 1.0)
              ..translate(0.0, _isPressed ? 2.0 : 0.0),
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasLetter
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: _isPressed ? 4 : 8,
                        offset: Offset(0, _isPressed ? 1 : 3),
                      ),
                      if (canReveal && !isVisible)
                        BoxShadow(
                          color: const Color(0xFFffc93c).withValues(
                            alpha: 0.3 + (_pulseAnimation.value * 0.3),
                          ),
                          blurRadius: 12 + (_pulseAnimation.value * 8),
                        ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: hasLetter ? 8 : 0,
                  sigmaY: hasLetter ? 8 : 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: hasLetter
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isRevealed
                                ? [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.2),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.9),
                                    Colors.white.withValues(alpha: 0.7),
                                  ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: hasLetter
                        ? Border.all(
                            color: isRevealed
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          )
                        : canReveal
                            ? Border.all(
                                color: const Color(0xFFffc93c).withValues(
                                  alpha: 0.4 + (_pulseAnimation.value * 0.4),
                                ),
                                width: 2,
                              )
                            : null,
                  ),
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      scale: isVisible ? 1 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isVisible ? 1 : 0,
                        child: Text(
                          letter ?? '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isRevealed
                                ? Colors.white.withValues(alpha: 0.6)
                                : const Color(0xFF2c5364),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
