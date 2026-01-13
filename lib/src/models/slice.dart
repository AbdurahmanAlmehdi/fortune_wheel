import 'package:flutter/material.dart';
import 'content_type.dart';

/// Represents a single slice/segment of the fortune wheel
class Slice {
  /// List of content items to display in this slice (stacked vertically)
  final List<SliceContent> contents;

  /// Solid background color for the slice
  final Color? backgroundColor;

  /// Background image for the slice
  final ImageProvider? backgroundImage;

  /// Gradient background for the slice
  final Gradient? gradient;

  /// Optional data associated with this slice (e.g., prize value, ID)
  final dynamic data;

  const Slice({
    this.contents = const [],
    this.backgroundColor,
    this.backgroundImage,
    this.gradient,
    this.data,
  }) : assert(
          backgroundColor == null || (backgroundImage == null && gradient == null),
          'Cannot specify both backgroundColor and backgroundImage/gradient',
        );

  /// Creates a slice with simple text content
  factory Slice.text(
    String text, {
    TextStyle? style,
    Color? backgroundColor,
    dynamic data,
  }) {
    return Slice(
      contents: [
        TextContent(
          text: text,
          style: style,
        ),
      ],
      backgroundColor: backgroundColor,
      data: data,
    );
  }

  /// Creates a slice with an image
  factory Slice.image(
    ImageProvider image, {
    Size? size,
    Color? backgroundColor,
    dynamic data,
  }) {
    return Slice(
      contents: [
        ImageContent(
          image: image,
          preferredSize: size ?? const Size(50, 50),
        ),
      ],
      backgroundColor: backgroundColor,
      data: data,
    );
  }

  /// Creates a slice with both text and image
  factory Slice.textWithImage(
    String text,
    ImageProvider image, {
    TextStyle? style,
    Size? imageSize,
    Color? backgroundColor,
    dynamic data,
  }) {
    return Slice(
      contents: [
        ImageContent(
          image: image,
          preferredSize: imageSize ?? const Size(40, 40),
        ),
        TextContent(
          text: text,
          style: style,
        ),
      ],
      backgroundColor: backgroundColor,
      data: data,
    );
  }
}
