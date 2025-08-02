// import 'package:ble1/const/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ble1/data_logger/provider/datalog_provider.dart';

// class MenuItem {
//   final int id;
//   final String label;
//   // final IconData icon;

//   MenuItem(this.id, this.label);
// }

// class ChooseLapMenu extends ConsumerStatefulWidget  {
//   const ChooseLapMenu({super.key});

//   @override
//   ConsumerState<ChooseLapMenu> createState() => _ChooseLapMenuState();
// }

// class _ChooseLapMenuState extends ConsumerState<ChooseLapMenu> {
//   MenuItem? selectedLap;

//     @override
// Widget build(BuildContext context) {
//   final lapMap = ref.watch(dataLogProvider.notifier).laps;
//   final lapCount = lapMap.length;

//   // Generate menu items from available laps
//   List<MenuItem> menuItems = List.generate(lapCount, (index) {
//     if (index == 0) return MenuItem(index, 'Out Lap');
//     return MenuItem(index, 'Lap $index');
//   });

//   // Get the currently selected lap from the provider
//   final TextEditingController menuController = TextEditingController();

//     return DropdownMenu<MenuItem>(
//       inputDecorationTheme: InputDecorationTheme(
//         enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: menuButton,
//             ),
//             borderRadius: BorderRadius.circular(10)),
//         filled: true,
//         fillColor: menuButton,
//         outlineBorder: null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//         ),
//       ),
//       width: 220,

//       leadingIcon: const Icon(Icons.numbers),

//       initialSelection: selectedLap,
//       controller: menuController,

//     onSelected: (MenuItem? menu) {
//         if (menu != null) {
//           ref.read(selectedLapProvider.notifier).state = menu.id;
//           setState(() {
//             selectedLap = menu;
//           });
//         }
//       },

//       menuStyle: MenuStyle(
//         backgroundColor: WidgetStateProperty.all<Color>(
//           menuButton,
//         ),
//       ),

//       label: null, // the one above the box
//       textStyle: const TextStyle(
//         color: menuButtonText,
//         fontSize: 15,
//       ),

//       dropdownMenuEntries:

//    menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
//         return DropdownMenuEntry<MenuItem>(
//           value: menu,
//           label: menu.label,
//           leadingIcon: const Icon(Icons.numbers),
//         );
//       }).toList(),
//     );
//   }
// }

//------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ble1/data_logger/provider/datalog_provider.dart';
// //import 'package:ble1/data_logger/provider/selected_lap_provider.dart'; // ← your lap provider here

// class ChooseLapMenu extends ConsumerWidget {
//   const ChooseLapMenu({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedLap = ref.watch(selectedLapProvider);
//     final allLaps = ref.watch(dataLogProvider.notifier).laps.keys.toList()
//       ..sort();

//     return DropdownButton<int>(
//       value: selectedLap,
//       onChanged: (int? newValue) {
//         if (newValue != null) {
//           ref.read(selectedLapProvider.notifier).state = newValue;
//         }
//       },
//       dropdownColor: Colors.grey[850],
//       style: const TextStyle(color: Colors.white, fontSize: 16),
//       underline: Container(height: 2, color: Colors.orange),
//       icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//       items: allLaps.map<DropdownMenuItem<int>>((int lapNum) {
//         final label = lapNum == 0 ? 'Out Lap' : 'Lap $lapNum';
//         return DropdownMenuItem<int>(
//           value: lapNum,
//           child: Text(label),
//         );
//       }).toList(),
//     );
//   }
// }

//------------------------------------------------------------------------------------
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ble1/data_logger/provider/datalog_provider.dart';
// import 'package:ble1/const/constant.dart'; // For menuButton, menuButtonText

// class ChooseLapMenu extends ConsumerWidget {
//   const ChooseLapMenu({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedLap = ref.watch(selectedLapProvider);
//     final lapMap = ref.watch(dataLogProvider.notifier).laps;
//     final fastestLap = ref.watch(dataLogProvider.notifier).getFastestLap();

