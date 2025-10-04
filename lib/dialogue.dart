import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localpkg/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A way to show "snack bars", or little popups on screen.
class SnackBarManager {
  SnackBarManager._();

  /// Show a simple text-based snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(BuildContext context, String content) {
    return showCustom(context, Text(content));
  }

  /// Show a snack bar with a custom containing widget.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showCustom(BuildContext context, Widget content) {
    final manager = ScaffoldMessenger.of(context);
    manager.clearSnackBars();

    return manager.showSnackBar(
      SnackBar(
        content: content,
      ),
    );
  }
}

/// A way to show "snack bars", or little popups on screen.
/// 
/// This was added as a quicker method of showing snack bars, rather than using [SnackBarManager].
extension SnackBarManagerExtension on SnackBar {
  /// Show a simple text-based snack bar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(BuildContext context, String content) {
    return SnackBarManager.show(context, content);
  }

  /// Show a snack bar with a custom containing widget.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showCustom(BuildContext context, Widget content) {
    return SnackBarManager.showCustom(context, content);
  }
}

/// For showing simple dialogues.
class SimpleDialogue {
  SimpleDialogue._();

  /// Show a simple dialogue.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget content,
    bool cancel = false,
    bool fullscreen = false,
    bool copy = false,
    String? copyText,
  }) {
    if (copyText == null && copy == true) {
      copy = false;
    }

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: fullscreen ? MediaQuery.of(context).size.width * 0.95 : null,
            height: fullscreen ? MediaQuery.of(context).size.height * 0.95 : null,
            child: content,
          ),
          actions: [
            if (copy)
            TextButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyText!));
                SnackBarManager.show(context, "Copied to clipboard!");
              },
            ),
            if (cancel)
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
            ),
          ],
        );
      },
    );
  }

  /// Show a dialogue that you can't click out of.
  static void showConstant({required BuildContext context, String? title, String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          child: AlertDialog(
            title: title != null ? Text(title) : SizedBox.shrink(),
            content: message != null ? Text(message) : SizedBox.shrink(),
            actions: [],
          ),
        );
      },
    );
  }

  /// Show a dialogue if it has not been shown before.
  static Future<bool> showFirstTriggerDialogue({required BuildContext context, required String title, required List<Widget> children, bool cancel = false, String key = "", bool ignorePrefs = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = ignorePrefs ? false : (prefs.getBool(key) ?? false);
    bool selection = false;

    if (!shown) {
      if (!ignorePrefs) prefs.setBool(key, true);
      int i = 0;

      for (Widget child in children) {
        selection = await SimpleDialogue.show(context: context, title: "$title${children.length <= 1 ? "" : " (${i + 1} of ${children.length})"}", content: child, fullscreen: true) ?? false;
        i++;
      }
    } else {
      selection = false;
    }

    return selection;
  }
}

/// A class for showing confirmation dialogues.
class ConfirmationDialogue {
  ConfirmationDialogue._();

  /// Show a URL confirmation.
  static Future<bool> showUrlConfirmation(BuildContext context, Uri url) async {
    if ((await show(context: context, title: "Open URL?", description: "Do you want to open $url in your default browser or app?")) ?? false) {
      UrlManager.openUrl(url: url);
      return true;
    } else {
      return false;
    }
  }

  /// Show a simple confirmation.
  static Future<bool?> show({required BuildContext context, required String title, String? description, bool onOff = false}) async {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: description != null ? Text(description) : SizedBox.shrink(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(onOff ? 'On' : 'Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(onOff ? 'Off' : 'No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}