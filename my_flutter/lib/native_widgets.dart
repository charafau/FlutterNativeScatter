import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings.dart'; // Import the bindings defined above

/// Base class for all native widgets
abstract class NativeWidget {
  final Pointer<Void> handle;
  NativeWidget(this.handle);
}

class TextWidget extends NativeWidget {
  TextWidget(String text) : super(_create(text));

  static Pointer<Void> _create(String text) {
    // Must convert Dart String to C String (Utf8)
    final cStr = text.toNativeUtf8();
    final ptr = createText(cStr);
    calloc.free(cStr); // Release the temporary string memory
    return ptr;
  }
}

class ButtonWidget extends NativeWidget {
  ButtonWidget(String text) : super(_create(text));

  static Pointer<Void> _create(String text) {
    final cStr = text.toNativeUtf8();
    final ptr = createButton(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ImageWidget extends NativeWidget {
  ImageWidget(String systemName) : super(_create(systemName));

  static Pointer<Void> _create(String name) {
    final cStr = name.toNativeUtf8();
    final ptr = createImage(cStr);
    calloc.free(cStr);
    return ptr;
  }
}

class ContainerWidget extends NativeWidget {
  ContainerWidget({
    double padding = 0,
    double width = 0,
    double height = 0,
    double r = 1,
    double g = 1,
    double b = 1,
    NativeWidget? child,
    bool isCard = false,
  }) : super(isCard ? createCard() : createContainer()) {
    // Set properties
    containerSetProperties(handle, padding, width, height, r, g, b);

    // Set child if present
    if (child != null) {
      containerSetChild(handle, child.handle);
    }
  }

  // Factory for the specific Card variant
  factory ContainerWidget.card({required NativeWidget child}) {
    return ContainerWidget(
      isCard: true,
      padding: 16,
      r: 1,
      g: 1,
      b: 1, // White
      child: child,
    );
  }
}

class ColumnWidget extends NativeWidget {
  ColumnWidget({List<NativeWidget> children = const []})
    : super(createColumn()) {
    for (var child in children) {
      linearAddChild(handle, child.handle);
    }
  }
}

class RowWidget extends NativeWidget {
  RowWidget({List<NativeWidget> children = const []}) : super(createRow()) {
    for (var child in children) {
      linearAddChild(handle, child.handle);
    }
  }
}
