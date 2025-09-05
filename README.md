## What is this?

This is like my other project, `localpkg-flutter`, which had some issues; so I'm redoing it. This version is object-oriented and uses better coding habits.

## How to import

In your `pubspec.yaml`:

```yaml
dependencies:
    localpkg:
        git:
            url: https://github.com/Calebh101/localpkg-flutter-2.git
            ref: main # 'main' for latest commit, 'dev' for latest development commit (may not always be updated), or a specific commit hash for a specific commit
```

## How to use

For using the global analysis template, add this to your `analysis_options.yaml`:

```yaml
include: package:localpkg/lints/default.yaml
```

## Notes

`logger.dart` has been omitted in favor of the upcoming `styled_logger` package.