import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fortune_wheel/fortune_wheel.dart';

/// Enhanced Fortune Wheel Demo showcasing the new visual features:
/// - Thicker border with decorative dots
/// - Center indicator circle
/// - Custom arrow pin that stays fixed while wheel spins
class EnhancedWheelDemo extends StatefulWidget {
  const EnhancedWheelDemo({super.key});

  @override
  State<EnhancedWheelDemo> createState() => _EnhancedWheelDemoState();
}

class _EnhancedWheelDemoState extends State<EnhancedWheelDemo> {
  final GlobalKey<FortuneWheelState> _wheelKey = GlobalKey();
  int? _selectedIndex;
  bool _isSpinning = false;
  String _statusMessage = 'Tap "Spin" to try your luck!';

  // Sample prizes similar to the reference image
  final List<String> _prizes = [
    '100',
    '50',
    '200',
    '25',
    '500',
    '10',
    '1000',
    '5',
  ];

  late List<Slice> _slices;

  @override
  void initState() {
    super.initState();
    _initializeSlices();
  }

  void _initializeSlices() {
    // Create slices with alternating colors similar to the reference image
    _slices = _prizes.asMap().entries.map((entry) {
      final index = entry.key;
      final prize = entry.value;

      final (colorKey, colorValue) = _getColorForIndex(index);

      print(
        'Prize: $prize, index: $index, color: ${colorValue.value.toRadixString(16)} $colorKey',
      );

      return Slice(
        contents: [
          TextContent(
            textMode: SliceTextMode.horizontal,
            text: prize,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: colorValue,
        data: {'prize': prize, 'index': index},
      );
    }).toList();
  }

  (String, Color) _getColorForIndex(int index) {
    // Alternating colors similar to the reference image
    final colors = {
      'red': const Color(0xFFE74C3C), // Red
      'blue': const Color(0xFF3498DB), // Blue
      'orange': const Color(0xFFF39C12), // Orange
      'purple': const Color(0xFF9B59B6), // Purple
      'teal': const Color(0xFF1ABC9C), // Teal
      'dark orange': const Color(0xFFE67E22), // Dark orange
      'green': const Color(0xFF2ECC71), // Green
      'pink': const Color(0xFFE91E63), // Pink
    };
    final colorKey = colors.keys.elementAt(index);
    print('colorKey: $colorKey');
    final colorValue = colors[colorKey] ?? Colors.white;
    return (colorKey, colorValue);
  }

  /// Simulates a backend API call
  Future<int> _fetchSpinResultFromBackend() async {
    setState(() {
      _statusMessage = 'Calling backend API...';
    });

    print('Calling backend API...');

    await Future.delayed(const Duration(seconds: 1));

    final random = math.Random();
    final winningIndex = random.nextInt(_prizes.length);

    setState(() {
      _statusMessage = 'Spinning to ${_prizes[winningIndex]}...';
    });

    print('Spinning to ${_prizes[winningIndex]}...');

    return winningIndex;
  }

  /// Handles the spin button press with backend integration
  Future<void> _handleSpin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
    });

    try {
      // Get result from backend

      _wheelKey.currentState?.startContinuousRotation();
      final resultIndex = await _fetchSpinResultFromBackend();

      print('resultIndex: $resultIndex');

      // Spin to the result
      await _wheelKey.currentState!.stopContinuousRotation(
        landOnIndex: resultIndex,
      );

      print('spinToBackendResult: ${_wheelKey.currentState!.currentIndex}');

      setState(() {
        _selectedIndex = resultIndex;
        _statusMessage = 'You won: ${_prizes[resultIndex]} points!';
        _isSpinning = false;
      });

      _showWinDialog(resultIndex);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isSpinning = false;
      });
    }
  }

  void _showWinDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text(
          'You won ${_prizes[index]} points!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (colorKey, colorValue) = _getColorForIndex(_selectedIndex ?? 0);
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        title: const Text('Enhanced Fortune Wheel'),
        backgroundColor: const Color(0xFF34495E),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Status message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // The Enhanced Fortune Wheel
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 350,
                  height: 350,
                  child: FortuneWheel(
                    key: _wheelKey,
                    slices: _slices,
                    configuration: WheelConfiguration(
                      circlePreferences: CirclePreferences(
                        strokeWidth: 8,
                        strokeColor: const Color(0xFF34495E),
                        // NEW: Border dots configuration
                        borderDots: const BorderDotsConfiguration(
                          dotSize: 8,
                          dotColor: Color(0xFFFFA500),
                          dotBorderColor: Color(0xFF34495E),
                          dotBorderWidth: 2,
                          dotsPerSlice: 1, // One dot per slice boundary
                        ),
                        // NEW: Center indicator configuration
                        centerIndicator: const CenterIndicatorConfiguration(
                          radius: 35,
                          color: Colors.white,
                          borderColor: Color(0xFF34495E),
                          borderWidth: 4,
                        ),
                      ),
                      slicePreferences: const SlicePreferences(
                        strokeWidth: 2,
                        strokeColor: Color(0xFF2C3E50),
                      ),
                      startPosition: WheelStartPosition.top,
                      layerInsets: const EdgeInsets.all(20),
                      contentMargins: const EdgeInsets.all(20),
                    ),
                    // NEW: Custom arrow pin using the ArrowPin widget
                    pinConfiguration: PinConfiguration.custom(
                      widget: const ArrowPin(
                        color: Color(0xFFE74C3C),
                        size: Size(40, 50),
                        borderColor: Colors.white,
                        borderWidth: 3,
                        withShadow: true,
                      ),
                      size: const Size(40, 50),
                      position: PinPosition.top,
                      verticalOffset: -10,
                    ),
                    centerCollisionDetection: true,
                    onCenterCollision: (progress) {
                      // Optional: Add haptic feedback or sound
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Spin button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _handleSpin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: _isSpinning
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'SPIN THE WHEEL',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Current result display
          if (_selectedIndex != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorValue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                'Current Prize: ${_prizes[_selectedIndex!]} Points',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
