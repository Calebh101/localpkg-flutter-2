import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Type used for [ThemeManager.getColorForType].
enum ColorType {
  /// Get the corresponding color to the current [Brightness].
  brightness,

  /// Get the primary color of the current [BuildContext].
  primary,

  /// Get the secondary color of the current [BuildContext].
  secondary,
}

/// Manages themes and theme-related subjects.
class ThemeManager {
  ThemeManager._();

  /// Gets the current color corresponding to the inputted [type].
  ///
  /// For example, if you input [ColorType.brightness], then the color returned will correspond to the current brightness. So if the current brightness is [Brightness.light], then [Colors.black] will be returned.
  ///
  /// If you input [ColorType.primary] or [ColorType.secondary], then the primary/secondary color corresponding to the current [BuildContext] will be returned.
  static Color getColorForType({required BuildContext context, required ColorType type, Brightness? brightness}) {
    switch (type) {
      case ColorType.brightness:
        brightness ??= MediaQuery.of(context).platformBrightness;

        switch (brightness) {
          case Brightness.light: return Colors.black;
          case Brightness.dark: return Colors.white;
        }
      case ColorType.primary:
        return Theme.of(context).primaryColor;
      case ColorType.secondary:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}

/// [GradientText] is a quick and simple class for putting, well, gradients on text.
class GradientText extends Text {
  /// The colors used for the text gradient.
  final List<GradientColor> colors;

  /// Where the gradient starts.
  final AlignmentGeometry begin;

  /// Where the gradient ends.
  final AlignmentGeometry end;

  /// [GradientText] is a quick and simple class for putting, well, gradients on text.
  GradientText(super.data, {required this.colors, super.key, super.style, super.strutStyle, super.textAlign, super.textDirection, super.locale, super.softWrap, super.overflow, @Deprecated('Use textScaler instead. textScaleFactor will not be used.') super.textScaleFactor, super.textScaler, super.maxLines, super.semanticsLabel, super.textWidthBasis, super.textHeightBehavior, super.selectionColor, this.begin = Alignment.centerLeft, this.end = Alignment.centerRight});

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = buildGradientColors(colors);
    assert(data != null, "Text data cannot be null.");
    assert(gradientColors.isNotEmpty, "Gradient colors cannot be empty.");

    Widget widget = Text(
      data!,
      style: (style ?? TextStyle()).copyWith(color: gradientColors.length == 1 ? style?.color ?? gradientColors[0] : Colors.white),
      key: key,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );

    return gradientColors.length == 1 ? widget : ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
        begin: begin,
        end: end,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: widget,
    );
  }

  /// Turn a `List<GradientColor` into a `List<Color`.
  static List<Color> buildGradientColors(List<GradientColor> colors) {
    List<Color> output = [];
    for (GradientColor item in colors) output.addAll(item.toColorList());
    return output;
  }
}

/// Colors for gradients.
class GradientColor {
  /// The specified color.
  final Color color;

  /// How many times this color is repeated in the final list.
  final int intensity;

  /// Colors for gradients. [intensity] represents how many times this color is repeated in the final list.
  GradientColor(this.color, {this.intensity = 1}) {
    assert(intensity >= 0, "Color intensity must be non-negative.");
  }

  /// Turn this into a `List<Color>`.
  List<Color> toColorList() {
    List<Color> result = [];
    for (int i = 0; i < intensity; i++) result.add(color);
    return result;
  }
}