//     final laps = lapMap.keys.toList()..sort();

//     String formatLapTime(int milliseconds) {
//       final minutes = milliseconds ~/ 60000;
//       final seconds = (milliseconds % 60000) ~/ 1000;
//       final ms = milliseconds % 1000;
//       return '$minutes:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
//     }

//     final menuItems = laps.map((lap) {
//       final data = lapMap[lap]!;
//       final lapTime = (data.isNotEmpty)
//           ? data.last['timestamp'] - data.first['timestamp']
//           : 0;

//       final label =
//            lap == 0 ? '  Out Lap' : '  Lap $lap  -  ${formatLapTime(lapTime)}';
//          // lap == 0 ? 'Out Lap' : 'Lap $lap';

//       return DropdownMenuEntry<int>(
//         value: lap,
//         label: label,
//         leadingIcon: const Icon(Icons.flag),
//       );
//     }).toList();

//     return DropdownMenu<int>(
//       initialSelection: selectedLap,
//       onSelected: (int? lap) {
//         if (lap != null) {
//           ref.read(selectedLapProvider.notifier).state = lap;
//         }
//       },
//       dropdownMenuEntries: menuItems,
//       width: 220,
//     //  label: const Text('Lap', style: TextStyle(color: menuButtonText)),
//       controller: TextEditingController(),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: menuButton,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: menuButton),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       textStyle: const TextStyle(color: menuButtonText, fontSize: 15),
//       menuStyle: MenuStyle(
//         backgroundColor: WidgetStateProperty.all(menuButton),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/const/constant.dart'; // For menuButton, menuButtonText

class ChooseLapMenu extends ConsumerWidget {
  const ChooseLapMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLap = ref.watch(selectedLapProvider);
    final lapMap = ref.watch(dataLogProvider.notifier).laps;

    final laps = lapMap.keys.toList()..sort();

    String formatLapTime(int milliseconds) {
      final minutes = milliseconds ~/ 60000;
      final seconds = (milliseconds % 60000) ~/ 1000;
      final ms = milliseconds % 1000;
      return '$minutes:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
    }

    // Create a map of lap -> lap time
    final lapTimes = {
      for (final lap in laps)
        if (lapMap[lap]!.length > 1)
          lap: lapMap[lap]!.last['timestamp'] - lapMap[lap]!.first['timestamp']
    };

    // Exclude lap 0 if desired
    lapTimes.remove(0);
    lapTimes
        .remove(laps.last); // Remove the last lap from fastest lap calculation

    // Find the fastest lap, default to lap 0 if no other laps exist
    final bestLap = lapTimes.isNotEmpty
        ? lapTimes.entries.reduce((a, b) => a.value < b.value ? a : b).key
        : 0; // Default to lap 0 if lapTimes is empty

    final menuItems = laps.map((lap) {
      final data = lapMap[lap]!;
      final lapTime = (data.isNotEmpty)
          ? data.last['timestamp'] - data.first['timestamp']
          : 0;

      final isBest = lap == bestLap;

      final label = lap == 0
          ? 'Out Lap'
          : isBest
              ? '⭐ Lap $lap - ${formatLapTime(lapTime)}'
              : 'Lap $lap - ${formatLapTime(lapTime)}';

      return DropdownMenuEntry<int>(
        value: lap,
        label: label,
        leadingIcon: isBest
            ? const Icon(Icons.star, color: Colors.amber)
            : const Icon(Icons.flag),
        style: isBest
            ? const ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
      );
    }).toList();

    return DropdownMenu<int>(
      initialSelection: selectedLap,
      onSelected: (int? lap) {
        if (lap != null) {
          ref.read(selectedLapProvider.notifier).state = lap;
        }
      },
      dropdownMenuEntries: menuItems,
      width: 220,
      // label: const Text('Lap', style: TextStyle(color: menuButtonText)),
      controller: TextEditingController(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: menuButton,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: menuButton),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textStyle: const TextStyle(color: menuButtonText, fontSize: 15),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(menuButton),
      ),
    );
  }
}
