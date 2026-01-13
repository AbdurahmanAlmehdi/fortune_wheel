# Fortune Wheel

A highly customizable spinning fortune wheel widget for Flutter with advanced animations and backend integration support. Perfect for gamification, prize wheels, decision makers, and any application requiring an interactive spinning wheel.

## Features

- **Backend Integration**: Spin to results determined by your server
- **Advanced Animations**:
  - Spin to specific index with multiple rotations
  - Continuous rotation mode
  - Smooth deceleration with customizable curves
- **Rich Customization**:
  - Multiple content types per slice (text, images, lines)
  - Solid colors, gradients, or image backgrounds
  - Configurable slice borders and colors
  - Curved text support (text follows circular path)
  - Straight and vertical text orientations
- **Interactive Features**:
  - Tap to select slices
  - Pin/pointer indicator with multiple positions
  - Collision detection with callbacks
- **Production Ready**:
  - No external dependencies (except curved_text)
  - Optimized CustomPainter rendering
  - Comprehensive example app

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fortune_wheel: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:fortune_wheel/fortune_wheel.dart';

FortuneWheel(
  slices: [
    Slice.text('Prize 1', backgroundColor: Colors.red),
    Slice.text('Prize 2', backgroundColor: Colors.blue),
    Slice.text('Prize 3', backgroundColor: Colors.green),
    Slice.text('Prize 4', backgroundColor: Colors.orange),
  ],
  pinConfiguration: PinConfiguration.icon(
    icon: Icons.arrow_drop_down,
    color: Colors.red,
  ),
)
```

### Backend Integration (Sequential)

Perfect for when you need to fetch the result first, then spin:

```dart
final GlobalKey<FortuneWheelState> wheelKey = GlobalKey();

// In your spin handler:
Future<void> handleSpin() async {
  // Step 1: Call your backend API
  final response = await http.post('https://your-api.com/spin');
  final result = jsonDecode(response.body);
  final winningIndex = result['winningIndex'];

  // Step 2: Spin to the backend result
  await wheelKey.currentState!.spinToBackendResult(
    winningIndex,
    fullRotations: 5,
    duration: Duration(seconds: 4),
  );

  // Step 3: Show result
  showWinDialog(winningIndex);
}

// Your widget:
FortuneWheel(
  key: wheelKey,
  slices: mySlices,
  // ... other config
)
```

### Backend Integration (Async)

Start spinning immediately while fetching the result in background:

```dart
Future<void> handleAsyncSpin() async {
  // Start spinning immediately
  wheelKey.currentState!.startContinuousRotation(rotationsPerSecond: 2);

  // Fetch result while spinning
  final winningIndex = await fetchResultFromBackend();

  // Stop at the result
  await wheelKey.currentState!.stopContinuousRotation(
    landOnIndex: winningIndex,
  );
}
```

## Configuration

### Wheel Configuration

```dart
FortuneWheel(
  slices: mySlices,
  configuration: WheelConfiguration(
    circlePreferences: CirclePreferences(
      strokeWidth: 4,
      strokeColor: Colors.black,
    ),
    slicePreferences: SlicePreferences(
      strokeWidth: 2,
      strokeColor: Colors.white,
      backgroundColors: SliceBackgroundColors.evenOdd(
        evenColor: Colors.blue,
        oddColor: Colors.red,
      ),
    ),
    startPosition: WheelStartPosition.top,
    layerInsets: EdgeInsets.all(15),
    contentMargins: EdgeInsets.all(15),
  ),
)
```

### Pin Configuration

```dart
// Icon pin
PinConfiguration.icon(
  icon: Icons.arrow_drop_down,
  size: Size(50, 50),
  color: Colors.red,
  position: PinPosition.top,
)

// Image pin
PinConfiguration.image(
  image: AssetImage('assets/pin.png'),
  size: Size(40, 40),
  position: PinPosition.top,
)

// Custom widget pin
PinConfiguration.custom(
  widget: YourCustomWidget(),
  size: Size(50, 50),
)
```

### Slice Content

```dart
// Simple text
Slice.text('Prize', backgroundColor: Colors.red)

// Text with image
Slice.textWithImage(
  'Prize',
  AssetImage('assets/icon.png'),
  imageSize: Size(40, 40),
)

