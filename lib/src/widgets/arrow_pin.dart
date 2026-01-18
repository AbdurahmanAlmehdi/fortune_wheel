import 'package:flutter/material.dart';

/// Custom arrow pin widget that looks like a classic arrow pointer
class ArrowPin extends StatelessWidget {
  /// Color of the arrow
  final Color color;

  /// Size of the arrow
  final Size size;

  /// Border color of the arrow
  final Color? borderColor;

  /// Border width of the arrow
  final double borderWidth;

  /// Whether to add a shadow
  final bool withShadow;

  const ArrowPin({
    super.key,
    this.color = Colors.red,
    this.size = const Size(40, 50),
    this.borderColor,
    this.borderWidth = 2.0,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _ArrowPainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        withShadow: withShadow,
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final bool withShadow;

  _ArrowPainter({
    required this.color,
    this.borderColor,
    required this.borderWidth,
    required this.withShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createArrowPath(size);

    // Draw shadow if enabled
    if (withShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.save();
      canvas.translate(0, 2);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // Draw border if specified
    if (borderColor != null && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, borderPaint);
    }

    // Draw arrow fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  /// Creates the arrow path
  Path _createArrowPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start at top center (arrow point)
    path.moveTo(width / 2, 0);

    // Right side of arrow point
    path.lineTo(width * 0.75, height * 0.4);

    // Inner right edge
    path.lineTo(width * 0.6, height * 0.4);

    // Bottom right
    path.lineTo(width * 0.6, height);

    // Bottom left
    path.lineTo(width * 0.4, height);

    // Inner left edge
    path.lineTo(width * 0.4, height * 0.4);

    // Left side of arrow point
    path.lineTo(width * 0.25, height * 0.4);

    // Close path back to top
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.withShadow != withShadow;
  }
}

/// Triangle arrow pin widget - simpler design
class TriangleArrowPin extends StatelessWidget {
  /// Color of the arrow
  final Color color;

  /// Size of the arrow
  final Size size;

  /// Border color of the arrow
  final Color? borderColor;

  /// Border width of the arrow
  final double borderWidth;

  /// Whether to add a shadow
  final bool withShadow;

  const TriangleArrowPin({
    super.key,
    this.color = Colors.red,
    this.size = const Size(30, 40),
    this.borderColor,
    this.borderWidth = 2.0,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _TriangleArrowPainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        withShadow: withShadow,
      ),
    );
  }
}

class _TriangleArrowPainter extends CustomPainter {
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final bool withShadow;

  _TriangleArrowPainter({
    required this.color,
    this.borderColor,
    required this.borderWidth,
    required this.withShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Create triangle pointing down
    path.moveTo(size.width / 2, size.height); // Bottom point
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    // Draw shadow if enabled
    if (withShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.save();
      canvas.translate(0, 2);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // Draw border if specified
    if (borderColor != null && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, borderPaint);
    }

    // Draw arrow fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(_TriangleArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.withShadow != withShadow;
  }
}
