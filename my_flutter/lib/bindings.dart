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
typedef WidgetReleaseC = Void Function(WidgetRef widget);
typedef WidgetSetPaddingC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetMarginC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetSizeC = Void Function(WidgetRef widget, Float w, Float h);
typedef WidgetSetBgColorC =
    Void Function(WidgetRef widget, Float r, Float g, Float b, Float a);
typedef WidgetSetCornerRadiusC = Void Function(WidgetRef widget, Float radius);
typedef WidgetSetFlexGrowC = Void Function(WidgetRef widget, Float value);
typedef WidgetSetOnClickC =
    Void Function(
      WidgetRef widget,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef WidgetLogC = Void Function(Pointer<Utf8> message);
typedef CreateListViewC = WidgetRef Function();
typedef ListViewBuilderCallbackC = Void Function(WidgetRef list, Int64 index);
typedef ListViewUpdateItemC =
    Void Function(WidgetRef list, Int64 index, WidgetRef item);
typedef ListViewSetBuilderC =
    Void Function(
      WidgetRef list,
      Int64 count,
      Pointer<NativeFunction<ListViewBuilderCallbackC>> callback,
    );
typedef ContainerSetChildC = Void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildrenC =
    Void Function(WidgetRef parent, Pointer<WidgetRef> children, Int64 count);
typedef WidgetLayoutRootC =
    Void Function(WidgetRef root, Float width, Float height);
typedef GetUIViewFromWidgetC = Pointer<Void> Function(WidgetRef root);

// Dart Function Signatures (for execution)
typedef CreateTextDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateButtonDart = WidgetRef Function(Pointer<Utf8> text);
typedef CreateImageDart = WidgetRef Function(Pointer<Utf8> name);
typedef CreateVoidDart = WidgetRef Function();
typedef WidgetReleaseDart = void Function(WidgetRef widget);
typedef WidgetSetPaddingDart = void Function(WidgetRef widget, double value);
typedef WidgetSetMarginDart = void Function(WidgetRef widget, double value);
typedef WidgetSetSizeDart = void Function(WidgetRef widget, double w, double h);
typedef WidgetSetBgColorDart =
    void Function(WidgetRef widget, double r, double g, double b, double a);
typedef WidgetSetCornerRadiusDart =
    void Function(WidgetRef widget, double radius);
typedef WidgetSetFlexGrowDart = void Function(WidgetRef widget, double value);
typedef WidgetSetOnClickDart =
    void Function(
      WidgetRef widget,
      Pointer<NativeFunction<Void Function()>> callback,
    );
typedef WidgetLogDart = void Function(Pointer<Utf8> message);
typedef CreateListViewDart = WidgetRef Function();
typedef ListViewUpdateItemDart =
    void Function(WidgetRef list, int index, WidgetRef item);
typedef ListViewSetBuilderDart =
    void Function(
      WidgetRef list,
      int count,
      Pointer<NativeFunction<ListViewBuilderCallbackC>> callback,
    );
typedef ContainerSetChildDart =
    void Function(WidgetRef parent, WidgetRef child);
typedef LinearAddChildrenDart =
    void Function(WidgetRef parent, Pointer<WidgetRef> children, int count);
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

final widgetSetPadding = nativeLib
    .lookupFunction<WidgetSetPaddingC, WidgetSetPaddingDart>(
      'widget_set_padding',
    );
final widgetSetMargin = nativeLib
    .lookupFunction<WidgetSetMarginC, WidgetSetMarginDart>('widget_set_margin');
final widgetSetSize = nativeLib
    .lookupFunction<WidgetSetSizeC, WidgetSetSizeDart>('widget_set_size');
final widgetSetBackgroundColor = nativeLib
    .lookupFunction<WidgetSetBgColorC, WidgetSetBgColorDart>(
      'widget_set_background_color',
    );
final widgetSetCornerRadius = nativeLib
    .lookupFunction<WidgetSetCornerRadiusC, WidgetSetCornerRadiusDart>(
      'widget_set_corner_radius',
    );
final widgetSetFlexGrow = nativeLib
    .lookupFunction<WidgetSetFlexGrowC, WidgetSetFlexGrowDart>(
      'widget_set_flex_grow',
    );
final widgetSetOnClick = nativeLib
    .lookupFunction<WidgetSetOnClickC, WidgetSetOnClickDart>(
      'widget_set_on_click',
    );
final widgetLog = nativeLib.lookupFunction<WidgetLogC, WidgetLogDart>(
  'widget_log',
);
final createListView = nativeLib
    .lookupFunction<CreateListViewC, CreateListViewDart>('create_list_view');
final listViewSetBuilder = nativeLib
    .lookupFunction<ListViewSetBuilderC, ListViewSetBuilderDart>(
      'list_view_set_builder',
    );
final listViewUpdateItem = nativeLib
    .lookupFunction<ListViewUpdateItemC, ListViewUpdateItemDart>(
      'list_view_update_item',
    );
final createSafeArea = nativeLib
    .lookupFunction<CreateListViewC, CreateListViewDart>('create_safe_area');
final containerSetChild = nativeLib
    .lookupFunction<ContainerSetChildC, ContainerSetChildDart>(
      'container_set_child',
    );
final linearAddChildren = nativeLib
    .lookupFunction<LinearAddChildrenC, LinearAddChildrenDart>(
      'linear_add_children',
    );

final widgetLayoutRoot = nativeLib
    .lookupFunction<WidgetLayoutRootC, WidgetLayoutRootDart>(
      'widget_layout_root',
    );
final getUIViewFromWidget = nativeLib
    .lookupFunction<GetUIViewFromWidgetC, GetUIViewFromWidgetDart>(
      'get_ui_view_from_widget',
    );

final widgetRelease = nativeLib
    .lookupFunction<WidgetReleaseC, WidgetReleaseDart>('widget_release');

typedef DisplayWidgetC = Void Function(Int32 viewHandleAddress);

// Dart Function Signature
typedef DisplayWidgetDart = void Function(int viewHandleAddress);

// New Function Lookup
final displayWidgetInViewController = nativeLib
    .lookupFunction<DisplayWidgetC, DisplayWidgetDart>(
      'display_widget_in_view_controller',
    );
