import 'dart:ffi';
import 'package:ffi/ffi.dart';

// On iOS, symbols from the app executable (Runner) are available via 'process()'.
final DynamicLibrary nativeLib = DynamicLibrary.process();

// --- Type Definitions ---
typedef WidgetRef = Pointer<Void>; // Common Widget Handle

// C Function Signatures (for lookup)
typedef CreateTextC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateButtonC = WidgetRef Function(Pointer<Utf8> text);
typedef CreateImageC = WidgetRef Function(Pointer<Utf8> name);
typedef CreateVoidC = WidgetRef Function();
typedef ContainerSetPropsC =
    Void Function(
      WidgetRef,
      Float padding,
      Float w,
      Float h,
      Float r,
      Float g,
      Float b,
    );
typedef ContainerSetChildC = Void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildC = Void Function(WidgetRef parent, WidgetRef child);
typedef WidgetLayoutRootC =
    Void Function(WidgetRef root, Float width, Float height);
typedef GetUIViewFromWidgetC = Pointer<Void> Function(WidgetRef root);

// Dart Function Signatures (for execution)
typedef CreateTextDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateButtonDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateImageDart = WidgetRef Function(Pointer<Utf8> name);
typedef CreateVoidDart = WidgetRef Function();
typedef ContainerSetPropsDart =
    void Function(
      WidgetRef,
      double padding,
      double w,
      double h,
      double r,
      double g,
      double b,
    );
typedef ContainerSetChildDart =
    void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildDart = void Function(WidgetRef parent, WidgetRef child);
typedef WidgetLayoutRootDart =
    void Function(WidgetRef root, double width, double height);
typedef GetUIViewFromWidgetDart = Pointer<Void> Function(WidgetRef root);

// --- Function Lookups ---

final createText = nativeLib.lookupFunction<CreateTextC, CreateTextDart>(
  'create_text',
);
final createButton = nativeLib.lookupFunction<CreateButtonC, CreateButtonDart>(
  'create_button',
);
final createImage = nativeLib.lookupFunction<CreateImageC, CreateImageDart>(
  'create_image',
);
final createSwitch = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_switch',
);
final createContainer = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_container',
);
final createCard = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_card',
);
final createColumn = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_column',
);
final createRow = nativeLib.lookupFunction<CreateVoidC, CreateVoidDart>(
  'create_row',
);

final containerSetProperties = nativeLib
    .lookupFunction<ContainerSetPropsC, ContainerSetPropsDart>(
      'container_set_properties',
    );
final containerSetChild = nativeLib
    .lookupFunction<ContainerSetChildC, ContainerSetChildDart>(
      'container_set_child',
    );
final linearAddChild = nativeLib
    .lookupFunction<LinearAddChildC, LinearAddChildDart>('linear_add_child');

final widgetLayoutRoot = nativeLib
    .lookupFunction<WidgetLayoutRootC, WidgetLayoutRootDart>(
      'widget_layout_root',
    );
final getUIViewFromWidget = nativeLib
    .lookupFunction<GetUIViewFromWidgetC, GetUIViewFromWidgetDart>(
      'get_ui_view_from_widget',
    );

typedef DisplayWidgetC = Void Function(Int32 viewHandleAddress);

// Dart Function Signature
typedef DisplayWidgetDart = void Function(int viewHandleAddress);

// New Function Lookup
final displayWidgetInViewController = nativeLib
    .lookupFunction<DisplayWidgetC, DisplayWidgetDart>(
      'display_widget_in_view_controller',
    );
