import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../configuration/wheel_configuration.dart';

/// Utility class for wheel-related mathematical calculations
class WheelMath {
  /// Converts degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Converts radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Calculates the degree per slice
  static double degreePerSlice(int sliceCount) {
    return 360.0 / sliceCount;
  }

  /// Calculates the radian per slice
  static double radianPerSlice(int sliceCount) {
    return (2 * math.pi) / sliceCount;
  }

  /// Calculates the rotation angle for a specific slice index
  static double rotationForIndex(
    int index,
    int sliceCount,
    WheelStartPosition startPosition,
  ) {
    final sliceRadian = radianPerSlice(sliceCount);
    final startRadian = startPosition.radians;

    // Calculate rotation needed to position this slice at the top
    // We need to rotate the wheel so that the center of the target slice
    // aligns with the pin position (which is at startPosition)
    final targetRadian = (index * sliceRadian) + (sliceRadian / 2);

    return startRadian - targetRadian;
  }

  /// Gets the slice index at a specific rotation angle
  static int indexAtRotation(
    double rotation,
    int sliceCount,
    WheelStartPosition startPosition,
  ) {
    final sliceRadian = radianPerSlice(sliceCount);
    final startRadian = startPosition.radians;

    // Normalize rotation to 0-2π range
    var normalizedRotation = rotation % (2 * math.pi);
    if (normalizedRotation < 0) {
      normalizedRotation += 2 * math.pi;
    }

    // Adjust for start position
    var adjustedRotation = normalizedRotation - startRadian;
    if (adjustedRotation < 0) {
      adjustedRotation += 2 * math.pi;
    }

    // Calculate which slice this rotation points to
    final index = ((2 * math.pi - adjustedRotation) / sliceRadian).floor();

    return index % sliceCount;
  }

  /// Calculates the chord length (width) of a circular segment at a given distance from center
  static double chordLength(double radius, double distanceFromCenter, double angleRadians) {
    final effectiveRadius = radius - distanceFromCenter;
    return 2 * effectiveRadius * math.sin(angleRadians / 2);
  }

  /// Calculates the available width for content at a specific distance from center
  static double availableWidth(
    double radius,
    double distanceFromCenter,
    int sliceCount,
  ) {
    final sliceRadian = radianPerSlice(sliceCount);
    return chordLength(radius, distanceFromCenter, sliceRadian);
  }

  /// Calculates polar coordinates (angle, radius) from cartesian (x, y)
  static Offset cartesianToPolar(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final radius = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);
    return Offset(angle, radius);
  }

  /// Calculates cartesian coordinates (x, y) from polar (angle, radius)
  static Offset polarToCartesian(Offset center, double angle, double radius) {
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    return Offset(x, y);
  }

  /// Normalizes an angle to be within 0 to 2π range
  static double normalizeAngle(double angle) {
    var normalized = angle % (2 * math.pi);
    if (normalized < 0) {
      normalized += 2 * math.pi;
    }
    return normalized;
  }

  /// Calculates the shortest angular distance between two angles
  static double angularDistance(double from, double to) {
    final diff = normalizeAngle(to - from);
    return diff > math.pi ? diff - 2 * math.pi : diff;
  }
}
