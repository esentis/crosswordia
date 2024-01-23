import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  const BlurContainer({
    super.key,
    this.sigmaX,
    this.sigmaY,
    this.color,
    this.opacity,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.height,
    this.width,
    required this.child,
  });

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
    return Stack(
      children: [
        Container(
          height: height ?? 200,
          width: width ?? 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xffFFF9DE).withOpacity(0.1),
                const Color(0xffFFD3B0).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            border: Border.all(
              color: borderColor ?? Colors.pink.withOpacity(0.1),
              width: borderWidth ?? 2,
            ),
          ),
        ),
        Container(
          height: height ?? 200,
          width: width ?? 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xffA6D0DD).withOpacity(0.1),
                const Color(0xffFF6969).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            // border: Border.all(
            //   color: borderColor ?? Colors.pink.withOpacity(0.1),
            //   width: borderWidth ?? 2,
            // ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigmaX ?? 4, sigmaY: sigmaY ?? 3),
            child: Container(
              height: height ?? 200,
              width: width ?? 200,
              decoration: BoxDecoration(
                color: (color ?? Colors.pink).withOpacity(opacity ?? 0.05),
                borderRadius: BorderRadius.circular(borderRadius ?? 12),
                // border: Border.all(
                //   color: borderColor ?? Colors.pink.withOpacity(0.1),
                //   width: borderWidth ?? 2,
                // ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
