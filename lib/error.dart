import 'dart:io';

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

  void warn({String? code, bool? trace}) {
    logger.warn(toString(), code: code, trace: trace ?? false);
  }

  void error({String? code, bool? trace}) {
    logger.error(toString(), code: code, trace: trace ?? false);
  }

  void invoke({String? code, bool? trace}) {
    throw Exception(toString());
  }
}

class CrashPageApp extends StatelessWidget {
  final String? message;
  final String? description;
  final String? code;
  final bool support;
  final bool close;
  final bool copy;
  final Function? reset;
  final Function? closeFunction;
  final VoidCallback? retryFunction;
  final String? trace;

  const CrashPageApp({
    super.key,
    this.message,
    this.description,
    this.code,
    this.support = true,
    this.reset,
    this.close = false,
    this.copy = true,
    this.closeFunction,
    this.retryFunction,
    this.trace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calebh101 Launcher: Error',
      theme: brandTheme(seedColor: Colors.red),
      darkTheme: brandTheme(seedColor: Colors.red, darkMode: true),
      home: CrashPage(message: message, description: description, code: code, support: support, reset: reset, close: close, closeFunction: closeFunction, retryFunction: retryFunction, copy: copy, trace: trace),
    );
  }
}

class CrashPage extends StatefulWidget {
  final String? message;
  final String? description;
  final String? code;
  final bool support;
  final bool close;
  final bool copy;
  final Function? reset;
  final Function? closeFunction;
  final VoidCallback? retryFunction;
  final String? trace;

  const CrashPage({
    super.key,
    this.message,
    this.description,
    this.code,
    this.support = true,
    this.reset,
    this.close = false,
    this.copy = true,
    this.closeFunction,
    this.retryFunction,
    this.trace,
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
                      widget.trace!,
                      trimLines: 2,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: "Show Full Stack Trace",
                      trimExpandedText: "Collapse",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.support)
                    TextButton(
                      child: Text("Support"),
                      onPressed: () {
                        support(context);
                      },
                    ),
                    if (widget.reset != null)
                    TextButton(
                      child: Text("Reset"),
                      onPressed: () async {
                        if (await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "Are you sure you want to delete all app data? This cannot be undone. Only use this if closing and reopening the app or waiting for the issue to be resolved does not fix this issue.") ?? false) {
                          widget.reset!();
                        }
                      },
                    ),
                    if (widget.close)
                    TextButton(
                      child: Text("Close"),
                      onPressed: () {
                        (widget.closeFunction ?? () {
                          exit(0);
                        })();
                      },
                    ),
                    if (widget.retryFunction != null)
                    TextButton(
                      child: Text("Retry"),
                      onPressed: widget.retryFunction,
                    ),
                    if (widget.copy)
                    TextButton(onPressed: () {
                      Clipboard.setData(ClipboardData(text: "Message: ${widget.message}\nCode: ${widget.code}\n\nContent:\n${widget.description}"));
                      SnackBarManager.show(context, "Copied to clipboard!");
                    }, child: Text("Copy")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void CrashScreen({String? message, String? description, String? code, Function? reset, bool support = true, bool close = false, bool copy = true, Function? closeFunction, VoidCallback? retryFunction, String? trace}) {
  runApp(CrashPageApp(message: message, description: description, code: code, support: support, reset: reset, close: close, copy: copy, closeFunction: closeFunction, retryFunction: retryFunction, trace: trace));
}

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

  String format({int? end}) {
    return _format(toString(), end: end);
  }
}