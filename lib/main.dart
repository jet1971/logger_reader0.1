// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'data_logger/ble_folder/screens/bluetooth_off_screen.dart';
import 'dart:async';
import 'package:ble1/data_logger/provider/note_provider.dart';
import 'package:ble1/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_logger/ble_folder/screens/scan_screen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:ble1/data_logger/log_viewer/widgets/sideBar/notes/models/note_database.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/venue_model.dart';


// final colorScheme = ColorScheme.fromSeed(
//   brightness: Brightness.dark,
//   seedColor: const Color.fromARGB(255, 102, 6, 247),
//   surface: const Color.fromARGB(255, 56, 49, 66),
// );

// final theme = ThemeData().copyWith(
//   scaffoldBackgroundColor: colorScheme.surface,
//   colorScheme: colorScheme,

// );

// final colorScheme = ColorScheme.fromSeed(
//   brightness: Brightness.dark,
//   seedColor: const Color.fromARGB(255, 102, 6, 247),
//   surface: const Color.fromARGB(255, 56, 49, 66),

// );

// final theme = ThemeData(

//   useMaterial3: true, // be explicit
//   colorScheme: colorScheme,
// ).copyWith(

//   scaffoldBackgroundColor: colorScheme.surface,
//   dialogTheme: const DialogThemeData(
//     backgroundColor: Colors.white,
//     surfaceTintColor: Colors.transparent,
//   ),
// );

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark, // keep app dark overall
  seedColor: const Color.fromARGB(255, 102, 6, 247),
  surface: const Color.fromARGB(255, 56, 49, 66),
);

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,

  // 👇 global dialog styling
  dialogTheme: const DialogThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
  ),

  // 👇 make TextFields inside dialogs black-on-white
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: Colors.black87),
    hintStyle: TextStyle(color: Colors.black54),
    prefixStyle: TextStyle(color: Colors.black87),
    suffixStyle: TextStyle(color: Colors.black87),
    iconColor: Colors.black87,
    prefixIconColor: Colors.black87,
    suffixIconColor: Colors.black87,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black38),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black87, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
    ),
  ),

  // 👇 cursor + selection inside TextFields
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Color(0x33000000),
    selectionHandleColor: Colors.black,
  ),
);

// textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
//   titleSmall: GoogleFonts.ubuntuCondensed(
//     fontWeight: FontWeight.bold,
//);
// titleMedium: GoogleFonts.ubuntuCondensed(
//   fontWeight: FontWeight.bold,
//   fontSize: 18,
// ),
// titleLarge: GoogleFonts.ubuntuCondensed(
//   fontWeight: FontWeight.bold,
// ),

// Define a provider for NoteDatabase
// final noteDatabaseProvider = Provider<NoteDatabase>((ref) {
//   return NoteDatabase();
// });

void main() async {
  FlutterBluePlus.setLogLevel(LogLevel.info, color: true);
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await initializeIsar();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const Home(),
      ),
    ),
  );
}

// This widget shows BluetoothOffScreen or
// ScanScreen depending on the adapter state
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({super.key});

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
      debugShowCheckedModeBanner: false,
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
