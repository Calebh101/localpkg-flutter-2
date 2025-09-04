import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localpkg/dialogue.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

enum FormatTimeMode {
  hhmmss,
  hhmm,
  mmss,
}

enum FormatDurationMode {
  hourRequired,
  hourOptional,
}

enum ColorType {
  theme,
  primary,
  secondary,
}

class TimeFormatter {
  static String formatTime(Duration input, {
    FormatTimeMode output = FormatTimeMode.hhmm,
    bool army = false,
  }) {
    int ms = input.inMilliseconds;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(ms);
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

bool isWhole(num number) {
  return number % 1 == 0;
}

String cleanNumber(num number) {
  if (number is double && isWhole(number)) {
    return "${number.toInt()}";
  } else {
    return "$number";
  }
}


Color getColor({required BuildContext context, required ColorType type, Brightness? brightness}) {
  if (type == ColorType.theme) {
    brightness ??= MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      return Colors.white;
    } else if (brightness == Brightness.light) {
      return Colors.black;
    } else {
      throw Exception("Unknown brightness: $brightness");
    }
  } else if (type == ColorType.primary) {
    return Theme.of(context).primaryColor;
  } else if (type == ColorType.secondary) {
    return Theme.of(context).colorScheme.secondary;
  } else {
    throw Exception("Unknown ColorType: $type");
  }
}

class UrlManager {
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

  static String addHttpPrefix(String url, {String defaultPrefix = "http"}) {
    if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('ws://') && !url.startsWith('wss://')) {
      return '$defaultPrefix://$url';
    }
    return url;
  }

  static String removeHttpPrefix(String url, {bool removeWebsocket = true}) {
    url = url.replaceAll("http://", "");
    url = url.replaceAll("https://", "");

    if (removeWebsocket) {
      url = url.replaceAll("ws://", "");
      url = url.replaceAll("wss://", "");
    }

    return url;
  }
}

String toSentenceCase(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

String toTitleCase(String input) {
  if (input.isEmpty) return input;

  return input
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : word)
      .join(' ');
}

@Deprecated("Use shareText instead.")
Future<bool> shareTextFile(bool allowShareContent, String subject, String content, String extension) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.$extension');
    final file2 = await file.writeAsString(content);
    await Share.shareXFiles([XFile(file2.path)], text: subject);
    return true;
  } catch (e) {
    if (allowShareContent) {
      print("Unable to Share.shareXFiles: falling back on Share.share: $e");
      try {
        await Share.share(content, subject: subject);
        return true;
      } catch (e2) {
        print("Unable to Share.share: $e2");
        return false;
      }
    } else {
      print("Unable to Share.share: action not allowed");
      return false;
    }
  }
}

Future<bool> shareText({required String content, required String filename, bool allowTextShare = true, String? subject}) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    final file2 = await file.writeAsString(content);
    await Share.shareXFiles([XFile(file2.path)], text: subject);
    return true;
  } catch (e) {
    if (allowTextShare) {
      print("Unable to Share.shareXFiles: falling back on Share.share: $e");
      try {
        await Share.share(content, subject: subject);
        return true;
      } catch (e2) {
        print("Unable to Share.share: $e2");
        return false;
      }
    } else {
      print("Unable to Share.share: action not allowed");
      return false;
    }
  }
}

Future<bool> sharePlainText({required String content, String? subject}) async {
  try {
    await Share.share(content, subject: subject);
    return true;
  } catch (e) {
    print("Unable to Share.share: $e");
    return false;
  }
}

double getSizeFactor({
  required BuildContext context,
  int mode = 1,
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
    case 1: // width
      size = screenSize.width;
      break;
    case 2: // height
      size = screenSize.height;
      break;
    case 3: // auto
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

int getCrossAxisCount({required BuildContext context, int factor = 180}) {
  double screenWidth = MediaQuery.of(context).size.width;
  int crossAxisCount = (screenWidth / factor).floor();
  crossAxisCount = crossAxisCount < 1 ? 1 : crossAxisCount;
  return crossAxisCount;
}

void navigate({required BuildContext context, required Widget page,
    /// mode 1: push
    /// mode 2: push and replace
    int mode = 1,
  }) {
  if (mode == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  } else if (mode == 2) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  } else {
    throw Exception("Invalid mode in navigate: $mode");
  }
}

void support(context) {
  openUrlConf(context, Uri.parse("$host/$supportEndpoint"));
}

void feedback(context) {
  openUrlConf(context, Uri.parse("$host/$feedbackEndpoint"));
}

double parseVersion(String input, {int base = 2}) {
  int letter = 0;
  RegExp regex = RegExp(r'^[a-zA-Z0-9.]*$');
  String letters = input.replaceAll(RegExp(r'[^a-zA-Z]'), '');

  if (letters.length == 1) {
    letter = letters[0].codeUnitAt(0) - 65;
  }

  if (!regex.hasMatch(input)) {
    throw Exception("Invalid version (not alphanumeric with periods): $input");
  }

  String inputS = input.replaceAll(RegExp(r'[^0-9.]'), '');
  String code = "$inputS${".${letter.toString().padLeft(base, '0')}"}";

  List<String> segments = code.split('.');
  String result = '';

  for (var segment in segments) {
    result += segment.toString().padLeft(base, '0');
  }

  print("parsed version $input to $result");
  return double.tryParse(result) ?? 0;
}

bool isNewerVersion({required String current, required String latest}) {
  double currentN = parseVersion(current);
  double latestN = parseVersion(latest);
  if (latestN > currentN) {
    return true;
  }
  return false;
}