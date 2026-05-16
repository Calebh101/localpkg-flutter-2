import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localpkg_flutter/dialogue.dart';
import 'package:url_launcher/url_launcher.dart';

/// Determines what's used to decide the size factor.
enum SizeFactorMode {
  /// Use the width.
  byWidth,

  /// Use the height.
  byHeight,

  /// Whichever's smaller.
  auto,
}

/// Determines what mode is used in [SimpleNavigator].
enum NavigatorMode {
  /// Uses [Navigator.push].
  push,

  /// Uses [Navigator.pushReplacement].
  pushReplacement,
}

/// Manages opening URLs.
class UrlLauncher {
  /// Tries to launch the specified [Uri].
  static Future<void> openUrl({required Uri url, LaunchMode launchMode = LaunchMode.externalApplication}) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: launchMode,
        );
      } else {
        throw Exception('Could not launch $url: canLaunchUrl returned false');
      }
    } catch (e) {
      throw Exception("Could not launch $url: $e");
    }
  }
}

/// Manages size-related things.
class SizeManager {
  SizeManager._();

  /// Get the factor of size based on the screen size.
  static double getSizeFactor({
    required BuildContext context,
    SizeFactorMode mode = SizeFactorMode.byWidth,
    double maxSize = 3,
    bool forceUseWidth = true,
  }) {
    double size;
    Size screenSize = MediaQuery.of(context).size;

    if ((screenSize.width > screenSize.height) && !forceUseWidth) {
      size = screenSize.height;
    } else {
      size = screenSize.width;
    }

    switch (mode) {
      case SizeFactorMode.byWidth: // width
        size = screenSize.width;
        break;
      case SizeFactorMode.byHeight: // height
        size = screenSize.height;
        break;
      case SizeFactorMode.auto: // auto
        if (screenSize.width > screenSize.height) {
          size = screenSize.height;
        } else {
          size = screenSize.width;
        }
        break;
    }

    size = size * 0.003;
    size = size > maxSize ? maxSize : size;
    return size;
  }

  /// Get how many items to display in a row of a grid based on the size.
  static int getCrossAxisCount({required BuildContext context, int factor = 180}) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / factor).floor();
    crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;
    return crossAxisCount;
  }
}

/// Manages simple navigation functions.
class SimpleNavigator {
  SimpleNavigator._();

  /// Navigates to the specified page.
  static void navigate({required BuildContext context, required Widget page, NavigatorMode mode = NavigatorMode.push}) {
    switch (mode) {
      case NavigatorMode.push:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
        break;
      case NavigatorMode.pushReplacement:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
        break;
    }
  }
}

/// Several addons to the [Text] widget to make your development easier.
extension TextAddons on Text {
  /// True this text's data is empty and there's no [TextSpan].
  bool get isEmpty => (data?.isEmpty ?? true) && textSpan == null;

  /// A helper function to make a new [Text] in a simpler way, since [Text]s can't be modified directly.
  Text edit({String? data, Key? key, TextStyle? style, StrutStyle? strutStyle, TextAlign? textAlign, TextDirection? textDirection, Locale? locale, bool? softWrap, TextOverflow? overflow, @Deprecated('Use textScaler instead. Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. This feature was deprecated after v3.12.0-2.0.pre.') double? textScaleFactor, TextScaler? textScaler, int? maxLines, String? semanticsLabel, String? semanticsIdentifier, TextWidthBasis? textWidthBasis, TextHeightBehavior? textHeightBehavior, Color? selectionColor}) {
    return Text(data ?? this.data ?? '', key: key ?? this.key, style: style ?? this.style, strutStyle: strutStyle ?? this.strutStyle, textAlign: textAlign ?? this.textAlign, textDirection: textDirection ?? this.textDirection, locale: locale ?? this.locale, softWrap: softWrap ?? this.softWrap, overflow: overflow ?? this.overflow, textScaleFactor: textScaleFactor ?? this.textScaleFactor, textScaler: textScaler ?? this.textScaler, maxLines: maxLines ?? this.maxLines, semanticsLabel: semanticsLabel ?? this.semanticsLabel, semanticsIdentifier: semanticsIdentifier ?? this.semanticsIdentifier, textWidthBasis: textWidthBasis ?? this.textWidthBasis, textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior, selectionColor: selectionColor ?? this.selectionColor);
  }

