import 'package:ble1/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/chosen_data_provider.dart';

class MenuItem {
  final String id;
  final String label;
  final IconData icon;

  MenuItem(this.id, this.label, this.icon);
}

List<MenuItem> menuItems = [
  MenuItem('speed', 'Speed', Icons.speed_sharp),
  MenuItem('afr', 'AFR', Icons.speed_sharp),
  MenuItem('coolantTemperature', 'Engine Temp', Icons.thermostat_outlined),
  MenuItem('airTemperature', 'Air Temp', Icons.thermostat_outlined),
  MenuItem('tps', 'TPS', Icons.speed_sharp),
  MenuItem('rpm', 'RPM', Icons.speed_sharp),
  MenuItem('batteryVoltage', 'Battery Volts', Icons.speed_sharp),
  MenuItem('airboxPressure', 'Air Pressure', Icons.speed_sharp),
  MenuItem('oilPressure', 'Oil Pressure', Icons.speed_sharp),
];

class ChoosePlotDataMenu extends ConsumerStatefulWidget {
  const ChoosePlotDataMenu({super.key});

  @override
  ConsumerState<ChoosePlotDataMenu> createState() => _ChoosePlotDataMenuState();
}

class _ChoosePlotDataMenuState extends ConsumerState<ChoosePlotDataMenu> {
  // Track the selected menu item
  MenuItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    final TextEditingController menuController = TextEditingController();

    // Set the initial selection for the menu
    selectedMenu ??= menuItems.firstWhere(
      // Find the first menu item that matches the chosen content
      (menu) =>
          menu.id ==
          ref.watch(
              chosenDataProvider), // Watch the chosen content provider to get the current selection
      orElse: () =>
          menuItems.first, // Default to the first item if no match is found
    );
    selectedMenu ??= menuItems.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
      child: DropdownMenu<MenuItem>(
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: cardBackgroundColor,
              ),
              borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Color.fromRGBO(0, 0, 0, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        width: 200,
        initialSelection: selectedMenu,
        controller: menuController,
        onSelected: (MenuItem? menu) {
          setState(() {
            selectedMenu = menu; // Update selected menu item
          });
          ref.read(chosenDataProvider.notifier).setChosenData(selectedMenu?.id);
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
            cardBackgroundColor, // Set the background color of the menu
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
              value: menu, // Set the value of the menu item
              label: menu.label, // Set the label of the menu item
              leadingIcon: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0), // Add padding for spacing in dropdown
                child: Icon(menu.icon),
              ));
        }).toList(),
      ),
    );
  }
}
