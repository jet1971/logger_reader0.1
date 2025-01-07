import 'package:ble1/const/constant.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final int id;
  final String label;
  final IconData icon;

  MenuItem(this.id, this.label, this.icon);
}

List<MenuItem> menuItems = [
  MenuItem(1, 'Lap 1', Icons.numbers),
  MenuItem(2, 'Lap 2', Icons.numbers),
  MenuItem(3, 'Lap 3', Icons.numbers),
  MenuItem(4, 'Lap 4', Icons.numbers),
];

class ChooseLapMenu extends StatefulWidget {
  const ChooseLapMenu({super.key});

  @override
  State<ChooseLapMenu> createState() => _ChooseLapMenuState();
}

class _ChooseLapMenuState extends State<ChooseLapMenu> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<MenuItem>(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: menuButton,
            ),
            borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: menuButton,
        outlineBorder: null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      width: 220,
      initialSelection: menuItems.first,
       leadingIcon: const Icon(Icons.numbers),

      // leadingIcon: const Icon(Icons.speed),
      //   controller: menuController,
      //   requestFocusOnTap: true,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          menuButton,
        ),
      ),

      textStyle: const TextStyle(
          color: menuButtonText, fontSize: 15,),
      label: null,

      onSelected: (MenuItem? menu) {
        setState(() {
          // selectedMenu = menu;
        });
      },
      dropdownMenuEntries:
          menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
        return DropdownMenuEntry<MenuItem>(
            value: menu, label: menu.label, leadingIcon: Icon(menu.icon));
      }).toList(),
    );
  }
}
