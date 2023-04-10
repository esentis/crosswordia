import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  const BlurContainer(
      {super.key,
      this.sigmaX,
      this.sigmaY,
      this.color,
      this.opacity,
      this.borderRadius,
      this.borderWidth,
      this.borderColor,
      this.height,
      this.width,
      required this.child});

  final double? sigmaX;
  final double? sigmaY;
  final Color? color;
  final double? opacity;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? height;
  final double? width;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX ?? 5, sigmaY: sigmaY ?? 5),
        child: Container(
          height: height ?? 200,
          width: width ?? 200,
          decoration: BoxDecoration(
            color: (color ?? Colors.pink).withOpacity(opacity ?? 0.05),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            border: Border.all(
              color: borderColor ?? Colors.pink.withOpacity(0.1),
              width: borderWidth ?? 2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
