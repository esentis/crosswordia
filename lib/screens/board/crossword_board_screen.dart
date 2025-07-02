import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/found_words_overlay.dart';
import 'package:crosswordia/screens/board/widgets/game_board.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector_section.dart';
import 'package:crosswordia/screens/board/widgets/top_bar.dart';
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
              TopBar(
                controller: _controller,
                showFoundWords: _showFoundWords,
                onToggleFoundWords: _toggleFoundWordsOverlay,
              ),
              _buildMainColumn(size),
              if (_showFoundWords)
                FoundWordsOverlay(
                  controller: _controller,
                  animation: _overlayAnimation,
                  onClose: _toggleFoundWordsOverlay,
                ),
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

  Widget _buildMainColumn(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: GameBoard(
            controller: _controller,
            onLetterTap: _onLetterTap,
          ),
        ),
        LetterConnectorSection(
          controller: _controller,
          lettersController: _lettersController,
          onCompleted: _checkCreatedWord,
          onShuffleTap: () {
            _shuffleSpin
              ..reset()
              ..forward();
            _controller.shuffleLetters();
          },
          shuffleAnimation: _shuffleSpin,
        ),
      ],
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
