import 'dart:ui';

import 'package:crosswordia/screens/board/controllers/crossword_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoardCell extends StatefulWidget {
  const BoardCell({
    required this.row,
    required this.col,
    required this.position,
    required this.controller,
    required this.onTap,
    super.key,
  });

  final int row;
  final int col;
  final String position;
  final CrosswordBoardController controller;
  final Future<void> Function(String) onTap;

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell>
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