  /// A helper function to make a new [Text] in a simpler way, since [Text]s can't be modified directly.
  static Text editText(Text original, {String? data, Key? key, TextStyle? style, StrutStyle? strutStyle, TextAlign? textAlign, TextDirection? textDirection, Locale? locale, bool? softWrap, TextOverflow? overflow, @Deprecated('Use textScaler instead. Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. This feature was deprecated after v3.12.0-2.0.pre.') double? textScaleFactor, TextScaler? textScaler, int? maxLines, String? semanticsLabel, String? semanticsIdentifier, TextWidthBasis? textWidthBasis, TextHeightBehavior? textHeightBehavior, Color? selectionColor}) {
    return original.edit(data: data, key: key, style: style, strutStyle: strutStyle, textAlign: textAlign, textDirection: textDirection, locale: locale, softWrap: softWrap, overflow: overflow, textScaleFactor: textScaleFactor, textScaler: textScaler, maxLines: maxLines, semanticsLabel: semanticsLabel, semanticsIdentifier: semanticsIdentifier, textWidthBasis: textWidthBasis, textHeightBehavior: textHeightBehavior, selectionColor: selectionColor);
  }

  /// A helper function to make a new [TextStyle] in a simpler way, since [TextStyle]s can't be modified directly.
  ///
  /// Note: `package` can't be accessed from a [TextStyle], so if you manually set a `package` on the original, you'll need to pass it in to [originalPackage].
  static TextStyle editTextStyle(TextStyle? original, {bool? inherit, Color? color, Color? backgroundColor, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, double? wordSpacing, TextBaseline? textBaseline, double? height, TextLeadingDistribution? leadingDistribution, Locale? locale, Paint? foreground, Paint? background, List<Shadow>? shadows, List<FontFeature>? fontFeatures, List<FontVariation>? fontVariations, TextDecoration? decoration, Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness, String? debugLabel, String? fontFamily, List<String>? fontFamilyFallback, String? package, TextOverflow? overflow, String? originalPackage}) {
    return TextStyle(inherit: inherit ?? original?.inherit ?? true, color: color ?? original?.color, backgroundColor: backgroundColor ?? original?.backgroundColor, fontSize: fontSize ?? original?.fontSize, fontWeight: fontWeight ?? original?.fontWeight, fontStyle: fontStyle ?? original?.fontStyle, letterSpacing: letterSpacing ?? original?.letterSpacing, wordSpacing: wordSpacing ?? original?.wordSpacing, textBaseline: textBaseline ?? original?.textBaseline, height: height ?? original?.height, leadingDistribution: leadingDistribution ?? original?.leadingDistribution, locale: locale ?? original?.locale, foreground: foreground ?? original?.foreground, background: background ?? original?.background, shadows: shadows ?? original?.shadows, fontFeatures: fontFeatures ?? original?.fontFeatures, fontVariations: fontVariations ?? original?.fontVariations, decoration: decoration ?? original?.decoration, decorationColor: decorationColor ?? original?.decorationColor, decorationStyle: decorationStyle ?? original?.decorationStyle, decorationThickness: decorationThickness ?? original?.decorationThickness, debugLabel: debugLabel ?? original?.debugLabel, fontFamily: fontFamily ?? original?.fontFamily, fontFamilyFallback: fontFamilyFallback ?? original?.fontFamilyFallback, package: package ?? originalPackage, overflow: overflow ?? original?.overflow);
  }

  /// Edit the style of a [Text] inline.
  Text editStyle({bool? inherit, Color? color, Color? backgroundColor, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, double? wordSpacing, TextBaseline? textBaseline, double? height, TextLeadingDistribution? leadingDistribution, Locale? locale, Paint? foreground, Paint? background, List<Shadow>? shadows, List<FontFeature>? fontFeatures, List<FontVariation>? fontVariations, TextDecoration? decoration, Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness, String? debugLabel, String? fontFamily, List<String>? fontFamilyFallback, String? package, TextOverflow? overflow, String? originalPackage}) {
    final original = style;
    return edit(style: editTextStyle(style, inherit: inherit ?? original?.inherit ?? true, color: color ?? original?.color, backgroundColor: backgroundColor ?? original?.backgroundColor, fontSize: fontSize ?? original?.fontSize, fontWeight: fontWeight ?? original?.fontWeight, fontStyle: fontStyle ?? original?.fontStyle, letterSpacing: letterSpacing ?? original?.letterSpacing, wordSpacing: wordSpacing ?? original?.wordSpacing, textBaseline: textBaseline ?? original?.textBaseline, height: height ?? original?.height, leadingDistribution: leadingDistribution ?? original?.leadingDistribution, locale: locale ?? original?.locale, foreground: foreground ?? original?.foreground, background: background ?? original?.background, shadows: shadows ?? original?.shadows, fontFeatures: fontFeatures ?? original?.fontFeatures, fontVariations: fontVariations ?? original?.fontVariations, decoration: decoration ?? original?.decoration, decorationColor: decorationColor ?? original?.decorationColor, decorationStyle: decorationStyle ?? original?.decorationStyle, decorationThickness: decorationThickness ?? original?.decorationThickness, debugLabel: debugLabel ?? original?.debugLabel, fontFamily: fontFamily ?? original?.fontFamily, fontFamilyFallback: fontFamilyFallback ?? original?.fontFamilyFallback, package: package ?? originalPackage, overflow: overflow ?? original?.overflow));
  }

