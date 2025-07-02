import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    required this.controller,
    required this.showFoundWords,
    required this.onToggleFoundWords,
    super.key,
  });

  final CrosswordBoardController controller;
  final bool showFoundWords;
  final VoidCallback onToggleFoundWords;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: onToggleFoundWords,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(showFoundWords ? 1.05 : 1.0),
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
                      colors: showFoundWords
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
                      color: showFoundWords
                          ? const Color(0xFFffc93c).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                    boxShadow: showFoundWords
                        ? [
                            BoxShadow(
                              color: const Color(0xFFffc93c)
                                  .withValues(alpha: 0.3),
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
                              'Level ${controller.level}  •  Coins ${controller.playerStatus.coins}',
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
                              showFoundWords
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onToggleFoundWords,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: showFoundWords
                                  ? const Color(0xFFffc93c)
                                      .withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                                '${controller.totalFoundWordsOfLevel.length} of ${controller.allPlacedWords.length} placed words • ${controller.totalWordsOfLevel.length} total',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.karla(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: showFoundWords
                                      ? Colors.white
                                      : Colors.white70,
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
}
