import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

export 'package:localpkg_flutter/theme.dart' show GradientColor, GradientText;

/// An Android-like box or button.
class Setting extends StatelessWidget {
  /// The title of the box.
  final String title;

  /// The description of the box.
  final String? description;

  /// The current value shown.
  final String? value;

  /// What happens when it's clicked.
  final GestureTapCallback? action;

  /// An Android-like box or button.
  const Setting({super.key, required this.title, this.description, this.value, this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null)
            Text(
              value!,
            ),
          ],
        ),
      ),
    );
  }
}

/// Title for a section of [Setting]s.
class SettingTitle extends StatelessWidget {
  /// The overall title of the section.
  final String title;

  /// The optional description of the section.
  final String? description;

  /// The children of the section. This is optional.
  final List<Widget> children;

  /// Title for a section of [Setting]s.
  const SettingTitle({super.key, required this.title, this.description, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

/// A boxy button.
class BlockButton extends StatelessWidget {
  /// The content of the button.
  final Widget child;

  /// The size of the button, in pixels.
  final double size;

  /// What happens when the button is clicked.
  final VoidCallback action;

  late final double _w;
  late final double _h;

  /// A boxy button. [width] and [height] default to [size] and [size] / 2, respectively.
  BlockButton({super.key, required this.child, required this.size, required this.action, double? width, double? height}) {
    _w = width ?? size;
    _h = height ?? (size / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(_w, _h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // Square edges
          ),
        ),
        onPressed: action,
        child: child,
      ),
    );
  }
}

/// This widget combines a [SingleChildScrollView] and a [Scrollbar], using one [ScrollController].
class ScrollWidget extends StatelessWidget {
  /// The widget key of [SingleChildScrollView].
  final Key? scrollViewKey;

  /// The widget key of [Scrollbar].
  final Key? scrollbarKey;

  /// Content of the [ScrollWidget].
  final Widget child;

  /// Decides if a [Scrollbar] should be included.
  final bool showScrollbar;

  /// The [ScrollController] of both the [SingleChildScrollView] and [Scrollbar].
  final ScrollController? controller;

  /// The default [ScrollController] of both the [SingleChildScrollView] and [Scrollbar].
  final ScrollController defaultController = ScrollController();

  /// `thumbVisibility` of [Scrollbar].
  final bool? thumbVisibility;

  /// `trackVisibility` of [Scrollbar].
  final bool? trackVisibility;

  /// `scrollbarThickness` of [Scrollbar].
  final double? scrollbarThickness;

  /// `scrollbarRadius` of [Scrollbar].
  final Radius? scrollbarRadius;

  /// `scrollbarNotificationsPredicate` of [Scrollbar].
  final bool Function(ScrollNotification)? scrollbarNotificationsPredicate;

  /// `scrollbarInteractive` of [Scrollbar].
  final bool? scrollbarInteractive;

  /// `scrollbarOrientation` of [Scrollbar].
  final ScrollbarOrientation? scrollbarOrientation;

  /// `scrollViewScrollDirection` of [SingleChildScrollView].
  final Axis scrollViewScrollDirection;

  /// `scrollViewReverse` of [SingleChildScrollView].
  final bool scrollViewReverse;

  /// `scrollViewPadding` of [SingleChildScrollView].
  final EdgeInsetsGeometry? scrollViewPadding;

  /// `scrollViewPrimary` of [SingleChildScrollView].
  final bool? scrollViewPrimary;

  /// `scrollViewPhysics` of [SingleChildScrollView].
  final ScrollPhysics? scrollViewPhysics;

  /// `scrollViewDragStartBehavior` of [SingleChildScrollView].
  final DragStartBehavior scrollViewDragStartBehavior;

  /// `scrollViewClipBehavior` of [SingleChildScrollView].
  final Clip scrollViewClipBehavior;

  /// `scrollViewHitTestBehavior` of [SingleChildScrollView].
  final HitTestBehavior scrollViewHitTestBehavior;

  /// `scrollViewRestorationId` of [SingleChildScrollView].
  final String? scrollViewRestorationId;

  /// `scrollViewKeyboardDismissBehavior` of [SingleChildScrollView].
  final ScrollViewKeyboardDismissBehavior scrollViewKeyboardDismissBehavior;

  /// This widget combines a [SingleChildScrollView] and a [Scrollbar], using one [ScrollController].
  ScrollWidget({super.key, this.scrollViewKey, this.scrollbarKey, required this.child, this.showScrollbar = true, this.controller, this.thumbVisibility, this.trackVisibility, this.scrollbarThickness, this.scrollbarRadius, this.scrollbarNotificationsPredicate, this.scrollbarInteractive, this.scrollbarOrientation, this.scrollViewScrollDirection = Axis.vertical, this.scrollViewReverse = false, this.scrollViewPadding, this.scrollViewPrimary, this.scrollViewPhysics, this.scrollViewDragStartBehavior = DragStartBehavior.start, this.scrollViewClipBehavior = Clip.hardEdge, this.scrollViewHitTestBehavior = HitTestBehavior.opaque, this.scrollViewRestorationId, this.scrollViewKeyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual});

  @override
  Widget build(BuildContext context) {
    Widget result;
    Widget scrollView = SingleChildScrollView(
      key: scrollViewKey,
      child: child,
      controller: controller ?? defaultController,
      scrollDirection: scrollViewScrollDirection,
      reverse: scrollViewReverse,
      padding: scrollViewPadding,
      primary: scrollViewPrimary,
      physics: scrollViewPhysics,
      dragStartBehavior: scrollViewDragStartBehavior,
      clipBehavior: scrollViewClipBehavior,
      hitTestBehavior: scrollViewHitTestBehavior,
      restorationId: scrollViewRestorationId,
      keyboardDismissBehavior: scrollViewKeyboardDismissBehavior,
    );

    if (showScrollbar) {
      result = Scrollbar(
        key: scrollbarKey,
        child: scrollView,
        controller: controller ?? defaultController,
        thumbVisibility: thumbVisibility,
        trackVisibility: trackVisibility,
        thickness: scrollbarThickness,
        radius: scrollbarRadius,
        notificationPredicate: scrollbarNotificationsPredicate,
        interactive: scrollbarInteractive,
        scrollbarOrientation: scrollbarOrientation,
      );
    } else {
      result = scrollView;
    }

    return result;
  }
}