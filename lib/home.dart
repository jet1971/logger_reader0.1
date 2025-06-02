import 'package:flutter/material.dart';
import 'package:ble1/data_logger/ble_folder/screens/scan_screen.dart';
import 'package:ble1/data_logger/log_viewer/open_existing_datalogs.dart';



import 'package:ble1/temp.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: 10,
            ),
          ),
    
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    Text(
                      'JT Electronics Data Logger  ',
                      style: TextStyle(
                          color: Color.fromARGB(255, 249, 249, 250),
                          fontSize: 26),
                    ),
                    //   SizedBox(
                    //   height: 40,
                    // ),
                    Icon(
                      Icons.bluetooth,
                      size: 30,
                      color: Color.fromARGB(255, 196, 193, 193),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 10,
                // ),
                 Text(
                  'www.jtmc.co.uk',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(
                  height: 50,
                ),
                HomePageButton(
                  title: 'Download Data Logs',
                  page: ScanScreen(),
                ),
                SizedBox(
                  height: 30,
                ),
                HomePageButton(
                  title: 'Open Existings Data Logs',
                  page: ListSavedFiles(),
                ),
                SizedBox(
                  height: 30,
                ),
                HomePageButton(
                  title: 'Logger Settings',
                  page: TestPage(),
                ),
                SizedBox(
                  height: 30,
                ),
                HomePageButton(title: 'ToolBox'),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageButton extends StatelessWidget {
  const HomePageButton({
    super.key,
    required this.title,
    this.page,
  });
  final String title;
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: const Color.fromARGB(255, 196, 193, 193),
            ),
            borderRadius: BorderRadius.circular(7)),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        width: 300,
        alignment: Alignment.center,
        child: Text(
          title,
          //style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
      onTap: () {
        if (page != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => page!,
            ),
          );
        } else {
          // Handle what happens when the page is not provided
          print("No page assigned for this button.");
        }
      },
    );
  }
}
