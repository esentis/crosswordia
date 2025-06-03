// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;

import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/board/crossword_board_screen.dart';
import 'package:crosswordia/services/levels_service.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseLevelScreen extends StatefulWidget {
  const ChooseLevelScreen({
    required this.levelCount,
    required this.playerStatus,
    super.key,
  });

  final int levelCount;
  final PlayerStatus playerStatus;

  @override
  State<ChooseLevelScreen> createState() => _ChooseLevelScreenState();
}

class _ChooseLevelScreenState extends State<ChooseLevelScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pathAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;
  late ScrollController _scrollController;

  // Track hover states
  final Map<int, bool> _hoveredLevels = {};

  // Constants
  static const double _levelSize = 80.0;
  static const double _pathWidth = 400.0;
  static const double _verticalSpacing = 120.0;

  @override
  void initState() {
    super.initState();

    _pathAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // _floatingAnimationController = AnimationController(
    //   duration: const Duration(seconds: 3),
    //   vsync: this,
    // )..repeat(reverse: true);

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    // Scroll to current level after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    final currentLevelIndex = widget.playerStatus.currentLevel - 1;
    final scrollPosition = currentLevelIndex * _verticalSpacing - 200;

    _scrollController.animateTo(
      scrollPosition.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pathAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Get level status
  LevelStatus _getLevelStatus(int level) {
    if (level < widget.playerStatus.currentLevel) {
      return LevelStatus.completed;
    } else if (level == widget.playerStatus.currentLevel) {
      return LevelStatus.current;
    } else {
      return LevelStatus.locked;
    }
  }

  // Calculate position on winding path
  Offset _getLevelPosition(int index) {
    final row = index;
    final x = _pathWidth / 2 + math.sin(row * 0.5) * (_pathWidth / 3);
    final y = row * _verticalSpacing;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Color(0xFFFFE4B5), // Moccasin
              Color(0xFFFFF1C1), // Cream
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              // Level path
              Expanded(
                child: Stack(
                  children: [
                    // Path line
                    CustomPaint(
                      size: Size(
                          MediaQuery.of(context).size.width, double.infinity),
                      painter: PathPainter(
                        levelCount: widget.levelCount,
                        animation: _pathAnimationController,
                        getLevelPosition: _getLevelPosition,
                      ),
                    ),

                    // Scrollable level nodes
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: widget.levelCount * _verticalSpacing + 200,
                        child: Stack(
                          children: List.generate(widget.levelCount, (index) {
                            final level = index + 1;
                            final position = _getLevelPosition(index);
                            final status = _getLevelStatus(level);

                            return Positioned(
                              left: position.dx - _levelSize / 2,
                              top: position.dy,
                              child: _buildLevelNode(level, status),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Fancy header

              // Bottom progress bar
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Back button
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildAnimatedButton(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // Title
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFCB500), Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'ADVENTURE MAP',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(int level, LevelStatus status) {
    final isHovered = _hoveredLevels[level] ?? false;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLevels[level] = true),
      onExit: (_) => setState(() => _hoveredLevels[level] = false),
      child: GestureDetector(
        onTap: status != LevelStatus.locked ? () => _openLevel(level) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isHovered ? 1.15 : 1.0)
            ..translate(0.0, isHovered ? -5.0 : 0.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Glow effect for current level
              if (status == LevelStatus.current)
                AnimatedBuilder(
                  animation: _pulseAnimationController,
                  builder: (context, child) {
                    return Container(
                      width: _levelSize +
                          20 +
                          _pulseAnimationController.value * 20,
                      height: _levelSize +
                          20 +
                          _pulseAnimationController.value * 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow.withValues(alpha: 0.3),
                            Colors.yellow.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Level container
              Container(
                width: _levelSize,
                height: _levelSize,
                decoration: BoxDecoration(
                  gradient: _getLevelGradient(status),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getLevelShadowColor(status),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: _getLevelContent(level, status),
              ),

              // Stars for completed levels
              if (status == LevelStatus.completed)
                Positioned(
                  bottom: -5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.star,
                        size: 20,
                        color: Colors.amber,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 2,
                          ),
                        ],
                      );
                    }),
                  ),
                ),

              // Lock overlay for locked levels
              if (status == LevelStatus.locked)
                Container(
                  width: _levelSize,
                  height: _levelSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getLevelGradient(LevelStatus status) {
    switch (status) {
      case LevelStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case LevelStatus.current:
        return const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case LevelStatus.locked:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF616161)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getLevelShadowColor(LevelStatus status) {
    switch (status) {
      case LevelStatus.completed:
        return Colors.green.withValues(alpha: 0.5);
      case LevelStatus.current:
        return Colors.orange.withValues(alpha: 0.6);
      case LevelStatus.locked:
        return Colors.black.withValues(alpha: 0.3);
    }
  }

  Widget _getLevelContent(int level, LevelStatus status) {
    if (status == LevelStatus.locked) {
      return const Icon(
        Icons.lock_rounded,
        color: Colors.white,
        size: 35,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$level',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (widget.playerStatus.currentLevel - 1) / widget.levelCount;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${widget.playerStatus.currentLevel}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width * progress,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingUI(BuildContext context) {
    return Positioned(
      top: 140,
      right: 20,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: Icons.emoji_events,
            color: Colors.amber,
            onTap: () {
              // Show achievements
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.leaderboard,
            color: Colors.purple,
            onTap: () {
              // Show leaderboard
            },
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.settings,
            color: Colors.blueGrey,
            onTap: () {
              // Show settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _buildAnimatedButton(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) {},
      onTapUp: (_) {},
      onTap: onTap,
      child: child,
    );
  }

  // Navigate to the level
  Future<void> _openLevel(int level) async {
    final ref = ProviderScope.containerOf(context);
    final authState = ref.read(authStateProvider.notifier);
    final userId = authState.session?.user.id;

    if (userId == null) {
      return;
    }

    // Show loading indicator with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFCB500)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading Level $level...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        LevelsService.instance.getLevel(level),
        PlayerStatusService.instance.getLevelsFoundWords(userId, level),
        PlayerStatusService.instance.getPlayerStatus(userId),
      ]);

      // Pop loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final Level? levelData = results[0] as Level?;
      final Set<String> foundWords = results[1] as Set<String>? ?? {};
      final PlayerStatus? playerStatus = results[2] as PlayerStatus?;

      if (levelData != null && playerStatus != null && context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CrosswordBoardScreen(
              words: levelData.words,
              foundWords: foundWords,
              level: level,
              playerStatus: playerStatus,
              userId: userId,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      // Pop loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load level: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Level status enum
enum LevelStatus {
  completed,
  current,
  locked,
}

// Custom painter for the winding path
class PathPainter extends CustomPainter {
  final int levelCount;
  final Animation<double> animation;
  final Offset Function(int) getLevelPosition;

  PathPainter({
    required this.levelCount,
    required this.animation,
    required this.getLevelPosition,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < levelCount; i++) {
      final position = getLevelPosition(i);
      if (i == 0) {
        path.moveTo(position.dx, position.dy + 40);
      } else {
        final prevPosition = getLevelPosition(i - 1);

        // Create smooth curves between levels
        final controlPoint1 = Offset(
          prevPosition.dx,
          prevPosition.dy + 60,
        );
        final controlPoint2 = Offset(
          position.dx,
          position.dy - 20,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          position.dx,
          position.dy + 40,
        );
      }
    }

    // Draw animated path
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final extractedPath = metric.extractPath(
        0,
        metric.length * animation.value,
      );
      canvas.drawPath(extractedPath, paint);
    }

    // Draw dots along the path
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (int i = 1; i < levelCount; i++) {
      if (i % 3 == 0) continue; // Skip every 3rd dot for cleaner look
      final position = getLevelPosition(i);
      canvas.drawCircle(
        Offset(position.dx, position.dy + 40),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Shimmer effect for progress bar
class ShimmerPainter extends CustomPainter {
  final Animation<double> animation;

  ShimmerPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.3),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(animation.value * 2 * math.pi),
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
