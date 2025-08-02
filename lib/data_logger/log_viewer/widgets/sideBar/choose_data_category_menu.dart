import 'package:ble1/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/chosen_content_provider.dart';

class MenuItem {
  final String id;
  final String label;
  final IconData icon;

  MenuItem(this.id, this.label, this.icon);
}

List<MenuItem> menuItems = [
  MenuItem('track_report', 'Track Report', Icons.data_exploration_sharp),
  MenuItem('engine_data', 'Engine', Icons.speed_sharp),
  MenuItem('suspension_data', 'Debug/Raw', Icons.motorcycle_outlined),
  MenuItem('section_times', 'Linked Graphs', Icons.timer),
];

class ChooseScreenMenu extends ConsumerStatefulWidget {
  const ChooseScreenMenu({super.key});

  @override
  ConsumerState<ChooseScreenMenu> createState() => _ChooseScreenMenuState();
}

class _ChooseScreenMenuState extends ConsumerState<ChooseScreenMenu> {
  // Track the selected menu item
  MenuItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    final TextEditingController menuController = TextEditingController();

    // Set the initial selection for the menu
    selectedMenu ??= menuItems.firstWhere(// Find the first menu item that matches the chosen content
      (menu) => menu.id == ref.watch(chosenContentProvider),// Watch the chosen content provider to get the current selection
      orElse: () => menuItems.first,// Default to the first item if no match is found
    );
    //selectedMenu ??= menuItems.first;

    return DropdownMenu<MenuItem>(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: menuButton,
            ),
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: menuButton,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      width: 220,
      initialSelection: selectedMenu,
      controller: menuController,
      onSelected: (MenuItem? menu) {
        setState(() {
          selectedMenu = menu; // Update selected menu item
        });
        ref
            .read(chosenContentProvider.notifier)
            .setChosenContent(selectedMenu?.id);
      },
      leadingIcon: selectedMenu != null
          ? Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 8.0), // Add space between icon and text
              child: Icon(selectedMenu!.icon),
            )
          : const Padding(
              padding: EdgeInsets.only(
                  right:
                      8.0), // Add space between icon and text for default icon
              child: Icon(Icons.data_exploration),
            ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          Colors.black,
        ),
      ),
      textStyle: const TextStyle(
        color: menuButtonText,
        fontSize: 15,
      ),
      label: null, // the one above the box
      enableSearch: false,
      enableFilter: false,
      dropdownMenuEntries:
          menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
        return DropdownMenuEntry<MenuItem>(
            value: menu,// Set the value of the menu item
            label: menu.label,// Set the label of the menu item
            leadingIcon: Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0), // Add padding for spacing in dropdown
              child: Icon(menu.icon),
            ));
      }).toList(),
    );
  }
}
