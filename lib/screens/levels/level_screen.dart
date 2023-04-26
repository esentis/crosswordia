import 'dart:math' as math;

import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/board/crossword_board_screen.dart';
import 'package:crosswordia/screens/levels/widgets/level_painter.dart';
import 'package:crosswordia/services/levels_service.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({
    required this.levelCount,
    required this.playerStatus,
    super.key,
  });
  final int levelCount;
  final PlayerStatus playerStatus;
  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _animationController;

  late Animation<Matrix4> _animation;

  void panToNode(LevelNode node) async {
    LevelNode targetNode = node;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double targetX = (screenWidth / 1.2) - targetNode.position.dx;
    double targetY = (screenHeight / 1.5) - targetNode.position.dy;

    // Calculate the target transformation matrix
    Matrix4 targetMatrix = Matrix4.identity()..translate(targetX, targetY);

    // Set up the animation
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );

    // Reset and play the animation
    _animationController.reset();
    await _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.addListener(() {
      _transformationController.value = _animation.value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int nodeCount = widget.levelCount;
    double horizontalSpacingFactor =
        0.4; // Adjust this to control the horizontal spacing
    double verticalSpacingFactor =
        0.2; // Adjust this to control the vertical spacing

    double sineFrequency =
        2; // Adjust this to control the frequency of the sine function
    double sineAmplitude =
        4; // Adjust this to control the amplitude of the sine function
    double sineOffset =
        0.5; // Adjust this to control the offset of the sine function

    final List<LevelNode> nodes = List.generate(
      nodeCount,
      (index) => LevelNode(
        finishedLineColor: const Color(0xffF5C6EC),
        inProgressLineColor: Colors.grey[300]!,
        shadowColor: Colors.black.withOpacity(0.4),
        isFinished: index + 1 < widget.playerStatus.currentLevel,
        level: index + 1,
        userCurrentLevel: widget.playerStatus.currentLevel,
        position: Offset(
          screenWidth / 2 +
              screenWidth *
                  horizontalSpacingFactor *
                  math.sin(sineFrequency * index * math.pi / 3 +
                      sineOffset * sineAmplitude),
          screenHeight * verticalSpacingFactor +
              index * screenHeight * verticalSpacingFactor,
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      panToNode(nodes[widget.playerStatus.currentLevel]);
    });

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      double x = node.position.dx;
      double y = node.position.dy;

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    double customPaintWidth = maxX - minX + 2 * 40;
    double customPaintHeight = maxY - minY + 2 * 40;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your level')),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/bg.webp',
            fit: BoxFit.cover,
          )),
          Container(
            color: Colors.white.withOpacity(0.6),
          ),
          Consumer(builder: (context, ref, child) {
            final playerStatus = ref.read(authStateProvider.notifier);
            return InteractiveViewer(
              transformationController: _transformationController,
              scaleEnabled: true,
              constrained: false,
              clipBehavior: Clip.none,
              minScale: 0.3,
              maxScale: 2.0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: customPaintWidth * 1.3,
                    maxHeight: customPaintHeight * 1.1,
                  ),
                  child: Stack(
                    // clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        painter: LevelScreenPainter(nodes: nodes),
                        size: Size.infinite,
                      ),
                      ...nodes.map((node) {
                        return Positioned(
                          left: node.position.dx - 40,
                          top: node.position.dy - 40,
                          child: LevelNodeWidget(
                            node: node,
                            radius: 40,
                            onTap: () async {
                              Set<String> levelWords = {};
                              Set<String> foundWords = {};

                              final Level? level = await LevelsService.instance
                                  .getLevel(node.level);
                              foundWords = await PlayerStatusService.instance
                                      .getLevelsFoundWords(
                                          playerStatus.session!.user.id,
                                          node.level) ??
                                  {};

                              if (level != null) {
                                levelWords = level.words;
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CrosswordBoardScreen(
                                        words: levelWords,
                                        foundWords: foundWords,
                                        level: node.level,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
