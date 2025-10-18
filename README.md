## What is this?

This is like my other project, `localpkg-flutter`, which had some issues; so I'm redoing it. This version is object-oriented and uses better coding habits.

## How to import

In your `pubspec.yaml`:

```yaml
dependencies:
    localpkg_flutter:
        git:
            url: https://github.com/Calebh101/localpkg-flutter-2.git
            ref: main
```

## How to use

For using the global analysis template, add this to your `analysis_options.yaml`:

```yaml
include: package:localpkg_flutter/lints/default.yaml
```

There are also some scripts that can be used with `dart run <script>`:

- `locakpkg:update`: Update localpkg in the Flutter project.

## Changed items

Some notable changes:

- Everything is now object-oriented, with both static methods and extensions.
- `var.dart` is now `constants.dart`.
- `Version` is now fully reworked.

Several methods, functions, and classes have been removed, for cleanliness. Here are a few of them:

- `logger.dart` has been removed in favor of the `styled_logger` package.
- `tipjar.dart` has been removed because I don't really want it.
- `brandTheme` has been removed in favor of variable UIs, instead of a set one for all apps.
- `SettingButton` because it looks ugly.
- `Section` because it doesn't serve a purpose.

`online.dart` is also not present, and will not be present until my server rewrite is complete.