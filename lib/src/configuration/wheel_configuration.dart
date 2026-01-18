import 'package:flutter/material.dart';

/// Main configuration for the fortune wheel
class WheelConfiguration {
  /// Preferences for the wheel circle
  final CirclePreferences circlePreferences;

  /// Preferences for slices
  final SlicePreferences slicePreferences;

  /// Start position of the first slice
  final WheelStartPosition startPosition;

  /// Padding to prevent clipping of effects (shadows, glows)
  final EdgeInsets layerInsets;

  /// Internal padding within slices
  final EdgeInsets contentMargins;

  const WheelConfiguration({
    this.circlePreferences = const CirclePreferences(),
    this.slicePreferences = const SlicePreferences(),
    this.startPosition = WheelStartPosition.top,
    this.layerInsets = const EdgeInsets.all(10),
    this.contentMargins = const EdgeInsets.all(8),
  });
}

/// Preferences for the outer circle of the wheel
class CirclePreferences {
  /// Stroke width of the outer circle
  final double strokeWidth;

  /// Color of the outer circle stroke
  final Color strokeColor;

  /// Configuration for border dots
  final BorderDotsConfiguration? borderDots;

  /// Configuration for center indicator
  final CenterIndicatorConfiguration? centerIndicator;

  const CirclePreferences({
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.black,
    this.borderDots,
    this.centerIndicator,
  });
}

/// Configuration for dots on the wheel border
class BorderDotsConfiguration {
  /// Size (radius) of each dot
  final double dotSize;

  /// Color of the dots
  final Color dotColor;

  /// Number of dots per slice (if null, uses one dot per slice)
  final int? dotsPerSlice;

  /// Border color around each dot
  final Color? dotBorderColor;

  /// Border width around each dot
  final double dotBorderWidth;

  const BorderDotsConfiguration({
    this.dotSize = 6.0,
    this.dotColor = Colors.white,
    this.dotsPerSlice,
    this.dotBorderColor,
    this.dotBorderWidth = 2.0,
  });
}

/// Configuration for center indicator
class CenterIndicatorConfiguration {
  /// Radius of the center circle
  final double radius;

  /// Color of the center circle
  final Color color;

  /// Border color of the center circle
  final Color? borderColor;

  /// Border width of the center circle
  final double borderWidth;

  /// Optional widget to display in the center (like text or icon)
  final Widget? child;

  const CenterIndicatorConfiguration({
    this.radius = 30.0,
    this.color = Colors.white,
    this.borderColor,
    this.borderWidth = 3.0,
    this.child,
  });
}

/// Preferences for how slices are drawn
class SlicePreferences {
  /// Stroke width between slices
  final double strokeWidth;

  /// Color of stroke between slices
  final Color strokeColor;

  /// Default background colors when slice doesn't specify one
  final SliceBackgroundColors? backgroundColors;

  const SlicePreferences({
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.white,
    this.backgroundColors,
  });
}

/// Background color patterns for slices
class SliceBackgroundColors {
  /// Pattern type
  final ColorPattern pattern;

  /// Colors to use based on pattern
  final List<Color> colors;

  const SliceBackgroundColors({
    required this.pattern,
    required this.colors,
  }) : assert(colors.length > 0, 'Must provide at least one color');

  /// Creates even-odd color pattern
  factory SliceBackgroundColors.evenOdd({
    required Color evenColor,
    required Color oddColor,
  }) {
    return SliceBackgroundColors(
      pattern: ColorPattern.evenOdd,
      colors: [evenColor, oddColor],
    );
  }

  /// Creates custom repeating color pattern
  factory SliceBackgroundColors.custom({
    required List<Color> colors,
  }) {
    return SliceBackgroundColors(
      pattern: ColorPattern.custom,
      colors: colors,
    );
  }

  /// Gets the color for a specific slice index
  Color getColorForIndex(int index) {
    switch (pattern) {
      case ColorPattern.evenOdd:
        return index.isEven ? colors[0] : colors[1];
      case ColorPattern.custom:
        return colors[index % colors.length];
    }
  }
}

/// Color pattern types
enum ColorPattern {
  evenOdd,
  custom,
}

/// Start position of the wheel
enum WheelStartPosition {
  top, // 0 degrees
  right, // 90 degrees
  bottom, // 180 degrees
  left, // 270 degrees
}

/// Extension to convert start position to radians
extension WheelStartPositionExtension on WheelStartPosition {
  double get radians {
    switch (this) {
      case WheelStartPosition.top:
        return 0.0;
      case WheelStartPosition.right:
        return 1.5708; // π/2
      case WheelStartPosition.bottom:
        return 3.14159; // π
      case WheelStartPosition.left:
        return 4.71239; // 3π/2
    }
  }
}
