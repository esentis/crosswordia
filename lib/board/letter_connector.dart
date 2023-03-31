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
    required this.onLetterSelected,
    required this.onUnsnap,
    required this.onCompleted,
    this.letterStyle = LetterStyle.circle,
    this.distanceOfLetters,
    this.letterSize,
    this.borderColor,
    super.key,
  });
  final List<String> letters;
  final Function(String letter) onLetterSelected;
  final Function(List<String> allSelectedLetters) onCompleted;
  final VoidCallback onUnsnap;
  final LetterStyle letterStyle;
  final num? distanceOfLetters;
  final num? letterSize;
  final Color? borderColor;
  @override
  State<StatefulWidget> createState() => _LetterConnectorState();
}

class _LetterConnectorState extends State<LetterConnector> {
  List<Offset> letterPositions = [];
  List<String> get letters => widget.letters;

  Path path = Path();
  List<int> snappedLettersIndexes = [];
  List<String> snappedLetters = [];
  Offset? currentOffset;
  int lastSnappedLetter = -1;
  bool insideLetter = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: CustomPaint(
        painter: _LetterConnectPainter(
          letterPositions: letterPositions,
          letters: letters,
          snappedLetters: snappedLettersIndexes,
          letterSize: widget.letterSize,
          path: path,
          borderColor: widget.borderColor,
          currentOffset: currentOffset,
          currentIndex:
              _getLetterIndexAtOffset(currentOffset ?? const Offset(0, 0)),
          letterStyle: widget.letterStyle,
          distanceOfLetters: widget.distanceOfLetters,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  void _startDrawing(Offset localPosition) {
    int index = _getLetterIndexAtOffset(localPosition);

    if (index != -1 && !insideLetter) {
      kLog.d(
          'Drawing path from $index\n${letterPositions[index].dx}, ${letterPositions[index].dy}');
      path.moveTo(letterPositions[index].dx, letterPositions[index].dy);
      insideLetter = true;
      _snapLetter(index);
      currentOffset = localPosition;
    } else {
      insideLetter = false;
      currentOffset = null;
    }
  }

  void _snapLetter(int index) {
    snappedLetters.add(letters[index]);
    snappedLettersIndexes.add(index);
    lastSnappedLetter = index;
    widget.onLetterSelected(letters[index]);
  }

  void _unsnapLastLetter() {
    snappedLetters.removeLast();
    snappedLettersIndexes.removeLast();
    lastSnappedLetter =
        snappedLettersIndexes.isNotEmpty ? snappedLettersIndexes.last : -1;

    widget.onUnsnap();
  }

  void _updateDrawing(Offset localPosition) {
    int index = _getLetterIndexAtOffset(localPosition);

    if (index != -1 && index != lastSnappedLetter && !insideLetter) {
      insideLetter = true;
      if (!snappedLettersIndexes.contains(index)) {
        if (snappedLettersIndexes.isEmpty) {
          path.moveTo(letterPositions[index].dx, letterPositions[index].dy);
        } else {
          path.lineTo(letterPositions[index].dx, letterPositions[index].dy);
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
        path.moveTo(letterPositions[snappedLettersIndexes[0]].dx,
            letterPositions[snappedLettersIndexes[0]].dy);
        for (int i = 1; i < snappedLettersIndexes.length; i++) {
          path.lineTo(letterPositions[snappedLettersIndexes[i]].dx,
              letterPositions[snappedLettersIndexes[i]].dy);
        }
      } else if (snappedLettersIndexes.length == 1) {
        // Move to the first letter when there's only one letter left
        path = Path();
        path.moveTo(letterPositions[snappedLettersIndexes[0]].dx,
            letterPositions[snappedLettersIndexes[0]].dy);
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
  }

  int _getLetterIndexAtOffset(Offset offset) {
    for (int i = 0; i < letterPositions.length; i++) {
      if ((offset - letterPositions[i]).distance <= 20) {
        return i;
      }
    }
    return -1;
  }
}

class _LetterConnectPainter extends CustomPainter {
  final List<Offset> letterPositions;
  final List<String> letters;
  final List<int> snappedLetters;
  final Path path;
  final Offset? currentOffset;
  final int currentIndex;
  final LetterStyle letterStyle;
  final num? distanceOfLetters;
  final num? letterSize;
  final Color? borderColor;
  _LetterConnectPainter({
    required this.letterPositions,
    required this.letters,
    required this.path,
    required this.currentOffset,
    required this.snappedLetters,
    required this.currentIndex,
    required this.letterStyle,
    this.distanceOfLetters,
    this.letterSize,
    this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawPath(canvas);
    _drawCircularLetters(canvas, size);
  }

  void _drawCircularLetters(Canvas canvas, Size size) {
    double radius =
        distanceOfLetters?.toDouble() ?? min(size.width, size.height) / 2 - 70;
    Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < letters.length; i++) {
      double angle = (2 * pi / letters.length) * i;
      double dx = center.dx + radius * cos(angle);
      double dy = center.dy + radius * sin(angle);
      Offset position = Offset(dx, dy);

      if (letterPositions.length < letters.length) {
        letterPositions.add(position);
      }

      Color color = snappedLetters.contains(i) ? Colors.red : Colors.white;
      letterStyle == LetterStyle.circle
          ? _drawLetterInCircle(canvas, letters[i], position, color)
          : _drawLetterInSquare(canvas, letters[i], position, color);
    }
  }

// SQUARE LETTER
  void _drawLetterInSquare(
      Canvas canvas, String letter, Offset position, Color color) {
    double squareSize = letterSize?.toDouble() ?? 50.0;

    // Draw the square
    Paint squarePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
    Rect rect = Rect.fromCenter(
        center: position, width: squareSize, height: squareSize);
    RRect roundedRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(roundedRect, squarePaint);

    // Draw the border
    Paint borderPaint = Paint()
      ..color =
          borderColor ?? Colors.black // Set your desired border color here
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(roundedRect, borderPaint);

    // Draw the letter
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawLetterInCircle(
      Canvas canvas, String letter, Offset position, Color color) {
    double circleRadius =
        letterSize?.toDouble() ?? 25.0; // Half of the previous squareSize

    // Draw the filled circle
    Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, circleRadius, circlePaint);

    // Draw the border
    Paint borderPaint = Paint()
      ..color =
          borderColor ?? Colors.black // Set your desired border color here
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(position, circleRadius, borderPaint);

    // Draw the letter
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(fontSize: 24, color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawPath(Canvas canvas) {
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    if (currentOffset != null &&
        (snappedLetters.isEmpty ? currentIndex != -1 : true)) {
      Path newPath = Path.from(path);
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
