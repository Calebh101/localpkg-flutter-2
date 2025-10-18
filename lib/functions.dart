import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mode used to format time in [TimeFormatter].
enum FormatTimeMode {
  /// `hh:mm:ss`
  hhmmss,

  /// `hh:mm`
  hhmm,

  /// `mm:ss`
  mmss,
}

/// Mode used to format duration in [TimeFormatter].
enum FormatDurationMode {
  /// Hour will always be present.
  hourRequired,

  /// Hour might not be present.
  hourOptional,
}

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

/// Manages capitalizations.
extension CaseManager on String {
  /// Capitalizes the first character of the string.
  String toSentenceCase() {
    if (isEmpty) return this;
    return [this[0].toUpperCase(), substring(1)].join("");
  }

  /// Capitalizes the first letter of every word.
  String toTitleCase() {
    return capitalizeByDelim(this, " ");
  }

  /// Capitalizes the first letter of every word, based on a delimiter ([delim]).
  static String capitalizeByDelim(String input, Pattern delim) {
    if (input.isEmpty) return input;

    return input.split(delim).map((x) => x.trim()).map((word) => word.isNotEmpty
      ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
      : word).join(' ');
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