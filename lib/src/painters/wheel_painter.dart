import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/slice.dart';
import '../models/content_type.dart';
import '../configuration/wheel_configuration.dart';
import '../utils/wheel_math.dart';

/// CustomPainter that draws the fortune wheel
class WheelPainter extends CustomPainter {
  final List<Slice> slices;
  final WheelConfiguration configuration;
  final double rotation;

  WheelPainter({
    required this.slices,
    required this.configuration,
    this.rotation = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) -
        configuration.layerInsets.top;

    // Apply rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw each slice
    final sliceCount = slices.length;
    final sliceAngle = WheelMath.radianPerSlice(sliceCount);

    for (int i = 0; i < sliceCount; i++) {
      _drawSlice(
        canvas,
        center,
        radius,
        i,
        sliceAngle,
        slices[i],
      );
    }

    canvas.restore();

    // Draw outer circle
    _drawOuterCircle(canvas, center, radius);

    // Draw border dots (not rotated, so drawn after canvas.restore())
    if (configuration.circlePreferences.borderDots != null) {
      _drawBorderDots(canvas, center, radius, sliceCount);
    }

    // Draw center indicator (not rotated, so drawn after canvas.restore())
    if (configuration.circlePreferences.centerIndicator != null) {
      _drawCenterIndicator(canvas, center);
    }
  }

  /// Draws a single slice
  void _drawSlice(
    Canvas canvas,
    Offset center,
    double radius,
    int index,
    double sliceAngle,
    Slice slice,
  ) {
    final startAngle = configuration.startPosition.radians + (index * sliceAngle);
    final sweepAngle = sliceAngle;

    // Create slice path
    final path = _createSlicePath(center, radius, startAngle, sweepAngle);

    // Draw background
    _drawSliceBackground(canvas, path, slice, index);

    // Draw slice border
    _drawSliceBorder(canvas, path);

    // Draw content
    _drawSliceContent(
      canvas,
      center,
      radius,
      startAngle,
      sweepAngle,
      slice,
    );
  }

  /// Creates the path for a slice (pie wedge shape)
  Path _createSlicePath(
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.close();
    return path;
  }

  /// Draws the background of a slice
  void _drawSliceBackground(
    Canvas canvas,
    Path path,
    Slice slice,
    int index,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (slice.gradient != null) {
      // Gradient background
      final rect = path.getBounds();
      paint.shader = slice.gradient!.createShader(rect);
    } else if (slice.backgroundColor != null) {
      // Solid color background
      paint.color = slice.backgroundColor!;
    } else if (configuration.slicePreferences.backgroundColors != null) {
      // Use default color pattern
      paint.color = configuration.slicePreferences.backgroundColors!
          .getColorForIndex(index);
    } else {
      // No background
      return;
    }

    canvas.drawPath(path, paint);

    // TODO: Background image support (requires async image loading)
  }

  /// Draws the border of a slice
  void _drawSliceBorder(Canvas canvas, Path path) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = configuration.slicePreferences.strokeColor
      ..strokeWidth = configuration.slicePreferences.strokeWidth;