  /// Change the [Text]'s [TextStyle]'s font size easily.
  Text fontSize(num fontSize) {
    return edit(style: editTextStyle(style, fontSize: fontSize.toDouble()));
  }

  /// Change the [Text]'s [TextStyle]'s text color easily.
  Text color(Color? color) {
    return edit(style: TextAddons.editTextStyle(style, color: color));
  }
}

/// Several addons to the [SelectableText] widget to make your development easier.
extension SelectableTextAddons on SelectableText {
  /// True this text's data is empty and there's no [TextSpan].
  bool get isEmpty => (data?.isEmpty ?? true) && textSpan == null;

  /// A helper function to make a new [Text] in a simpler way, since [Text]s can't be modified directly.
  SelectableText edit({String? data, Key? key, TextStyle? style, StrutStyle? strutStyle, TextAlign? textAlign, TextDirection? textDirection, @Deprecated('Use textScaler instead. Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. This feature was deprecated after v3.12.0-2.0.pre.') double? textScaleFactor, TextScaler? textScaler, int? maxLines, String? semanticsLabel, TextWidthBasis? textWidthBasis, TextHeightBehavior? textHeightBehavior, Color? selectionColor}) {
    return SelectableText(data ?? this.data ?? '', key: key ?? this.key, style: style ?? this.style, strutStyle: strutStyle ?? this.strutStyle, textAlign: textAlign ?? this.textAlign, textDirection: textDirection ?? this.textDirection, textScaleFactor: textScaleFactor ?? this.textScaleFactor, textScaler: textScaler ?? this.textScaler, maxLines: maxLines ?? this.maxLines, semanticsLabel: semanticsLabel ?? this.semanticsLabel, textWidthBasis: textWidthBasis ?? this.textWidthBasis, textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior, selectionColor: selectionColor ?? this.selectionColor);
  }

  /// A helper function to make a new [Text] in a simpler way, since [Text]s can't be modified directly.
  static SelectableText editText(SelectableText original, {String? data, Key? key, TextStyle? style, StrutStyle? strutStyle, TextAlign? textAlign, TextDirection? textDirection, @Deprecated('Use textScaler instead. Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. This feature was deprecated after v3.12.0-2.0.pre.') double? textScaleFactor, TextScaler? textScaler, int? maxLines, String? semanticsLabel, TextWidthBasis? textWidthBasis, TextHeightBehavior? textHeightBehavior, Color? selectionColor}) {
    return original.edit(data: data, key: key, style: style, strutStyle: strutStyle, textAlign: textAlign, textDirection: textDirection, textScaleFactor: textScaleFactor, textScaler: textScaler, maxLines: maxLines, semanticsLabel: semanticsLabel, textWidthBasis: textWidthBasis, textHeightBehavior: textHeightBehavior, selectionColor: selectionColor);
  }

  /// Edit the style of a [SelectableText] inline.
  SelectableText editStyle({bool? inherit, Color? color, Color? backgroundColor, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing, double? wordSpacing, TextBaseline? textBaseline, double? height, TextLeadingDistribution? leadingDistribution, Locale? locale, Paint? foreground, Paint? background, List<Shadow>? shadows, List<FontFeature>? fontFeatures, List<FontVariation>? fontVariations, TextDecoration? decoration, Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness, String? debugLabel, String? fontFamily, List<String>? fontFamilyFallback, String? package, TextOverflow? overflow, String? originalPackage}) {
    final original = style;
    return edit(style: TextAddons.editTextStyle(style, inherit: inherit ?? original?.inherit ?? true, color: color ?? original?.color, backgroundColor: backgroundColor ?? original?.backgroundColor, fontSize: fontSize ?? original?.fontSize, fontWeight: fontWeight ?? original?.fontWeight, fontStyle: fontStyle ?? original?.fontStyle, letterSpacing: letterSpacing ?? original?.letterSpacing, wordSpacing: wordSpacing ?? original?.wordSpacing, textBaseline: textBaseline ?? original?.textBaseline, height: height ?? original?.height, leadingDistribution: leadingDistribution ?? original?.leadingDistribution, locale: locale ?? original?.locale, foreground: foreground ?? original?.foreground, background: background ?? original?.background, shadows: shadows ?? original?.shadows, fontFeatures: fontFeatures ?? original?.fontFeatures, fontVariations: fontVariations ?? original?.fontVariations, decoration: decoration ?? original?.decoration, decorationColor: decorationColor ?? original?.decorationColor, decorationStyle: decorationStyle ?? original?.decorationStyle, decorationThickness: decorationThickness ?? original?.decorationThickness, debugLabel: debugLabel ?? original?.debugLabel, fontFamily: fontFamily ?? original?.fontFamily, fontFamilyFallback: fontFamilyFallback ?? original?.fontFamilyFallback, package: package ?? originalPackage, overflow: overflow ?? original?.overflow));
  }

