import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/board_cell.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.controller,
    required this.onLetterTap,
    super.key,
  });

  final CrosswordBoardController controller;
  final Future<void> Function(String) onLetterTap;

  @override
  Widget build(BuildContext context) {
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
                key: ValueKey(controller.foundLetterPositions.hashCode),
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
                  return BoardCell(
                    row: row,
                    col: col,
                    position: currentPosition,
                    controller: controller,
                    onTap: onLetterTap,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}