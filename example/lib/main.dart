import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fortune_wheel/fortune_wheel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune Wheel Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FortuneWheelDemo(),
    );
  }
}

class FortuneWheelDemo extends StatefulWidget {
  const FortuneWheelDemo({super.key});

  @override
  State<FortuneWheelDemo> createState() => _FortuneWheelDemoState();
}

class _FortuneWheelDemoState extends State<FortuneWheelDemo> {
  final GlobalKey<FortuneWheelState> _wheelKey = GlobalKey();
  int? _selectedIndex;
  bool _isSpinning = false;
  String _statusMessage = 'Tap "Spin with Backend" to start!';

  // Sample prizes
  final List<String> _prizes = [
    '🎁 Prize 1',
    '💎 Prize 2',
    '🎉 Prize 3',
    '⭐ Prize 4',
    '🏆 Prize 5',
    '🎊 Prize 6',
    '🌟 Prize 7',
    '🎈 Prize 8',
  ];

  late List<Slice> _slices;

  @override
  void initState() {
    super.initState();
    _initializeSlices();
  }

  void _initializeSlices() {
    _slices = _prizes.asMap().entries.map((entry) {
      final index = entry.key;
      final prize = entry.value;

      return Slice(
        contents: [
          TextContent(
            text: prize,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: _getColorForIndex(index),
        data: {'prize': prize, 'index': index},
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  /// Simulates a backend API call that returns the winning index
  /// In a real app, this would be an HTTP call to your server
  Future<int> _fetchSpinResultFromBackend() async {
    setState(() {
      _statusMessage = 'Calling backend API...';
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate backend returning a random result
    // In production, replace this with actual HTTP call:
    // final response = await http.post('https://your-api.com/spin');
    // final result = jsonDecode(response.body);
    // return result['winningIndex'];

    final random = math.Random();
    final winningIndex = random.nextInt(_prizes.length);

    setState(() {
      _statusMessage = 'Backend returned index $winningIndex. Spinning...';
    });

    return winningIndex;
  }

  /// Handles the spin button press with backend integration
  Future<void> _handleSpinWithBackend() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
    });

    try {
      // Step 1: Call backend to get the result
      final resultIndex = await _fetchSpinResultFromBackend();

      // Step 2: Spin to the result returned by backend
      await _wheelKey.currentState!.spinToBackendResult(
        resultIndex,
        fullRotations: 5,
        duration: const Duration(seconds: 4),
      );

      // Step 3: Show result
      setState(() {
        _selectedIndex = resultIndex;
        _statusMessage = 'You won: ${_prizes[resultIndex]}!';
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

  /// Alternative: Spin immediately, then fetch result while spinning
  Future<void> _handleSpinWithAsyncBackend() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
      _statusMessage = 'Spinning while fetching result...';
    });

    try {
      // Start continuous spin immediately
      _wheelKey.currentState!.startContinuousRotation(rotationsPerSecond: 2);

      // Fetch result from backend while wheel is spinning
      final resultIndex = await _fetchSpinResultFromBackend();

      // Stop at the result
      await _wheelKey.currentState!.stopContinuousRotation(
        landOnIndex: resultIndex,
      );

      setState(() {
        _selectedIndex = resultIndex;
        _statusMessage = 'You won: ${_prizes[resultIndex]}!';
        _isSpinning = false;
      });

      _showWinDialog(resultIndex);
    } catch (e) {
      _wheelKey.currentState!.stop();
      setState(() {
        _statusMessage = 'Error: $e';
        _isSpinning = false;
      });
    }
  }

  /// Quick spin to a specific index (for testing)
  void _handleQuickSpin(int index) {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _wheelKey.currentState!.spinToIndex(
      index,
      fullRotations: 3,
      duration: const Duration(seconds: 2),
    ).then((_) {
      setState(() {
        _selectedIndex = index;
        _isSpinning = false;
      });
    });
  }

  void _showWinDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text(
          'You won ${_prizes[index]}!',
          style: const TextStyle(fontSize: 18),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortune Wheel - Backend Integration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // The Fortune Wheel
          Expanded(
            child: Center(
              child: SizedBox(
                width: 350,
                height: 350,
                child: FortuneWheel(
                  key: _wheelKey,
                  slices: _slices,
                  configuration: WheelConfiguration(
                    circlePreferences: const CirclePreferences(
                      strokeWidth: 4,
                      strokeColor: Colors.black,
                    ),
                    slicePreferences: const SlicePreferences(
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                    startPosition: WheelStartPosition.top,
                    layerInsets: const EdgeInsets.all(15),
                    contentMargins: const EdgeInsets.all(15),
                  ),
                  pinConfiguration: PinConfiguration.icon(
                    icon: Icons.arrow_drop_down,
                    size: const Size(50, 50),
                    color: Colors.red,
                    position: PinPosition.top,
                    verticalOffset: 0,
                  ),
                  onSliceTap: (index) {
                    if (!_isSpinning) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped: ${_prizes[index]}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  centerCollisionDetection: true,
                  onCenterCollision: (progress) {
                    // Optional: Add haptic feedback or sound here
                  },
                ),
              ),
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Main spin button with backend integration
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _handleSpinWithBackend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSpinning
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Spin with Backend (Sequential)',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Alternative: Async backend call
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _handleSpinWithAsyncBackend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSpinning
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Spin with Backend (Async)',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Quick test buttons
                Text(
                  'Quick Test (no backend):',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    _prizes.length,
                    (index) => ElevatedButton(
                      onPressed: _isSpinning ? null : () => _handleQuickSpin(index),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Current result display
          if (_selectedIndex != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _getColorForIndex(_selectedIndex!),
              child: Text(
                'Current: ${_prizes[_selectedIndex!]}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