    canvas.drawPath(path, paint);
  }

  /// Draws the outer circle border
  void _drawOuterCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = configuration.circlePreferences.strokeColor
      ..strokeWidth = configuration.circlePreferences.strokeWidth;

    canvas.drawCircle(center, radius, paint);
  }

  /// Draws content within a slice
  void _drawSliceContent(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Slice slice,
  ) {
    if (slice.contents.isEmpty) return;

    // Calculate the center angle of this slice
    final centerAngle = startAngle + (sweepAngle / 2);

    // Calculate total height needed for all content
    final contentMargins = configuration.contentMargins;
    final availableRadius = radius - contentMargins.top - contentMargins.bottom;

    // Divide available space equally among content items
    final itemCount = slice.contents.length;
    final radiusPerItem = availableRadius / itemCount;

    // Draw each content item from outside to inside
    for (int i = 0; i < slice.contents.length; i++) {
      final content = slice.contents[i];
      final distanceFromCenter = contentMargins.top + (i * radiusPerItem) + (radiusPerItem / 2);

      _drawContent(
        canvas,
        center,
        radius,
        centerAngle,
        sweepAngle,
        distanceFromCenter,
        content,
      );
    }
  }

  /// Draws a single content item
  void _drawContent(
    Canvas canvas,
    Offset center,
    double radius,
    double centerAngle,
    double sweepAngle,
    double distanceFromCenter,
    SliceContent content,
  ) {
    if (content is TextContent) {
      _drawTextContent(
        canvas,
        center,
        radius,
        centerAngle,
        sweepAngle,
        distanceFromCenter,
        content,
      );
    } else if (content is ImageContent) {
      _drawImageContent(
        canvas,
        center,
        centerAngle,
        distanceFromCenter,
        content,
      );
    } else if (content is LineContent) {
      _drawLineContent(
        canvas,
        center,
        radius,
        centerAngle,
        distanceFromCenter,
        content,
      );
    }
  }

  /// Draws text content
  void _drawTextContent(
    Canvas canvas,
    Offset center,
    double radius,
    double centerAngle,
    double sweepAngle,
    double distanceFromCenter,
    TextContent content,
  ) {
    final textStyle = content.style ?? const TextStyle(fontSize: 16, color: Colors.black);

    // Check if text should be flipped to prevent upside-down rendering
    final shouldFlip = content.flipUpsideDown &&
        _isUpsideDown(centerAngle);

    canvas.save();

    // Determine rendering mode (backwards compatible with deprecated isCurved)
    final bool useCurvedText;
    if (content.textMode == SliceTextMode.auto) {
      // Auto mode: decide based on available space
      useCurvedText = _shouldUseCurvedText(
        content.text,
        textStyle,
        sweepAngle,
        radius - distanceFromCenter,
      );
    } else if (content.textMode == SliceTextMode.curved) {
      useCurvedText = true;
    } else if (content.textMode == SliceTextMode.horizontal) {
      useCurvedText = false;
    } else {
      // Fallback to deprecated isCurved property
      useCurvedText = content.isCurved;
    }

    if (useCurvedText && content.orientation == TextOrientation.horizontal) {
      // Curved text using the curved_text package
      _drawCurvedText(
        canvas,
        center,
        radius,
        centerAngle,
        sweepAngle,
        distanceFromCenter,
        content,
        textStyle,
        shouldFlip,
      );
    } else if (content.orientation == TextOrientation.horizontal) {
      // Straight horizontal text
      _drawStraightText(
        canvas,
        center,
        centerAngle,
        distanceFromCenter,
        content,
        textStyle,
        shouldFlip,
      );
    } else {
      // Vertical text
      _drawVerticalText(
        canvas,
        center,
        centerAngle,
        distanceFromCenter,
        content,
        textStyle,
        shouldFlip,
      );
    }

    canvas.restore();
  }

  /// Determines if curved text should be used based on available space
  bool _shouldUseCurvedText(
    String text,
    TextStyle textStyle,
    double sliceAngle,
    double textRadius,
  ) {
    // Measure text width
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate required arc angle for the text
    final requiredArcAngle = textPainter.width / textRadius;

    // Use 90% of slice angle as available space (10% margin)
    final availableArcAngle = sliceAngle * 0.9;

    // Use curved text only if it fits comfortably
    // Additional heuristics:
    // - Very small slices (< 15°) → always horizontal
    // - Text too long (> 10 chars in small slice) → horizontal
    final sliceDegrees = WheelMath.radiansToDegrees(sliceAngle);

    if (sliceDegrees < 15) {
      return false; // Too small, always use horizontal
    }

    if (sliceDegrees < 30 && text.length > 5) {
      return false; // Medium slice with long text
    }

    return requiredArcAngle <= availableArcAngle;
  }

  /// Draws curved text following the circular arc
  void _drawCurvedText(
    Canvas canvas,
    Offset center,
    double radius,
    double centerAngle,
    double sweepAngle,
    double distanceFromCenter,
    TextContent content,
    TextStyle textStyle,
    bool shouldFlip,
  ) {
    // Position calculation for curved text
    final textRadius = radius - distanceFromCenter;

    // Create text painter to measure text
    final textPainter = TextPainter(
      text: TextSpan(text: content.text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate arc angle needed for the text
    final textWidth = textPainter.width;
    final arcAngle = textWidth / textRadius;

    // FIX: Constrain arc angle to slice boundaries (use 90% for padding)
    final maxArcAngle = sweepAngle * 0.9;
    final constrainedArcAngle = math.min(arcAngle, maxArcAngle);

    // Adjust starting angle to center the text
    var startAngle = centerAngle - (constrainedArcAngle / 2);

    // Flip if upside down
    if (shouldFlip) {
      startAngle += math.pi;
    }

    canvas.translate(center.dx, center.dy);
    canvas.rotate(startAngle);

    // Use curved_text package functionality (simplified version)
    // Note: For production, you'd integrate the curved_text package properly
    // For now, we'll use a character-by-character approach
    _drawCharacterByCharacterCurved(
      canvas,
      content.text,
      textStyle,
      textRadius,
      constrainedArcAngle,
    );

    canvas.rotate(-startAngle);
    canvas.translate(-center.dx, -center.dy);
  }

  /// Draws text character by character along a curve
  void _drawCharacterByCharacterCurved(
    Canvas canvas,
    String text,
    TextStyle textStyle,
    double radius,
    double totalAngle,
  ) {
    final anglePerChar = totalAngle / text.length;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charAngle = anglePerChar * i;

      canvas.save();
      canvas.rotate(charAngle);
      canvas.translate(0, -radius);

      final textPainter = TextPainter(
        text: TextSpan(text: char, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  /// Draws straight horizontal text
  void _drawStraightText(
    Canvas canvas,
    Offset center,
    double centerAngle,
    double distanceFromCenter,
    TextContent content,
    TextStyle textStyle,
    bool shouldFlip,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: content.text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: content.alignment,
    )..layout();

    final textRadius = distanceFromCenter;
    final position = WheelMath.polarToCartesian(center, centerAngle, textRadius);

    canvas.translate(position.dx, position.dy);

    // FIX: Correct rotation calculation to align with slice orientation
    // The centerAngle already includes startPosition offset, so we compensate
    // to get the natural slice-relative rotation, then add π/2 to point "up"
    var rotationAngle = centerAngle - configuration.startPosition.radians + (math.pi / 2);
    if (shouldFlip) {
      rotationAngle += math.pi;
    }

    canvas.rotate(rotationAngle);

    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2 + content.horizontalOffset,
        -textPainter.height / 2 + content.verticalOffset,
      ),
    );

    canvas.rotate(-rotationAngle);
    canvas.translate(-position.dx, -position.dy);
  }

  /// Draws vertical text
  void _drawVerticalText(
    Canvas canvas,
    Offset center,
    double centerAngle,
    double distanceFromCenter,
    TextContent content,
    TextStyle textStyle,
    bool shouldFlip,
  ) {
    // Similar to straight text but rotated 90 degrees more
    final textPainter = TextPainter(
      text: TextSpan(text: content.text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: content.alignment,
    )..layout();

    final textRadius = distanceFromCenter;
    final position = WheelMath.polarToCartesian(center, centerAngle, textRadius);

    canvas.translate(position.dx, position.dy);

    var rotationAngle = centerAngle + (math.pi / 2) + (math.pi / 2); // Extra 90 degrees
    if (shouldFlip) {
      rotationAngle += math.pi;
    }

    canvas.rotate(rotationAngle);

    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2 + content.horizontalOffset,
        -textPainter.height / 2 + content.verticalOffset,
      ),
    );

    canvas.rotate(-rotationAngle);
    canvas.translate(-position.dx, -position.dy);
  }

  /// Draws image content
  void _drawImageContent(
    Canvas canvas,
    Offset center,
    double centerAngle,
    double distanceFromCenter,
    ImageContent content,
  ) {
    // Note: Image drawing requires the image to be loaded first
    // This would typically be done asynchronously before painting
    // For now, this is a placeholder for the image drawing logic

    // TODO: Implement image drawing once image is loaded
    // This would involve:
    // 1. Loading the image asynchronously
    // 2. Caching the loaded image
    // 3. Drawing it here with proper rotation and positioning
  }

  /// Draws line content
  void _drawLineContent(
    Canvas canvas,
    Offset center,
    double radius,
    double centerAngle,
    double distanceFromCenter,
    LineContent content,
  ) {
    final paint = Paint()
      ..color = content.color
      ..strokeWidth = content.width
      ..style = PaintingStyle.stroke;

    if (content.type == LineType.dashed) {
      paint.strokeCap = StrokeCap.round;
      // Dashed line implementation would go here
    }

    final lineRadius = radius - distanceFromCenter;
    final lineLength = lineRadius * 0.8; // 80% of available radius

    final startPos = WheelMath.polarToCartesian(
      center,
      centerAngle,
      distanceFromCenter + content.verticalOffset,
    );
    final endPos = WheelMath.polarToCartesian(
      center,
      centerAngle,
      distanceFromCenter + lineLength + content.verticalOffset,
    );

    canvas.drawLine(startPos, endPos, paint);
  }

  /// Checks if an angle would render text upside down
  bool _isUpsideDown(double angle) {
    final normalized = WheelMath.normalizeAngle(angle);
    return normalized > math.pi / 2 && normalized < (3 * math.pi / 2);
  }

  /// Draws border dots around the wheel edge
  void _drawBorderDots(
    Canvas canvas,
    Offset center,
    double radius,
    int sliceCount,
  ) {
    final dotsConfig = configuration.circlePreferences.borderDots!;

    // Determine number of dots
    final dotsPerSlice = dotsConfig.dotsPerSlice ?? 1;
    final totalDots = sliceCount * dotsPerSlice;
    final anglePerDot = (2 * math.pi) / totalDots;

    for (int i = 0; i < totalDots; i++) {
      // Calculate angle for this dot
      // If dotsPerSlice is 1, dots will be at slice boundaries
      // If dotsPerSlice > 1, dots will be distributed within each slice
      final dotAngle = configuration.startPosition.radians + (i * anglePerDot);

      // Calculate dot position on the wheel edge
      final dotPosition = WheelMath.polarToCartesian(
        center,
        dotAngle,
        radius,
      );

      // Draw dot border if specified
      if (dotsConfig.dotBorderColor != null && dotsConfig.dotBorderWidth > 0) {
        final borderPaint = Paint()
          ..color = dotsConfig.dotBorderColor!
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          dotPosition,
          dotsConfig.dotSize + dotsConfig.dotBorderWidth,
          borderPaint,
        );
      }

      // Draw dot
      final dotPaint = Paint()
        ..color = dotsConfig.dotColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotPosition, dotsConfig.dotSize, dotPaint);
    }
  }

  /// Draws center indicator circle
  void _drawCenterIndicator(Canvas canvas, Offset center) {
    final centerConfig = configuration.circlePreferences.centerIndicator!;

    // Draw border if specified
    if (centerConfig.borderColor != null && centerConfig.borderWidth > 0) {
      final borderPaint = Paint()
        ..color = centerConfig.borderColor!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        center,
        centerConfig.radius + centerConfig.borderWidth,
        borderPaint,
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = centerConfig.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centerConfig.radius, centerPaint);
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.slices != slices ||
        oldDelegate.configuration != configuration;
  }
}
