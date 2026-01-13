import 'package:flutter/material.dart';

/// Base class for all content types that can be displayed in a wheel slice
abstract class SliceContent {
  const SliceContent();
}

/// Text content with styling preferences
class TextContent extends SliceContent {
  final String text;
  final TextStyle? style;
  final TextOrientation orientation;
  final bool isCurved;
  final bool flipUpsideDown;
  final double horizontalOffset;
  final double verticalOffset;
  final TextAlign alignment;
  final int? maxLines;
  final double? maxWidth;

  const TextContent({
    required this.text,
    this.style,
    this.orientation = TextOrientation.horizontal,
    this.isCurved = false,
    this.flipUpsideDown = true,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
    this.alignment = TextAlign.center,
    this.maxLines,
    this.maxWidth,
  });
}

/// Image content with positioning and sizing preferences
class ImageContent extends SliceContent {
  final ImageProvider image;
  final Size preferredSize;
  final double horizontalOffset;
  final double verticalOffset;
  final bool flipUpsideDown;
  final Color? backgroundColor;
  final Color? tintColor;

  const ImageContent({
    required this.image,
    required this.preferredSize,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
    this.flipUpsideDown = true,
    this.backgroundColor,
    this.tintColor,
  });
}

/// Line content for decorative lines
class LineContent extends SliceContent {
  final Color color;
  final double width;
  final LineType type;
  final double horizontalOffset;
  final double verticalOffset;

  const LineContent({
    required this.color,
    this.width = 2.0,
    this.type = LineType.solid,
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
  });
}

/// Text orientation options
enum TextOrientation {
  horizontal,
  vertical,
}

/// Line type options
enum LineType {
  solid,
  dashed,
}
