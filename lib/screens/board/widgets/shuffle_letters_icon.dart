import 'package:flutter/material.dart';

class ShuffleLettersIcon extends StatelessWidget {
  const ShuffleLettersIcon({super.key, required this.onShuffle});
  final VoidCallback onShuffle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onShuffle,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.shuffle,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
