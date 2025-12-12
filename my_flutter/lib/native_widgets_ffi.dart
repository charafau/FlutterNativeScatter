import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'bindings.dart'; // FFI bindings from Section 1

// MARK: - Base Widget Class (Manages the native pointer)

/// Represents a FlexWidget handle created on the native side.
abstract class NativeWidget {
  /// The opaque pointer to the native Swift/UIView object.
  final WidgetRef handle;

  NativeWidget(this.handle);

  /// Retrieves the handle to the underlying UIKit UIView.
  /// This is used to pass the final view back to a platform view or host view controller.
  Pointer<Void> getUIViewHandle() {
    return getUIViewFromWidget(handle);
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
  ContainerWidget({
    double padding = 0,
    double width = 0, // 0 means auto/flex in the C binding
    double height = 0, // 0 means auto/flex in the C binding
    Color color = Colors.white,
    NativeWidget? child,
    bool isCard = false,
  }) : super(isCard ? createCard() : createContainer()) {
    // Convert Flutter Color to R, G, B floats (0.0 to 1.0)
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // 1. Set properties
    containerSetProperties(handle, padding, width, height, r, g, b);

    // 2. Set child (composition)
    if (child != null) {
      containerSetChild(handle, child.handle);
    }
  }

  // Factory for Card
  factory ContainerWidget.card({required NativeWidget child}) {
    return ContainerWidget(
      isCard: true,
      padding: 16,
      color: Colors.white,
      child: child,
    );
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
