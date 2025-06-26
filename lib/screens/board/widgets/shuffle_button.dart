import 'package:flutter/material.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    required this.onTap,
    required this.animation,
    super.key,
  });

  final VoidCallback onTap;
  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
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
          child: const Icon(Icons.shuffle_rounded, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}