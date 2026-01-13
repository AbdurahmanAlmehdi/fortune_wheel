import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/slice.dart';
import '../configuration/wheel_configuration.dart';
import '../configuration/pin_configuration.dart';
import '../painters/wheel_painter.dart';
import '../utils/wheel_math.dart';

/// Callback for spin events
typedef SpinCallback = void Function();

/// Callback for collision events with progress (0.0 to 1.0)
typedef CollisionCallback = void Function(double? progress);

/// Callback for slice selection
typedef SliceCallback = void Function(int index);

/// Main Fortune Wheel widget with advanced animation and backend integration
class FortuneWheel extends StatefulWidget {
  /// List of slices to display in the wheel
  final List<Slice> slices;

  /// Configuration for the wheel appearance
  final WheelConfiguration? configuration;

  /// Configuration for the pin indicator
  final PinConfiguration? pinConfiguration;

  /// Whether to show the pin indicator
  final bool showPin;

  /// Callback when wheel is tapped (returns slice index)
  final SliceCallback? onSliceTap;

  /// Callback when edge collision is detected
  final CollisionCallback? onEdgeCollision;

  /// Callback when center collision is detected
  final CollisionCallback? onCenterCollision;

  /// Initial rotation in radians
  final double initialRotation;

  /// Enable edge collision detection
  final bool edgeCollisionDetection;

  /// Enable center collision detection
  final bool centerCollisionDetection;

  /// Duration for rotation animations
  final Duration animationDuration;

  /// Curve for rotation animations
  final Curve animationCurve;

  const FortuneWheel({
    super.key,
    required this.slices,
    this.configuration,
    this.pinConfiguration,
    this.showPin = true,
    this.onSliceTap,
    this.onEdgeCollision,
    this.onCenterCollision,
    this.initialRotation = 0.0,
    this.edgeCollisionDetection = false,
    this.centerCollisionDetection = false,
    this.animationDuration = const Duration(seconds: 5),
    this.animationCurve = Curves.easeOutCubic,
  })  : assert(slices.length > 0, 'Must have at least one slice');

  @override
  State<FortuneWheel> createState() => FortuneWheelState();
}

