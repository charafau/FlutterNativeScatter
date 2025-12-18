import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:my_flutter/bindings.dart';
import 'package:my_flutter/native_widgets_ffi.dart';

void main() {
  print('started!');
  addNumbers(2, 3);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// C function signature (Pointer<Int32> Function(Int32, Int32))
typedef AddNumbersC = Int32 Function(Int32 a, Int32 b);

// Dart function signature (int Function(int, int))
typedef AddNumbersDart = int Function(int a, int b);
final DynamicLibrary nativeLib = DynamicLibrary.process();

// Look up the symbol and cast it
final AddNumbersDart addNumbers = nativeLib
    .lookupFunction<AddNumbersC, AddNumbersDart>('add_numbers');

class _MyHomePageState extends State<MyHomePage> {
  void buildAndRetrieveNativeView() {
    // 1. Build the widget tree using the compositional approach
    final headerRow = RowWidget(
      children: [
        ImageWidget("person.crop.circle.fill"),
        TextWidget(" John Doe"),
      ],
    );

    final cardContentColumn = ColumnWidget(
      children: [
        headerRow,
        TextWidget("This UI is built in FlexLayout and composed in Dart!"),
        SwitchWidget(),
        ButtonWidget("Execute Action"),
      ],
    );

    final card = ContainerWidget.card(child: cardContentColumn);

    final root = ContainerWidget(child: card)
        .frame(width: 300, height: 500)
        .padding(10)
        .background(const Color(0xFFF2F2F2)); // Light Gray

    // 2. Trigger the Layout on the native side
    const rootWidth = 300.0;
    const rootHeight = 500.0;
    widgetLayoutRoot(root.handle, rootWidth, rootHeight);

    // 3. Get the final UIView handle to pass back to the Platform Channel
    final uiViewHandle = root.getUIViewHandle();
    final address = uiViewHandle.address;
    print("Native UIView handle (address) ready: ${uiViewHandle.address}");
    print("Calling Swift FFI function with address: $address");
    // In a real app, you would now use a MethodChannel to send uiViewHandle.address
    // to Swift/Objective-C to display the UIView via a UIViewController or Platform View.
    displayWidgetInViewController(address);
  }

  void invokeNative() {
    addNumbers(2, 3);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: .center,
          children: [
            const Text('Create card using UIKit from dart'),
            ElevatedButton(
              onPressed: buildAndRetrieveNativeView,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
