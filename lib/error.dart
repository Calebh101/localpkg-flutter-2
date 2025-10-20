import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localpkg_flutter/dialogue.dart';
import 'package:readmore/readmore.dart';

/// A specific [MaterialApp] that is run when your app has an unrecoverable error.
class CrashPageApp extends StatelessWidget {
  /// The content of this [MaterialApp].
  final CrashPage child;

  /// A specific [MaterialApp] that is run when your app has an unrecoverable error.
  ///
  /// [child] is required.
  const CrashPageApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calebh101 Launcher: Error',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: child,
    );
  }

  /// A quick way to run a new [CrashPageApp].
  static void run({required CrashPage child}) {
    Widget app = CrashPageApp(child: child);
    runApp(app);
  }
}

/// A class defining a specific button found on the [CrashPage].
class CrashPageButton {
  /// The text shown.
  final String text;

  /// What happens when you run it.
  final void Function(BuildContext context, String? message, String? description, Object? code, StackTrace? trace) action;

  /// A class defining a specific button found on the [CrashPage].
  ///
  /// [text] and [action] are required.
  CrashPageButton(this.text, {required this.action});

  /// A built-in button for copying an error.
  static CrashPageButton copy = CrashPageButton("Copy", action: (context, message, description, code, trace) {
    Clipboard.setData(ClipboardData(text: "Message: $message\nCode: $code\n\nContent:\n$description"));
    SnackBarManager.show(context, "Copied to clipboard!");
  });
}

/// A [StatefulWidget] for telling the user that something went very wrong.
class CrashPage extends StatefulWidget {
  /// A short message to tell the user what wrong.
  final String? message;

  /// Use this to actually describe more info about what went wrong.
  final String? description;

  /// The error code.
  final Object? code;

  /// The optional stack trace, if you want to provide this information.
  final StackTrace? trace;

  /// The buttons shown on the page, that the user can interact with.
  final List<CrashPageButton> buttons;

  /// A [StatefulWidget] for telling the user that something went very wrong.
  ///
  /// No parameter is required, although a [message] is recommended.
  const CrashPage({
    super.key,
    this.message,
    this.description,
    this.code,
    this.trace,
    this.buttons = const [],
  });

  @override
  State<CrashPage> createState() => _CrashPageState();
}

class _CrashPageState extends State<CrashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.amber,
                  size: 72,
                ),
                Text("Whoa!", style: TextStyle(fontSize: 32, color: Colors.redAccent)),
                Text(widget.message ?? "A critical error occured.", style: TextStyle(fontSize: 18)),
                if (widget.description != null)
                Text(widget.description!, style: TextStyle(fontSize: 12)),
                if (widget.code != null)
                Text("Code ${widget.code}", style: TextStyle(fontSize: 12)),
                if (widget.trace != null)
                Column(
                  children: [
                    Text("Stack Trace", style: TextStyle(fontSize: 18)),
                    ReadMoreText(
                      widget.trace!.toString(),
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: "Show Full Stack Trace",
                      trimExpandedText: "Collapse",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.buttons.map((button) {
                    return TextButton(
                      child: Text(button.text),
                      onPressed: () => button.action.call(context, widget.message, widget.description, widget.code, widget.trace),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}