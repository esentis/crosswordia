import 'dart:math';

import 'package:crosswordia/helper.dart';
import 'package:flutter/material.dart';

enum LetterStyle {
  square,
  circle,
}

class LetterConnector extends StatefulWidget {
  const LetterConnector({
    required this.letters,
    required this.onSnap,
    required this.onUnsnap,
    required this.onCompleted,
    required this.controller,
    this.letterStyle = LetterStyle.circle,
    this.distanceOfLetters,
    this.letterSize,
    this.borderColor,
    this.lineColor,
    this.selectedColor,
    this.unselectedColor,
    this.textStyle,
    super.key,
  });
  final List<String> letters;
  final void Function(LetterPosition letter) onSnap;
  final void Function(List<String> allSelectedLetters) onCompleted;
  final void Function(LetterPosition letter) onUnsnap;
  final LetterStyle letterStyle;
  final num? distanceOfLetters;
  final num? letterSize;
  final Color? borderColor;
  final Color? lineColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? textStyle;
  final LettersController controller;
  @override
  State<StatefulWidget> createState() => _LetterConnectorState();
}

class _LetterConnectorState extends State<LetterConnector>
    with TickerProviderStateMixin {
  List<LetterPosition> letterPositions = [];

  List<String> get letters => widget.letters;

  late List<AnimationController> _letterSnapAnimationController;
  late List<Animation<double>> _letterSnapAnimations;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _successAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  Path path = Path();
  List<int> snappedLettersIndexes = [];
  List<String> snappedLetters = [];
  Offset? currentOffset;
  int lastSnappedLetter = -1;
  bool insideLetter = false;

  void _startDrawing(Offset localPosition) {
    final int index = _getLetterIndexAtOffset(localPosition);

    if (index != -1 && !insideLetter) {
      kLog.i('Start drawing at $index');
      path.moveTo(
        letterPositions[index].position.dx,
        letterPositions[index].position.dy,
      );
      insideLetter = true;
      _snapLetter(index);
      currentOffset = localPosition;
    } else {
      insideLetter = false;
      currentOffset = null;
    }
  }

  void _snapLetter(int index) {
    _letterSnapAnimationController[index]
        .forward(from: 0.0); // Reset and play forward
    snappedLetters.add(letters[index]);
    snappedLettersIndexes.add(index);
    lastSnappedLetter = index;
    widget.onSnap(
      LetterPosition(
        position: letterPositions[index].position,
        letter: letters[index],
      ),
    );
  }

  void _unsnapLastLetter() {
    if (snappedLettersIndexes.isNotEmpty) {
      final int lastIndex = snappedLettersIndexes.last;
      // Reset the controller and play a different tween
      _letterSnapAnimationController[lastIndex].reverse();
      // Play forward with a potentially different tween or duration
      final lastLetter = snappedLetters.last;
      final lastLetterPosition =
          letterPositions[snappedLettersIndexes.last].position;
      snappedLetters.removeLast();
      snappedLettersIndexes.removeLast();
      lastSnappedLetter =
          snappedLettersIndexes.isNotEmpty ? snappedLettersIndexes.last : -1;

      widget.onUnsnap(
        LetterPosition(position: lastLetterPosition, letter: lastLetter),
      );
    }
  }

  void _updateDrawing(Offset localPosition) {
    final int index = _getLetterIndexAtOffset(localPosition);

    if (index != -1 && index != lastSnappedLetter && !insideLetter) {
      insideLetter = true;
      if (!snappedLettersIndexes.contains(index)) {
        if (snappedLettersIndexes.isEmpty) {
          path.moveTo(
            letterPositions[index].position.dx,
            letterPositions[index].position.dy,
          );
        } else {
          path.lineTo(
            letterPositions[index].position.dx,
            letterPositions[index].position.dy,
          );
        }
        _snapLetter(index);
      }
    } else if (index == lastSnappedLetter &&
        !insideLetter &&
        snappedLetters.length > 1) {
      insideLetter = true;
      if (snappedLetters.isNotEmpty && snappedLettersIndexes.isNotEmpty) {
        _unsnapLastLetter();
      }

      // Remove the last line segment
      if (snappedLettersIndexes.length > 1) {
        path = Path();
        path.moveTo(
          letterPositions[snappedLettersIndexes[0]].position.dx,
          letterPositions[snappedLettersIndexes[0]].position.dy,
        );
        for (int i = 1; i < snappedLettersIndexes.length; i++) {
          path.lineTo(
            letterPositions[snappedLettersIndexes[i]].position.dx,
            letterPositions[snappedLettersIndexes[i]].position.dy,
          );
        }
      } else if (snappedLettersIndexes.length == 1) {
        // Move to the first letter when there's only one letter left
        path = Path();
        path.moveTo(
          letterPositions[snappedLettersIndexes[0]].position.dx,
          letterPositions[snappedLettersIndexes[0]].position.dy,
        );
      }
    } else if (index == -1) {
      insideLetter = false;
    }
    currentOffset = localPosition;
  }

  void _endDrawing() {
    widget.onCompleted(snappedLetters);
    currentOffset = null;
    path = Path();
    snappedLettersIndexes.clear();
    snappedLetters.clear();
    lastSnappedLetter = -1;
    insideLetter = false;
    for (final controller in _letterSnapAnimationController) {
      controller.reset();
    }
  }

  int _getLetterIndexAtOffset(Offset offset) {
    const double touchTolerance = 10.0; // Adjust as needed for snap sensitivity

    for (int i = 0; i < letterPositions.length; i++) {
      if (widget.letterStyle == LetterStyle.circle) {
        final double radius =
            (widget.letterSize?.toDouble() ?? 25.0) + touchTolerance;
        if ((offset - letterPositions[i].position).distance <= radius) {
          return i;
        }
      } else if (widget.letterStyle == LetterStyle.square) {
        final double squareSize =
            (widget.letterSize?.toDouble() ?? 50.0) / 2 + touchTolerance;
        final Rect squareBounds = Rect.fromCenter(
          center: letterPositions[i].position,
          width: squareSize,
          height: squareSize,
        );
        if (squareBounds.contains(offset)) {
          return i;
        }
      }
    }
    return -1;
  }

  void triggerSuccessAnimation() {
    _successAnimationController.forward(from: 0.0).then((_) {
      _successAnimationController.reverse();
    });
  }

  void triggerErrorShake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.getLetterPositions = () => letterPositions;
    widget.controller.triggerErrorShake = () => triggerErrorShake();
    widget.controller.triggerSuccessAnimation = () => triggerSuccessAnimation();

    _letterSnapAnimationController =
        List.generate(widget.letters.length, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    });

    _letterSnapAnimations = _letterSnapAnimationController.map((controller) {
      return Tween<double>(begin: 1, end: 1.3).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.bounceIn,
          reverseCurve: Curves.bounceOut,
        ),
      );
    }).toList();

    // Initialize the shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Define the shake animation
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withOpacity(
        0.5,
      ),
    ).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successAnimationController.dispose();
    _scaleAnimation.removeListener(() {});
    _colorAnimation.removeListener(() {});
    for (final controller in _letterSnapAnimationController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * sin(_shakeController.value * 2 * pi),
            0,
          ),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: _successAnimationController,
        builder: (context, child) {
          // Apply the success animations (scale and color)
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _successAnimationController.value * 32 * pi,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _colorAnimation.value ?? Colors.white,
                  BlendMode.srcATop,
                ),
                child: child,
              ),
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            setState(() {
              _startDrawing(details.localPosition);
            });
          },
          onTapUp: (details) {
            setState(() {
              _endDrawing();
            });
          },
          onPanStart: (details) {
            setState(() {
              _startDrawing(details.localPosition);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _updateDrawing(details.localPosition);
            });
          },
          onPanEnd: (details) {
            setState(() {
              _endDrawing();
            });
          },
          child: AnimatedBuilder(
            animation: Listenable.merge(_letterSnapAnimations),
            builder: (context, child) => CustomPaint(
              painter: _LetterConnectPainter(
                letterPositions: letterPositions,
                letters: letters,
                snappedLetters: snappedLettersIndexes,
                letterAnimations: _letterSnapAnimations,
                letterSize: widget.letterSize,
                path: path,
                borderColor: widget.borderColor,
                currentOffset: currentOffset,
                onLetterPositionsDetermined: (positions) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (letterPositions.isEmpty) {
                      setState(() {
                        letterPositions = positions;
                      });
                    }
                  });
                },
                currentIndex: _getLetterIndexAtOffset(
                  currentOffset ?? Offset.zero,
                ),
                letterStyle: widget.letterStyle,
                distanceOfLetters: widget.distanceOfLetters,
                lineColor: widget.lineColor,
                selectedLetterColor: widget.selectedColor,
                unselectedLetterColor: widget.unselectedColor,
                letterTextStyle: widget.textStyle,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterConnectPainter extends CustomPainter {
  final List<LetterPosition> letterPositions;
  final List<String> letters;
  final List<int> snappedLetters;
  final Path path;
  final Offset? currentOffset;
  final int currentIndex;
  final LetterStyle letterStyle;
  final num? distanceOfLetters;
  final num? letterSize;
  final Color? borderColor;
  final Color? selectedLetterColor;
  final Color? unselectedLetterColor;
  final Color? lineColor;
  final TextStyle? letterTextStyle;
  final List<Animation<double>> letterAnimations;
  final Function(List<LetterPosition> letterPositions)
      onLetterPositionsDetermined;
  _LetterConnectPainter({
    required this.letterPositions,
    required this.letters,
    required this.path,
    required this.currentOffset,
    required this.snappedLetters,
    required this.currentIndex,
    required this.letterStyle,
    required this.onLetterPositionsDetermined,
    required this.letterAnimations,
    this.distanceOfLetters,
    this.letterSize,
    this.borderColor,
    this.selectedLetterColor,
    this.unselectedLetterColor,
    this.lineColor,
    this.letterTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
    _drawCircularLetters(canvas, size);
  }

  void _drawCircularLetters(Canvas canvas, Size size) {
    final double radius =
        distanceOfLetters?.toDouble() ?? min(size.width, size.height) / 2 - 70;
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < letters.length; i++) {
      final double scale = letterAnimations[i].value;
      final double angle = (2 * pi / letters.length) * i;
      final double dx = center.dx + radius * cos(angle);
      final double dy = center.dy + radius * sin(angle);
      final Offset position = Offset(dx, dy);

      if (letterPositions.length < letters.length) {
        letterPositions.add(
          LetterPosition(
            position: position,
            letter: letters[i],
          ),
        );
      }

      final Color color = snappedLetters.contains(i)
          ? selectedLetterColor ?? Colors.red
          : unselectedLetterColor ?? Colors.white;
      letterStyle == LetterStyle.circle
          ? // Pass the scale to the drawing methods
          _drawLetterInCircle(canvas, letters[i], position, color, scale)
          : _drawLetterInSquare(canvas, letters[i], position, color, scale);
    }

    onLetterPositionsDetermined(letterPositions);
  }

// SQUARE LETTER
  void _drawLetterInSquare(
    Canvas canvas,
    String letter,
    Offset position,
    Color color,
    double scale,
  ) {
    final double squareSize = (letterSize?.toDouble() ?? 50.0) * scale;

    // Draw the square
    final Paint squarePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    final Rect rect = Rect.fromCenter(
      center: position,
      width: squareSize,
      height: squareSize,
    );
    final RRect roundedRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(roundedRect, squarePaint);

    // Draw the border
    final Paint borderPaint = Paint()
      ..color =
          borderColor ?? Colors.black // Set your desired border color here
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(roundedRect, borderPaint);

    // Draw the letter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: letterTextStyle ??
            const TextStyle(fontSize: 24, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawLetterInCircle(
    Canvas canvas,
    String letter,
    Offset position,
    Color color,
    double scale,
  ) {
    final double circleRadius = (letterSize?.toDouble() ?? 25.0) * scale;

    // Draw the filled circle
    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, circleRadius, circlePaint);

    // Draw the border
    final Paint borderPaint = Paint()
      ..color =
          borderColor ?? Colors.black // Set your desired border color here
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, circleRadius, borderPaint);

    // Draw the letter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: letterTextStyle ??
            const TextStyle(fontSize: 24, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawPath(Canvas canvas) {
    final Paint paint = Paint()
      ..color = lineColor ?? Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    if (currentOffset != null &&
        (snappedLetters.isNotEmpty || currentIndex != -1)) {
      final Path newPath = Path.from(path);
      newPath.lineTo(currentOffset!.dx, currentOffset!.dy);
      canvas.drawPath(newPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LetterConnectPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.currentOffset != currentOffset;
  }
}

class LettersController {
  late List<LetterPosition> Function() getLetterPositions;
  late void Function() triggerErrorShake;
  late void Function() triggerSuccessAnimation;
  LettersController();
}

class LetterPosition {
  final Offset position;
  final String letter;
  LetterPosition({required this.position, required this.letter});

  @override
  String toString() {
    return 'LetterPosition(position: $position, letter: $letter)';
  }
}
