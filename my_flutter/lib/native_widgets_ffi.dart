import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'bindings.dart'; // FFI bindings from Section 1

// MARK: - Base Widget Class (Manages the native pointer)

/// Represents a FlexWidget handle created on the native side.
abstract class NativeWidget {
  /// The opaque pointer to the native Swift/UIView object.
  final WidgetRef handle;

  // Finalizer to automatically release the native widget when the Dart object is GC'd
  static final _finalizer = Finalizer<WidgetRef>((ptr) {
    widgetRelease(ptr);
  });

  NativeWidget(this.handle) {
    _finalizer.attach(this, handle, detach: this);
  }

  /// Retrieves the handle to the underlying UIKit UIView.
  Pointer<Void> getUIViewHandle() {
    return getUIViewFromWidget(handle);
  }

  // --- Builder / Modifiers ---

  /// Sets the padding (inner spacing)
  T padding<T extends NativeWidget>(double value) {
    widgetSetPadding(handle, value);
    return this as T;
  }

  /// Sets the margin (outer spacing)
  T margin<T extends NativeWidget>(double value) {
    widgetSetMargin(handle, value);
    return this as T;
  }

  /// Sets the frame size. Pass 0 or null for auto/flex.
  T frame<T extends NativeWidget>({double? width, double? height}) {
    widgetSetSize(handle, width ?? 0, height ?? 0);
    return this as T;
  }

  /// Sets the background color.
  T background<T extends NativeWidget>(Color color) {
    widgetSetBackgroundColor(
      handle,
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
      color.opacity,
    );
    return this as T;
  }

  /// Sets the corner radius.
  T cornerRadius<T extends NativeWidget>(double value) {
    widgetSetCornerRadius(handle, value);
    return this as T;
  }

  /// Sets flex grow property (equivalent to Expanded).
  /// [flex] defaults to 1.0.
  T expanded<T extends NativeWidget>({double flex = 1.0}) {
    widgetSetFlexGrow(handle, flex);
    return this as T;
  }
}

// MARK: - Leaf Widgets

class TextWidget extends NativeWidget {
  TextWidget(String text) : super(_create(text));

  static WidgetRef _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createText(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ButtonWidget extends NativeWidget {
  ButtonWidget(String text) : super(_create(text));

  static WidgetRef _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createButton(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ImageWidget extends NativeWidget {
  ImageWidget(String systemName) : super(_create(systemName));

  static WidgetRef _create(String name) {
    final cStr = name.toNativeUtf8();
    final ptr = createImage(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class SwitchWidget extends NativeWidget {
  SwitchWidget() : super(createSwitch());
}

// MARK: - Container Widgets

class ContainerWidget extends NativeWidget {
  // Now simpler: acts mainly as a wrapper.
  ContainerWidget({NativeWidget? child, bool isCard = false})
    : super(isCard ? createCard() : createContainer()) {
    if (child != null) {
      containerSetChild(handle, child.handle);
    }
  }

  // Factory for Card
  factory ContainerWidget.card({required NativeWidget child}) {
    return ContainerWidget(
      isCard: true,
      child: child,
    ).padding(16).background(Colors.white);
  }
}

// MARK: - Linear Widgets (Column/Row)

class ColumnWidget extends NativeWidget {
  ColumnWidget({List<NativeWidget> children = const []})
    : super(createColumn()) {
    _addChildren(children);
  }

  void _addChildren(List<NativeWidget> children) {
    for (var child in children) {
      linearAddChild(handle, child.handle);
    }
  }
}

class RowWidget extends NativeWidget {
  RowWidget({List<NativeWidget> children = const []}) : super(createRow()) {
    _addChildren(children);
  }

  void _addChildren(List<NativeWidget> children) {
    for (var child in children) {
      linearAddChild(handle, child.handle);
    }
  }
}
