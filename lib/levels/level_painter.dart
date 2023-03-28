import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';

class LevelNode {
  final int level;
  final int userCurrentLevel;
  final Offset position;
  final Color finishedLineColor;
  final Color inProgressLineColor;
  final Color shadowColor;
  final bool isFinished;
  LevelNode({
    required this.level,
    required this.position,
    required this.finishedLineColor,
    required this.isFinished,
    required this.inProgressLineColor,
    required this.shadowColor,
    required this.userCurrentLevel,
  });
}

class LevelScreenPainter extends CustomPainter {
  final List<LevelNode> nodes;

  LevelScreenPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final shadowPath = Path();

    for (int i = 0; i < nodes.length - 1; i++) {
      final startPosition = nodes[i].position;
      final endPosition = nodes[i + 1].position;

      double controlPoint1X =
          startPosition.dx + (endPosition.dx - startPosition.dx) * 0.25;
      double controlPoint1Y =
          startPosition.dy - (endPosition.dy - startPosition.dy) * 0.25;

      double controlPoint2X =
          startPosition.dx + (endPosition.dx - startPosition.dx) * 0.75;
      double controlPoint2Y =
          endPosition.dy + (endPosition.dy - startPosition.dy) * 0.25;

      double loopControlPoint1X =
          startPosition.dx + (endPosition.dx - startPosition.dx) * 0.5;
      double loopControlPoint1Y = startPosition.dy - 50;

      double loopControlPoint2X =
          startPosition.dx + (endPosition.dx - startPosition.dx) * 0.5;
      double loopControlPoint2Y = startPosition.dy + 50;

      final paint = Paint()
        ..color = nodes[i].isFinished
            ? nodes[i].finishedLineColor
            : nodes[i].inProgressLineColor
        ..strokeWidth = nodes[i].isFinished ? 18 : 10
        ..style = PaintingStyle.stroke;

      final shadowPaint = Paint()
        ..color = nodes[i].shadowColor
        ..imageFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5)
        ..strokeWidth = nodes[i].isFinished ? 22 : 14
        ..style = PaintingStyle.stroke;

      shadowPath.moveTo(startPosition.dx, startPosition.dy);
      shadowPath.cubicTo(
        controlPoint1X,
        controlPoint1Y,
        loopControlPoint1X,
        loopControlPoint1Y,
        startPosition.dx + (endPosition.dx - startPosition.dx) * 0.5,
        startPosition.dy,
      );
      shadowPath.cubicTo(
        loopControlPoint2X,
        loopControlPoint2Y,
        controlPoint2X,
        controlPoint2Y,
        endPosition.dx,
        endPosition.dy,
      );
      path.moveTo(startPosition.dx, startPosition.dy);
      path.cubicTo(
        controlPoint1X,
        controlPoint1Y,
        loopControlPoint1X,
        loopControlPoint1Y,
        startPosition.dx + (endPosition.dx - startPosition.dx) * 0.5,
        startPosition.dy,
      );
      path.cubicTo(
        loopControlPoint2X,
        loopControlPoint2Y,
        controlPoint2X,
        controlPoint2Y,
        endPosition.dx,
        endPosition.dy,
      );
      canvas.drawPath(shadowPath, shadowPaint);
      canvas.drawPath(path, paint);

      path.reset();
      shadowPath.reset();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LevelNodeWidget extends StatelessWidget {
  final LevelNode node;
  final double radius;

  const LevelNodeWidget({
    super.key,
    required this.node,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (node.level == node.userCurrentLevel)
          Pulse(
            infinite: true,
            child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xffF5C6EC).withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                )),
          ),
        Bounceable(
          scaleFactor: 0.5,
          onTap: node.userCurrentLevel < node.level
              ? null
              : () => print('Tapped on node ${node.level}'),
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: node.isFinished
                  ? const Color(0xffF5C6EC)
                  : node.userCurrentLevel == node.level
                      ? const Color(0xffBE6DB7)
                      : Colors.grey[300],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                node.level.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
