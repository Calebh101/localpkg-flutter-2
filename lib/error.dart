import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localpkg/dialogue.dart';
import 'package:readmore/readmore.dart';

class ManualError extends Error {
  final String message;

  ManualError(
    this.message,
  );

  @override
  String toString() {
    return 'ManualError: $message';
  }
}

class CrashPageApp extends StatelessWidget {
  final CrashPage child;

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

  static void run({required CrashPage child}) {
    Widget app = CrashPageApp(child: child);
    runApp(app);
  }
}

class CrashPageButton {
  final String text;
  final void Function(BuildContext context, String? message, String? description, String? code, StackTrace? trace) action;
  CrashPageButton(this.text, {required this.action});

  static CrashPageButton copy = CrashPageButton("Copy", action: (context, message, description, code, trace) {
    Clipboard.setData(ClipboardData(text: "Message: $message\nCode: $code\n\nContent:\n$description"));
    SnackBarManager.show(context, "Copied to clipboard!");
  });
}

class CrashPage extends StatefulWidget {
  final String? message;
  final String? description;
  final String? code;
  final StackTrace? trace;
  final List<CrashPageButton> buttons;

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