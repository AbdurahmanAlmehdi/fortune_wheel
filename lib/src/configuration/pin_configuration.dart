import 'package:flutter/material.dart';

/// Configuration for the pin/pointer indicator
class PinConfiguration {
  /// Size of the pin
  final Size size;

  /// Position of the pin relative to the wheel
  final PinPosition position;

  /// Horizontal offset from default position
  final double horizontalOffset;

  /// Vertical offset from default position
  final double verticalOffset;

  /// Background color of the pin
  final Color? backgroundColor;

  /// Tint color for the pin icon/image
  final Color? tintColor;

  /// Custom widget to use as pin (overrides icon/image)
  final Widget? customWidget;

  /// Icon to use as pin
  final IconData? icon;

  /// Image to use as pin
  final ImageProvider? image;

  const PinConfiguration({
    this.size = const Size(40, 40),
    this.position = PinPosition.top,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
    this.backgroundColor,
    this.tintColor,
    this.customWidget,
    this.icon,
    this.image,
  }) : assert(
          customWidget != null || icon != null || image != null,
          'Must provide either customWidget, icon, or image for pin',
        );

  /// Creates a pin with an icon
  factory PinConfiguration.icon({
    required IconData icon,
    Size size = const Size(40, 40),
    PinPosition position = PinPosition.top,
    Color? color,
    Color? backgroundColor,
    double horizontalOffset = 0.0,
    double verticalOffset = 0.0,
  }) {
    return PinConfiguration(
      icon: icon,
      size: size,
      position: position,
      tintColor: color,
      backgroundColor: backgroundColor,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
    );
  }

  /// Creates a pin with an image
  factory PinConfiguration.image({
    required ImageProvider image,
    Size size = const Size(40, 40),
    PinPosition position = PinPosition.top,
    Color? tintColor,
    Color? backgroundColor,
    double horizontalOffset = 0.0,
    double verticalOffset = 0.0,
  }) {
    return PinConfiguration(
      image: image,
      size: size,
      position: position,
      tintColor: tintColor,
      backgroundColor: backgroundColor,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
    );
  }

  /// Creates a pin with a custom widget
  factory PinConfiguration.custom({
    required Widget widget,
    Size size = const Size(40, 40),
    PinPosition position = PinPosition.top,
    double horizontalOffset = 0.0,
    double verticalOffset = 0.0,
  }) {
    return PinConfiguration(
      customWidget: widget,
      size: size,
      position: position,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
    );
  }
}

/// Position of the pin relative to the wheel
enum PinPosition {
  top,
  right,
  bottom,
  left,
}

/// Extension to get angle offset for pin position
extension PinPositionExtension on PinPosition {
  double get radians {
    switch (this) {
      case PinPosition.top:
        return 0.0;
      case PinPosition.right:
        return 1.5708; // π/2
      case PinPosition.bottom:
        return 3.14159; // π
      case PinPosition.left:
        return 4.71239; // 3π/2
    }
  }
}
