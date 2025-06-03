import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum LetterStyle {
  square,
  circle,
  woodenCircle,
}

class LetterConnector extends StatefulWidget {
  const LetterConnector({
    required this.letters,
    required this.onSnap,
    required this.onUnsnap,
    required this.onCompleted,
    required this.controller,
    this.letterStyle = LetterStyle.woodenCircle,
    this.distanceOfLetters,
    this.letterSize,
    this.borderColor,
    this.lineColor,
    this.selectedColor,
    this.unselectedColor,
    this.textStyle,
    this.showLettersBackground = true,
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
  final bool showLettersBackground;

  @override
  State<StatefulWidget> createState() => _LetterConnectorState();
}

class _LetterConnectorState extends State<LetterConnector>
    with TickerProviderStateMixin {
  // Letter positions and hitboxes
  final List<Offset> letterPositions = [];
  final List<Rect> letterHitboxes = [];
  bool positionsCalculated = false;

  // Selection state
  final List<int> selectedIndices = [];
  final List<String> selectedLetters = [];

  // Touch state
  Offset? currentPosition;
  bool isDragging = false;
  int? lastSelectedIndex;
  int? currentlyTouchedIndex; // Track which letter is currently being touched
  Set<int> visitedLetters = {}; // Track which letters we've already visited

  // Path for drawing
  final Path path = Path();

  // Container size for layout
  Size? containerSize;

  // Animations
  late List<AnimationController> letterAnimControllers;
  late List<Animation<double>> letterScaleAnimations;
  late AnimationController shakeController;
  late Animation<double> shakeAnimation;
  late AnimationController successController;
  late Animation<double> successScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up controller callbacks
    widget.controller.getLetterPositions = () => letterPositions
        .asMap()
        .entries
        .map((e) =>
            LetterPosition(position: e.value, letter: widget.letters[e.key]))
        .toList();

    widget.controller.triggerErrorShake = _triggerErrorAnimation;
    widget.controller.triggerSuccessAnimation = _triggerSuccessAnimation;

    // Initialize letter animations
    letterAnimControllers = List.generate(
      widget.letters.length,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    letterScaleAnimations = letterAnimControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        ),
      );
    }).toList();

    // Initialize shake animation
    shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: shakeController,
        curve: Curves.elasticInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          shakeController.reverse();
        }
      });

    // Initialize success animation
    successController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    successScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: successController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in letterAnimControllers) {
      controller.dispose();
    }
    shakeController.dispose();
    successController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LetterConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force recalculation of positions if letters change
    if (oldWidget.letters.length != widget.letters.length) {
      positionsCalculated = false;
      // Ensure animation controllers match new letter count
      if (letterAnimControllers.length != widget.letters.length) {
        // Dispose old controllers
        for (final controller in letterAnimControllers) {
          controller.dispose();
        }

        // Create new controllers
        letterAnimControllers = List.generate(
          widget.letters.length,
          (i) => AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: this,
          ),
        );

        letterScaleAnimations = letterAnimControllers.map((controller) {
          return Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeInBack,
            ),
          );
        }).toList();
      }
    }
  }

  // Calculate letter positions and hitboxes in a circle
  void _calculatePositions(Size size) {
    // Only recalculate if needed
    if (positionsCalculated) return;

    letterPositions.clear();
    letterHitboxes.clear();

    final double radius = widget.distanceOfLetters?.toDouble() ??
        min(size.width, size.height) / 2 - 70;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double letterSize = widget.letterSize?.toDouble() ?? 50.0;

    for (int i = 0; i < widget.letters.length; i++) {
      final double angle = (2 * pi / widget.letters.length) * i - (pi / 2);
      final double dx = center.dx + radius * cos(angle);
      final double dy = center.dy + radius * sin(angle);

      final Offset position = Offset(dx, dy);
      letterPositions.add(position);

      // Create hitbox exactly centered on position
      final Rect hitbox = Rect.fromCenter(
        center: position,
        width: letterSize * 1.5,
        height: letterSize * 1.5,
      );
      letterHitboxes.add(hitbox);
    }

    positionsCalculated = true;
  }

  // Find which letter is being touched using hitbox rect.contains
  int? _getLetterIndexAt(Offset position) {
    for (int i = 0; i < letterHitboxes.length; i++) {
      if (letterHitboxes[i].contains(position)) {
        return i;
      }
    }
    return null;
  }

  // Handle touch down
