import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_wheel/fortune_wheel.dart';

void main() {
  test('WheelMath calculates correct degrees per slice', () {
    expect(WheelMath.degreePerSlice(8), 45.0);
    expect(WheelMath.degreePerSlice(4), 90.0);
  });

  test('Slice model creates correctly', () {
    final slice = Slice.text('Test', backgroundColor: const Color(0xFFFF0000));
    expect(slice.contents.length, 1);
    expect(slice.backgroundColor, const Color(0xFFFF0000));
  });
}