  /// Change the [SelectableText]'s [TextStyle]'s font size easily.
  SelectableText fontSize(num fontSize) {
    return edit(style: TextAddons.editTextStyle(style, fontSize: fontSize.toDouble()));
  }

  /// Change the [SelectableText]'s [TextStyle]'s text color easily.
  SelectableText color(Color? color) {
    return edit(style: TextAddons.editTextStyle(style, color: color));
  }
}

/// Several addons for the [BuildContext] object.
extension ContextAddons on BuildContext {
  /// The current [Navigator.of] of this [BuildContext].
  NavigatorState get navigator => Navigator.of(this);

  /// The current [MediaQuery.of]'s [size] of this [BuildContext].
  Size get screenSize => MediaQuery.of(this).size;

  /// Only returns this [BuildContext] if [mounted] is true.
  /// Otherwise, returns `null`.
  BuildContext? get ifMountedOrNull => mounted ? this : null;

  /// Only executes the callback if [mounted] is true.
  /// Otherwise, returns `null`.
  T? ifMounted<T>(T Function(BuildContext context) callback) {
    if (mounted) {
      return callback.call(this);
    } else {
      return null;
    }
  }
}

/// Several addons for the [DateTime] object.
extension DateTimeAddons on DateTime {
  /// The number of seconds since
  /// the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most
  /// 8,640,000,000,000s (100,000,000 days) from the Unix epoch.
  /// In other words: `secondsSinceEpoch.abs() <= 8640000000000`.
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).toInt();
}

/// Show a simple text-based snack bar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(BuildContext context, String content) {
  return SnackBarManager.show(context, content);
}

/// `NullIfEmpty` extension on widget `Text`.
extension NullIfEmptyText on Text {
  /// True this text's data is empty and there's no [TextSpan].
  bool get isEmpty => (data?.isEmpty ?? true) && textSpan == null;

  /// If this text's data is empty and there's no [TextSpan], return null. Otherwise, return the widget.
  ///
  /// This returns null only if there are 0 characters. Spaces count.
  Text? get nullIfEmpty => isEmpty ? null : this;
}

/// `NullIfEmpty` extension on widget `SelectableText`.
extension NullIfEmptySelectableText on SelectableText {
  /// If this text's data is empty and there's no [TextSpan], return null. Otherwise, return the widget.
  ///
  /// This returns null only if there are 0 characters. Spaces count.
  SelectableText? get nullIfEmpty => isEmpty ? null : this;
}

/// `GlobalKey<FormState>`
typedef FormKey = GlobalKey<FormState>;

/// Addons for [FormKey] (`GlobalKey<FormState>`).
extension FormKeyAddons on FormKey {
  /// This key's [currentState], with a null check.
  ///
  /// This key must be attached to a [Form] for this to not throw.
  FormState get state => currentState!;

  /// Validates every [FormField] that is a descendant of this [Form], and
  /// returns true if there are no errors.
  ///
  /// The form will rebuild to report the results.
  ///
  /// See also:
  ///  * [validateGranularly], which also validates descendant [FormField]s,
  /// but instead returns a [Set] of fields with errors.
  bool validate() => state.validate();

  /// Validates every [FormField] that is a descendant of this [Form], and
  /// returns a [Set] of [FormFieldState] of the invalid field(s) only, if any.
  ///
  /// This method can be useful to highlight field(s) with errors.
  ///
  /// The form will rebuild to report the results.
  ///
  /// See also:
  ///  * [validate], which also validates descendant [FormField]s,
  /// and return true if there are no errors.
  Set<FormFieldState<Object?>> validateGranularly() => state.validateGranularly();
}