// Fix for the _handleTouchDown method to check mounted state
  void _handleTouchDown(Offset position) {
    if (!mounted) return; // Prevent setState call if widget is disposed

    final int? letterIndex = _getLetterIndexAt(position);

    if (letterIndex != null) {
      setState(() {
        isDragging = true;
        currentPosition = position;
        currentlyTouchedIndex = letterIndex;
        visitedLetters.clear();
        visitedLetters.add(letterIndex);
        _selectLetter(letterIndex);
      });
    }
  }

  void _handleTouchMove(Offset position) {
    if (!isDragging || !mounted) {
      return; // Prevent setState call if widget is disposed
    }

    setState(() {
      currentPosition = position;
      final int? letterIndex = _getLetterIndexAt(position);

      // Update which letter we're currently touching
      if (letterIndex != currentlyTouchedIndex) {
        currentlyTouchedIndex = letterIndex;

        // If we've moved to a valid letter
        if (letterIndex != null) {
          // If we've never visited this letter before
          if (!visitedLetters.contains(letterIndex)) {
            visitedLetters.add(letterIndex);
            _selectLetter(letterIndex);
          }
          // If we're returning to the last letter in our selection
          else if (selectedIndices.isNotEmpty &&
              letterIndex == selectedIndices.last &&
              selectedIndices.length > 1) {
            // Unselect the current letter
            _unselectLastLetter();
            // Remove it from visited letters so we can select it again
            visitedLetters.remove(letterIndex);
          }
        }
      }
    });
  }

  // Handle touch up
  void _handleTouchUp() {
    if (!isDragging || !mounted) {
      return; // Prevent setState call if widget is disposed
    }

    widget.onCompleted(selectedLetters);

    setState(() {
      isDragging = false;
      currentPosition = null;
      currentlyTouchedIndex = null;
      visitedLetters.clear();
      path.reset();
      selectedIndices.clear();
      selectedLetters.clear();
      lastSelectedIndex = null;
    });

    for (final controller in letterAnimControllers) {
      controller.reset();
    }
  }

  // Select a letter
  void _selectLetter(int index) {
    if (selectedIndices.contains(index)) return;

    letterAnimControllers[index].forward(from: 0.0);
    selectedIndices.add(index);
    selectedLetters.add(widget.letters[index]);
    lastSelectedIndex = index;

    widget.onSnap(
      LetterPosition(
        position: letterPositions[index],
        letter: widget.letters[index],
      ),
    );

    HapticFeedback.lightImpact();

    // Update path
    if (selectedIndices.length == 1) {
      path.reset();
      path.moveTo(
        letterPositions[index].dx,
        letterPositions[index].dy,
      );
    } else {
      path.lineTo(
        letterPositions[index].dx,
        letterPositions[index].dy,
      );
    }
  }

  // Unselect the last letter
  void _unselectLastLetter() {
    if (selectedIndices.isEmpty) return;

    final lastIndex = selectedIndices.last;
    final lastLetter = selectedLetters.last;
    final lastPosition = letterPositions[lastIndex];

    letterAnimControllers[lastIndex].reverse();

    selectedIndices.removeLast();
    selectedLetters.removeLast();
    lastSelectedIndex =
        selectedIndices.isNotEmpty ? selectedIndices.last : null;

    widget.onUnsnap(
      LetterPosition(position: lastPosition, letter: lastLetter),
    );

    HapticFeedback.lightImpact();

    // Update path
    path.reset();
    if (selectedIndices.isNotEmpty) {
      path.moveTo(
        letterPositions[selectedIndices.first].dx,
        letterPositions[selectedIndices.first].dy,
      );

      for (int i = 1; i < selectedIndices.length; i++) {
        path.lineTo(
          letterPositions[selectedIndices[i]].dx,
          letterPositions[selectedIndices[i]].dy,
        );
      }
    }
  }

  // Trigger error animation
  void _triggerErrorAnimation() {
    shakeController.forward(from: 0.0);
    HapticFeedback.vibrate();
  }

  // Trigger success animation
  void _triggerSuccessAnimation() {
    successController.forward(from: 0.0).then((_) {
      successController.reverse();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        containerSize = Size(constraints.maxWidth, constraints.maxHeight);
        _calculatePositions(containerSize!);

        return AnimatedBuilder(
          animation: shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                shakeAnimation.value * sin(shakeController.value * 2 * pi),
                0,
              ),
              child: child,
            );
          },
          child: AnimatedBuilder(
            animation: successController,
            builder: (context, child) {
              return Transform.scale(
                scale: successScaleAnimation.value,
                child: child,
              );
            },
            child: Listener(
              onPointerDown: (event) => _handleTouchDown(event.localPosition),
              onPointerMove: (event) => _handleTouchMove(event.localPosition),
              onPointerUp: (event) => _handleTouchUp(),
              onPointerCancel: (event) => _handleTouchUp(),
              child: CustomPaint(
                painter: LetterConnectorPainter(
                  letters: widget.letters,
                  letterPositions: letterPositions,
                  letterHitboxes: letterHitboxes,
                  selectedIndices: selectedIndices,
                  currentPosition: currentPosition,
                  isDragging: isDragging,
                  path: path,
                  letterStyle: widget.letterStyle,
                  letterSize: widget.letterSize?.toDouble() ?? 50.0,
                  letterScaleAnimations: letterScaleAnimations,
                  borderColor: widget.borderColor,
                  selectedColor: widget.selectedColor ?? Colors.blue.shade600,
                  unselectedColor:
                      widget.unselectedColor ?? Colors.blue.shade200,
                  lineColor: widget.lineColor ?? Colors.blue.shade600,
                  textStyle: widget.textStyle,
                  showLettersBackground: widget.showLettersBackground,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LetterConnectorPainter extends CustomPainter {
  final List<String> letters;
  final List<Offset> letterPositions;
  final List<Rect> letterHitboxes;
  final List<int> selectedIndices;
  final Offset? currentPosition;
  final bool isDragging;
  final Path path;
  final LetterStyle letterStyle;
  final double letterSize;
  final List<Animation<double>> letterScaleAnimations;
  final Color? borderColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color lineColor;
  final TextStyle? textStyle;
  final bool showDebugHitboxes;
  final bool showLettersBackground;
  LetterConnectorPainter({
    required this.letters,
    required this.letterPositions,
    required this.letterHitboxes,
    required this.selectedIndices,
    required this.currentPosition,
    required this.isDragging,
    required this.path,
    required this.letterStyle,
    required this.letterSize,
    required this.letterScaleAnimations,
    required this.selectedColor,
    required this.unselectedColor,
    required this.lineColor,
    this.borderColor,
    this.textStyle,
    this.showDebugHitboxes = false,
    this.showLettersBackground = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background if wooden style
    if (showLettersBackground) _drawWoodenBackground(canvas, size);

    // Draw path lines first
    _drawPaths(canvas);

    // Draw debug hitboxes if enabled
    if (showDebugHitboxes) {
      _drawHitboxes(canvas);
    }

    // Draw letters on top
    _drawLetters(canvas);
  }

  void _drawWoodenBackground(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 - 30;

    // Wooden background circle
    final Paint woodPaint = Paint()
      ..color = const Color(0xFFe0b982)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius + 40, woodPaint);

    // Border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(center, radius + 40, borderPaint);

    // Inner circle with lighter color
    final Paint innerPaint = Paint()
      ..color = const Color(0xFFf0d8b6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius + 20, innerPaint);
  }

  void _drawHitboxes(Canvas canvas) {
    final Paint hitboxPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (final hitbox in letterHitboxes) {
      canvas.drawRect(hitbox, hitboxPaint);
    }
  }

  void _drawPaths(Canvas canvas) {
    final Paint pathPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw fixed path between selected letters
    canvas.drawPath(path, pathPaint);

    // Draw dynamic line from last letter to finger position
    if (isDragging && currentPosition != null && selectedIndices.isNotEmpty) {
      final lastIndex = selectedIndices.last;
      final lastPosition = letterPositions[lastIndex];

      final dynamicPath = Path()
        ..moveTo(lastPosition.dx, lastPosition.dy)
        ..lineTo(currentPosition!.dx, currentPosition!.dy);

      canvas.drawPath(dynamicPath, pathPaint);
    }
  }

  void _drawLetters(Canvas canvas) {
    for (int i = 0; i < letterPositions.length; i++) {
      final position = letterPositions[i];
      final letter = letters[i];
      final bool isSelected = selectedIndices.contains(i);
      final double scale = i < letterScaleAnimations.length
          ? letterScaleAnimations[i].value
          : 1.0;

      if (letterStyle == LetterStyle.woodenCircle) {
        _drawWoodenStyleLetter(canvas, letter, position, isSelected, scale);
      } else if (letterStyle == LetterStyle.circle) {
        _drawCircleLetter(canvas, letter, position, isSelected, scale);
      } else {
        _drawSquareLetter(canvas, letter, position, isSelected, scale);
      }
    }
  }

  void _drawWoodenStyleLetter(Canvas canvas, String letter, Offset position,
      bool isSelected, double scale) {
    final double bubbleSize = letterSize * scale;

    // Shadow for 3D effect (if not selected)
    if (!isSelected) {
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final Rect shadowRect = Rect.fromCenter(
        center: position.translate(2, 2),
        width: bubbleSize,
        height: bubbleSize,
      );

      final RRect roundedShadowRect = RRect.fromRectAndRadius(
        shadowRect,
        Radius.circular(bubbleSize / 4),
      );

      canvas.drawRRect(roundedShadowRect, shadowPaint);
    }

    // Letter background
    final Paint bubblePaint = Paint()
      ..color = isSelected ? selectedColor : unselectedColor
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCenter(
      center: position,
      width: bubbleSize,
      height: bubbleSize,
    );

    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(bubbleSize / 4),
    );

    canvas.drawRRect(roundedRect, bubblePaint);

    // Highlight effect for unselected letters
    if (!isSelected) {
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;

      final Path highlightPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + 2,
            rect.top + 2,
            rect.width - 4,
            rect.height / 3,
          ),
          Radius.circular(bubbleSize / 5),
        ));

      canvas.drawPath(highlightPath, highlightPaint);
    }

    // Border
    final Paint borderPaint = Paint()
      ..color = isSelected
          ? Colors.white.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 2.0;

    canvas.drawRRect(roundedRect, borderPaint);

    // Letter text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: textStyle ??
            TextStyle(
                fontSize: bubbleSize * 0.6,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  )
                ]),
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

  void _drawCircleLetter(Canvas canvas, String letter, Offset position,
      bool isSelected, double scale) {
    final double radius = letterSize * 0.5 * scale;

    // Circle
    final Paint circlePaint = Paint()
      ..color = isSelected ? selectedColor : unselectedColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, radius, circlePaint);

    // Border
    final Paint borderPaint = Paint()
      ..color = borderColor ?? Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(position, radius, borderPaint);

    // Letter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style:
            textStyle ?? TextStyle(fontSize: radius * 0.9, color: Colors.black),
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

  void _drawSquareLetter(Canvas canvas, String letter, Offset position,
      bool isSelected, double scale) {
    final double size = letterSize * scale;

    // Square
    final Paint squarePaint = Paint()
      ..color = isSelected ? selectedColor : unselectedColor
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCenter(
      center: position,
      width: size,
      height: size,
    );

    final RRect roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size / 8),
    );

    canvas.drawRRect(roundedRect, squarePaint);

    // Border
    final Paint borderPaint = Paint()
      ..color = borderColor ?? Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(roundedRect, borderPaint);

    // Letter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style:
            textStyle ?? TextStyle(fontSize: size * 0.5, color: Colors.black),
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

  @override
  bool shouldRepaint(covariant LetterConnectorPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.isDragging != isDragging ||
        !listEquals(oldDelegate.selectedIndices, selectedIndices);
  }

  bool listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
