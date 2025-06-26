import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:crosswordia/screens/board/widgets/letter_connector.dart';
import 'package:crosswordia/screens/board/widgets/shuffle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterConnectorSection extends StatelessWidget {
  const LetterConnectorSection({
    required this.controller,
    required this.lettersController,
    required this.onCompleted,
    required this.onShuffleTap,
    required this.shuffleAnimation,
    super.key,
  });

  final CrosswordBoardController controller;
  final LettersController lettersController;
  final Future<void> Function(List<String>) onCompleted;
  final VoidCallback onShuffleTap;
  final AnimationController shuffleAnimation;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 17.0 + MediaQuery.paddingOf(context).bottom),
      child: SizedBox(
        height: size.height * 0.26,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (controller.lettersForTheBoard.isNotEmpty)
              LetterConnector(
                controller: lettersController,
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
                  controller.addLetterToCurrentWord(letterPosition.letter);
                },
                onUnsnap: (letterPosition) {
                  controller.removeLastLetterFromCurrentWord();
                },
                onCompleted: onCompleted,
                letters: controller.lettersForTheBoard,
                key: ValueKey(
                  controller.lettersForTheBoard.isNotEmpty
                      ? '${controller.lettersForTheBoard.last}'
                          '${controller.lettersForTheBoard.first}'
                          '${controller.lettersForTheBoard.length > 1 ? controller.lettersForTheBoard[1] : ""}'
                      : 'empty',
                ),
              ),
            ShuffleButton(
              onTap: onShuffleTap,
              animation: shuffleAnimation,
            ),
          ],
        ),
      ),
    );
  }
}