// Custom content
Slice(
  contents: [
    ImageContent(
      image: AssetImage('assets/icon.png'),
      preferredSize: Size(50, 50),
    ),
    TextContent(
      text: 'Grand Prize',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      isCurved: true,  // Text follows circular arc
    ),
    LineContent(
      color: Colors.white,
      width: 2,
    ),
  ],
  gradient: LinearGradient(
    colors: [Colors.purple, Colors.blue],
  ),
)
```

## Animation Methods

### Spin to Index

```dart
// Spin with multiple rotations to specific slice
await wheelKey.currentState!.spinToIndex(
  targetIndex,
  fullRotations: 5,
  duration: Duration(seconds: 4),
);

// Quick rotation without full spins
wheelKey.currentState!.rotateToIndex(
  targetIndex,
  duration: Duration(milliseconds: 500),
);
```

### Continuous Rotation

```dart
// Start continuous spinning
wheelKey.currentState!.startContinuousRotation(
  rotationsPerSecond: 2.0,
);

// Stop continuous spinning
wheelKey.currentState!.stopContinuousRotation(
  landOnIndex: 3,  // Optional: land on specific slice
);

// Stop immediately
wheelKey.currentState!.stop();
```

## Callbacks

```dart
FortuneWheel(
  slices: mySlices,
  onSliceTap: (index) {
    print('Tapped slice $index');
  },
  onEdgeCollision: (progress) {
    // Called when slice edge passes pin
    // progress: 0.0 to 1.0 during deceleration, null during continuous
    HapticFeedback.lightImpact();
  },
  onCenterCollision: (progress) {
    // Called when slice center passes pin
    playSound();
  },
  edgeCollisionDetection: true,
  centerCollisionDetection: true,
)
```

## Advanced Features

### Curved Text

Text can follow the circular arc of the wheel:

```dart
TextContent(
  text: 'Your Prize Name',
  isCurved: true,
  orientation: TextOrientation.horizontal,
  style: TextStyle(fontSize: 18),
)
```

### Gradients

```dart
Slice(
  contents: [TextContent(text: 'Prize')],
  gradient: LinearGradient(
    colors: [Colors.purple, Colors.blue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
)
```

### Multiple Content Items

Stack multiple content items in a slice:

```dart
Slice(
  contents: [
    ImageContent(
      image: AssetImage('assets/icon.png'),
      preferredSize: Size(40, 40),
    ),
    TextContent(text: 'Prize Name'),
    TextContent(
      text: 'Value: \$100',
      style: TextStyle(fontSize: 12),
    ),
  ],
)
```

## Real-World Backend Integration Example

Here's a complete example with error handling:

```dart
Future<void> spinWithBackend() async {
  try {
    setState(() => isSpinning = true);

    // Call your backend
    final response = await http.post(
      Uri.parse('https://api.example.com/spin'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({'userId': currentUserId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final winningIndex = data['winningIndex'];

      // Spin to result
      await wheelKey.currentState!.spinToBackendResult(
        winningIndex,
        fullRotations: 5,
        duration: Duration(seconds: 4),
      );

      // Update UI with result
      setState(() {
        currentPrize = prizes[winningIndex];
        isSpinning = false;
      });

      showPrizeDialog();
    } else {
      throw Exception('Failed to fetch result');
    }
  } catch (e) {
    setState(() => isSpinning = false);
    showErrorDialog(e.toString());
  }
}
```

## Example App

Run the example app to see all features in action:

```bash
cd example
flutter run
```

The example demonstrates:
- Sequential backend integration
- Async backend integration
- Quick test buttons
- Collision detection
- Custom styling

## Performance Tips

1. **Reuse Slices**: Create slices once in initState, don't recreate on every build
2. **Optimize Images**: Use appropriately sized images for slice content
3. **Limit Collision Detection**: Only enable when needed (adds overhead)
4. **Animation Duration**: Longer animations (4-5s) feel more realistic

## Platform Support

- iOS
- Android
- Web
- macOS
- Linux
- Windows

## Credits

Inspired by [SwiftFortuneWheel](https://github.com/sh-khashimov/SwiftFortuneWheel) for iOS.

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
