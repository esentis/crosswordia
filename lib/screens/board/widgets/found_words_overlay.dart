import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoundWordsOverlay extends StatelessWidget {
  const FoundWordsOverlay({
    required this.controller,
    required this.animation,
    required this.onClose,
    super.key,
  });

  final CrosswordBoardController controller;
  final Animation<double> animation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final foundPlacedWords = controller.totalFoundWordsOfLevel
        .where((word) => controller.allPlacedWords.contains(word))
        .toList();
    final foundOtherWords = controller.totalFoundWordsOfLevel
        .where((word) => !controller.allPlacedWords.contains(word))
        .toList();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          top: 85 + (20 * (1 - animation.value)),
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Transform.scale(
            scale: 0.8 + (0.2 * animation.value),
            child: Opacity(
              opacity: animation.value,
              child: GestureDetector(
                onTap: onClose,
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
                          _OverlayHeader(
                            foundWordsCount:
                                controller.totalFoundWordsOfLevel.length,
                          ),
                          _OverlayContent(
                            foundPlacedWords: foundPlacedWords,
                            foundOtherWords: foundOtherWords,
                            isEmpty: controller.totalFoundWordsOfLevel.isEmpty,
                          ),
                          const _OverlayFooter(),
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
}

class _OverlayHeader extends StatelessWidget {
  const _OverlayHeader({
    required this.foundWordsCount,
  });

  final int foundWordsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '$foundWordsCount',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFffc93c),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.foundPlacedWords,
    required this.foundOtherWords,
    required this.isEmpty,
  });

  final List<String> foundPlacedWords;
  final List<String> foundOtherWords;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foundPlacedWords.isNotEmpty) ...[
              WordSection(
                title: 'Placed on Board',
                words: foundPlacedWords,
                accentColor: const Color(0xFF4CAF50),
                icon: Icons.grid_on,
              ),
              const SizedBox(height: 16),
            ],
            if (foundOtherWords.isNotEmpty)
              WordSection(
                title: 'Bonus Words',
                words: foundOtherWords,
                accentColor: const Color(0xFF2196F3),
                icon: Icons.star_outline,
              ),
            if (isEmpty)
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
    );
  }
}

class _OverlayFooter extends StatelessWidget {
  const _OverlayFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class WordSection extends StatelessWidget {
  const WordSection({
    required this.title,
    required this.words,
    required this.accentColor,
    required this.icon,
    super.key,
  });

  final String title;
  final List<String> words;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
          children: words
              .map((word) => WordChip(word: word, accentColor: accentColor))
              .toList(),
        ),
      ],
    );
  }
}

class WordChip extends StatelessWidget {
  const WordChip({
    required this.word,
    required this.accentColor,
    super.key,
  });

  final String word;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
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
