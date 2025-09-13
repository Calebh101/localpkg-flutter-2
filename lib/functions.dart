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

/// Formats times, dates, and durations.
class TimeFormatter {
  /// Formats a [DateTime].
  static String formatTime(DateTime time, {
    FormatTimeMode output = FormatTimeMode.hhmm,
    bool army = false,
  }) {
    int hour = time.hour;
    int minute = time.minute;
    int second = time.second;
    int roundedHour = hour;

    if (army == false) {
      if (hour > 12) {
        roundedHour = hour - 12;
      }
    }

    String formatted = "$roundedHour:${minute.toString().padLeft(2, '0')}${output == FormatTimeMode.hhmmss || output == FormatTimeMode.mmss ? (":${second.toString().padLeft(2, '0')}"): ""}${!army ? (" ${hour >= 12 ? "PM" : "AM"}") : ""}";
    return formatted;
  }

  /// Formats a [Duration].
  static String formatDuration(Duration duration, {FormatDurationMode mode = FormatDurationMode.hourRequired}) {
    int ms = duration.inMilliseconds;
    int hours = (ms ~/ 3600000);
    int minutes = (ms % 3600000) ~/ 60000;
    int seconds = (ms % 60000) ~/ 1000;
    int remainingms = ms % 1000;

    if (mode == FormatDurationMode.hourRequired) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${remainingms.toString().padLeft(3, '0')}';
    } else if (mode == FormatDurationMode.hourOptional) {
      return '${hours > 0 ? "${hours.toString().padLeft(2, '0')}:" : ""}${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${remainingms.toString().padLeft(3, '0')}';
    } else {
      throw Exception("Invalid mode: $mode");
    }
  }
}

/// Extension for manipulating numbers.
extension NumberManager on num {
  /// Gets if the number is a whole number.
  bool isWhole() => this % 1 == 0;

  /// Returns a clean number. If this is a double but is a whole number, it is converted to an integer.
  String clean() {
    if (this is double && isWhole()) {
      return "${toInt()}";
    } else {
      return "$this";
    }
  }
}

/// Manages opening and manipulating URLs.
class UrlManager {
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

  /// Adds a prefix like `protocol://`.
  static String addHttpPrefix(String url, {String defaultPrefix = "http"}) {
    if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('ws://') && !url.startsWith('wss://')) return '$defaultPrefix://$url';
    return url;
  }

  /// Removes `http://` and `https://`, and optionally WebSocket and other protocols.
  static String removeHttpPrefix(String url, {bool removeWebsocket = true, List<String> otherProtocols = const []}) {
    List<String> protocols = ["http", "https", if (removeWebsocket) ...["ws", "wss"], ...otherProtocols];
    for (String protocol in protocols) url.replaceFirst("$protocol://", "");
    return url;
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

/// Extension to format [StackTrace]s.
extension StackTraceFormatter on StackTrace {
  static String _format(String input, {int? end}) {
    end ??= 16;
    assert(end > 0, "end must be greater than 0.");
    List<String> lines = input.split("\n");
    bool expands = false;
    if (lines.length > end) expands = true;
    if (lines.length < end) end = lines.length;
    return [...lines.sublist(0, end), if (expands) "And ${lines.length - end} more..."].join("\n");
  }

  /// Formats [StackTrace]s
  String format({int? end}) {
    return _format(toString(), end: end);
  }
}

/// Manages versions and version parsing.
class Version implements Comparable<Version> {
  /// `a` in `a.b.c`
  final int major;

  /// `b` in `a.b.c`
  final int intermediate;

  /// `c` in `a.b.c`
  final int minor;

  /// Letter identifier.
  final int patch;

  /// Optional revision.
  final int release;

  /// [major], [intermediate], and [minor] are required. [letter] and [release] have defaults.
  Version(this.major, this.intermediate, this.minor, [String letter = "A", this.release = 0]) : patch = letter.codeUnitAt(0), assert(release >= 0, "Release cannot be negative.");

  /// Returns the raw version string. [release] is only included if it is non-zero.
  @override
  String toString() {
    String main = "${[major, intermediate, minor].join(".")}${String.fromCharCode(patch)}";
    String releaseString = "R$release";
    return [main, if (release > 0) releaseString].join("-");
  }

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (intermediate != other.intermediate) return intermediate.compareTo(other.intermediate);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return release.compareTo(other.release);
  }

  @override
  int get hashCode => major.hashCode ^ intermediate.hashCode ^ minor.hashCode ^ patch.hashCode ^ release.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Version &&
      major == other.major &&
      intermediate == other.intermediate &&
      minor == other.minor &&
      patch == other.patch &&
      release == other.release;
  }

  /// This [Version] is greater than the other [Version].
  bool operator >(Version other) => compareTo(other) > 0;

  /// This [Version] is lesser than the other [Version].
  bool operator <(Version other) => compareTo(other) < 0;

  /// This [Version] is greater than or equal to the other [Version].
  bool operator >=(Version other) => compareTo(other) >= 0;

  /// This [Version] is lesser than or equal to the other [Version].
  bool operator <=(Version other) => compareTo(other) <= 0;

  /// Attempt to parse the version string. Possible values:
  /// 
  /// - `0.0.0A`
  /// - `2.14.5G-R2`
  /// - `23.0.1`
  static Version? tryParse(String input) {
    RegExp regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)([A-Z]+)?(?:-R(\d+))?$');
    RegExpMatch? match = regex.firstMatch(input);
    if (match == null) return null;

    List<int> chars = match.groups([1, 2, 3]).map((x) => int.parse(x!)).toList();
    String letter = match.group(4) ?? "A";
    int release = int.tryParse(match.group(5) ?? "") ?? 0;
    return Version(chars[0], chars[1], chars[2], letter, release);
  }

  /// Same as [tryParse], but throws an exception if it can't be parsed.
  static Version parse(String input) {
    Version? result = tryParse(input);
    if (result == null) throw Exception("Version could not be parsed: $input");
    return result;
  }
}

/// Addons for enums.
extension EnumAddons on Enum {
  /// Attempts to get the enum value from a string.
  /// 
  /// This will return null if not found.
  static T? fromStringOrNull<T extends Enum>(List<T> values, String target, {bool caseSensitive = true}) {
    if (caseSensitive == false) target = target.toLowerCase();
    for (T value in values) if ((caseSensitive ? value.name : value.name.toLowerCase()) == target) return value;
    return null;
  }

  /// Attempts to get the enum value from a string.
  /// 
  /// This will throw a [StateError] if not found.
  static T fromString<T extends Enum>(List<T> values, String target, {bool caseSensitive = true}) {
    return fromStringOrNull(values, target, caseSensitive: caseSensitive) ?? (throw StateError("No value of '$T' matched '$target'."));
  }
}