/// State for FortuneWheel - exposed to allow external control
class FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0.0;
  bool _isSpinning = false;
  Ticker? _collisionTicker;
  final Set<int> _detectedEdges = {};
  final Set<int> _detectedCenters = {};

  @override
  void initState() {
    super.initState();
    _currentRotation = widget.initialRotation;

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ))
      ..addListener(_onAnimationUpdate)
      ..addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _collisionTicker?.dispose();
    super.dispose();
  }

  /// Called on each animation frame
  void _onAnimationUpdate() {
    setState(() {
      _currentRotation = _rotationAnimation.value;
    });

    // Check for collisions if enabled
    if (_isSpinning) {
      _checkCollisions();
    }
  }

  /// Called when animation status changes
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isSpinning = false;
      });
      _stopCollisionDetection();
    }
  }

  /// Checks for edge and center collisions
  void _checkCollisions() {
    final sliceCount = widget.slices.length;
    final sliceRadian = WheelMath.radianPerSlice(sliceCount);
    final currentIndex = WheelMath.indexAtRotation(
      _currentRotation,
      sliceCount,
      widget.configuration?.startPosition ?? WheelStartPosition.top,
    );

    // Calculate progress (0.0 to 1.0) if animation is running
    final progress = _animationController.isAnimating
        ? _animationController.value
        : null;

    // Edge collision detection
    if (widget.edgeCollisionDetection && widget.onEdgeCollision != null) {
      // Check if we crossed a slice boundary
      final normalizedRotation = WheelMath.normalizeAngle(_currentRotation);
      final slicePosition = (normalizedRotation % sliceRadian) / sliceRadian;

      // Trigger on edge crossing (when position is near 0 or 1)
      if (slicePosition < 0.05 || slicePosition > 0.95) {
        if (!_detectedEdges.contains(currentIndex)) {
          _detectedEdges.add(currentIndex);
          widget.onEdgeCollision!(progress);
        }
      } else {
        _detectedEdges.remove(currentIndex);
      }
    }

    // Center collision detection
    if (widget.centerCollisionDetection && widget.onCenterCollision != null) {
      final normalizedRotation = WheelMath.normalizeAngle(_currentRotation);
      final slicePosition = (normalizedRotation % sliceRadian) / sliceRadian;

      // Trigger when passing through slice center (position around 0.5)
      if (slicePosition > 0.45 && slicePosition < 0.55) {
        if (!_detectedCenters.contains(currentIndex)) {
          _detectedCenters.add(currentIndex);
          widget.onCenterCollision!(progress);
        }
      } else {
        _detectedCenters.remove(currentIndex);
      }
    }
  }

  /// Starts collision detection
  void _startCollisionDetection() {
    _detectedEdges.clear();
    _detectedCenters.clear();
  }

  /// Stops collision detection
  void _stopCollisionDetection() {
    _detectedEdges.clear();
    _detectedCenters.clear();
  }

  /// Rotates instantly to a specific slice index
  void rotateToIndex(int index, {Duration? duration}) {
    if (index < 0 || index >= widget.slices.length) {
      throw ArgumentError('Index out of range: $index');
    }

    final targetRotation = WheelMath.rotationForIndex(
      index,
      widget.slices.length,
      widget.configuration?.startPosition ?? WheelStartPosition.top,
    );

    rotateTo(targetRotation, duration: duration);
  }

  /// Rotates to a specific angle
  void rotateTo(double targetRotation, {Duration? duration}) {
    _animationController.stop();
    _animationController.duration = duration ?? const Duration(milliseconds: 300);

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0.0);
  }

  /// Spins the wheel with full rotations to a specific index
  /// This is the key method for backend-controlled spinning
  Future<void> spinToIndex(
    int targetIndex, {
    int fullRotations = 5,
    Duration? duration,
  }) async {
    if (targetIndex < 0 || targetIndex >= widget.slices.length) {
      throw ArgumentError('Index out of range: $targetIndex');
    }

    if (_isSpinning) {
      return; // Already spinning
    }

    setState(() {
      _isSpinning = true;
    });

    _startCollisionDetection();

    final targetRotation = WheelMath.rotationForIndex(
      targetIndex,
      widget.slices.length,
      widget.configuration?.startPosition ?? WheelStartPosition.top,
    );

    // Add full rotations (counter-clockwise is positive in our coordinate system)
    final fullRotationRadians = fullRotations * 2 * math.pi;
    final finalRotation = _currentRotation - fullRotationRadians +
        (targetRotation - _currentRotation);

    _animationController.duration = duration ?? widget.animationDuration;

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    await _animationController.forward(from: 0.0);
  }

  /// Spins to a backend-determined result
  /// Usage: Call backend API first, get result index, then spin to it
  ///
  /// Example:
  /// ```dart
  /// final result = await fetchSpinResult(); // Your backend call
  /// await wheelKey.currentState!.spinToBackendResult(result.index);
  /// ```
  Future<void> spinToBackendResult(
    int resultIndex, {
    int fullRotations = 5,
    Duration? duration,
  }) async {
    return spinToIndex(
      resultIndex,
      fullRotations: fullRotations,
      duration: duration,
    );
  }

  /// Starts continuous rotation (infinite spinning)
  void startContinuousRotation({
    double rotationsPerSecond = 1.0,
  }) {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _animationController.duration = Duration(
      milliseconds: (1000 / rotationsPerSecond).round(),
    );

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation - (2 * math.pi), // One full rotation
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.repeat();
  }

  /// Stops continuous rotation and optionally lands on a specific index
  Future<void> stopContinuousRotation({
    int? landOnIndex,
    Duration? decelerationDuration,
  }) async {
    if (!_isSpinning) return;

    _animationController.stop();

    if (landOnIndex != null) {
      await spinToIndex(
        landOnIndex,
        fullRotations: 2,
        duration: decelerationDuration ?? const Duration(seconds: 3),
      );
    } else {
      setState(() {
        _isSpinning = false;
      });
    }
  }

  /// Stops any current animation
  void stop() {
    _animationController.stop();
    setState(() {
      _isSpinning = false;
    });
    _stopCollisionDetection();
  }

  /// Gets the current selected slice index
  int get currentIndex {
    return WheelMath.indexAtRotation(
      _currentRotation,
      widget.slices.length,
      widget.configuration?.startPosition ?? WheelStartPosition.top,
    );
  }

  /// Gets whether the wheel is currently spinning
  bool get isSpinning => _isSpinning;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: widget.onSliceTap != null ? _handleTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The wheel
          CustomPaint(
            painter: WheelPainter(
              slices: widget.slices,
              configuration: widget.configuration ?? const WheelConfiguration(),
              rotation: _currentRotation,
            ),
            child: Container(),
          ),

          // Pin indicator
          if (widget.showPin && widget.pinConfiguration != null)
            _buildPin(),
        ],
      ),
    );
  }

  /// Handles tap events on the wheel
  void _handleTap(TapUpDetails details) {
    if (_isSpinning) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final tapPosition = details.localPosition;

    // Convert tap position to polar coordinates
    final polar = WheelMath.cartesianToPolar(center, tapPosition);
    final tappedAngle = polar.dx;

    // Adjust for current rotation
    final adjustedAngle = tappedAngle - _currentRotation;

    // Find which slice was tapped
    final tappedIndex = WheelMath.indexAtRotation(
      adjustedAngle,
      widget.slices.length,
      widget.configuration?.startPosition ?? WheelStartPosition.top,
    );

    widget.onSliceTap?.call(tappedIndex);
  }

  /// Builds the pin widget
  Widget _buildPin() {
    final config = widget.pinConfiguration!;

    Widget pinWidget;

    if (config.customWidget != null) {
      pinWidget = config.customWidget!;
    } else if (config.icon != null) {
      pinWidget = Icon(
        config.icon,
        size: config.size.width,
        color: config.tintColor,
      );
    } else if (config.image != null) {
      pinWidget = Image(
        image: config.image!,
        width: config.size.width,
        height: config.size.height,
        color: config.tintColor,
      );
    } else {
      pinWidget = const SizedBox.shrink();
    }

    // Wrap in container if background color specified
    if (config.backgroundColor != null) {
      pinWidget = Container(
        width: config.size.width,
        height: config.size.height,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: pinWidget,
      );
    }

    // Position the pin based on configuration
    return Positioned(
      top: config.position == PinPosition.top
          ? config.verticalOffset
          : null,
      bottom: config.position == PinPosition.bottom
          ? config.verticalOffset
          : null,
      left: config.position == PinPosition.left
          ? config.horizontalOffset
          : null,
      right: config.position == PinPosition.right
          ? config.horizontalOffset
          : null,
      child: pinWidget,
    );
  }
}
