// Dispays the startline cordinates in Settings/Venues screen

import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/venue_model.dart';
import 'package:ble1/data_logger/models/venue.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble1/settings/check_server_for_venue_update.dart';
import 'package:isar/isar.dart';

class Venues extends StatefulWidget {
  const Venues(
      {super.key,
      required this.updateAvailable,
      required this.settingsCharacteristic});
  final bool updateAvailable;
  final BluetoothCharacteristic settingsCharacteristic;

  @override
  State<Venues> createState() => _VenuesState();
}

class _VenuesState extends State<Venues> {
  //List<dynamic> venues = [];
  List<Venue> venues = [];

  VenueListInfo? _venueListInfo;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isUpdating = widget.updateAvailable;
    checkForVenueListUpdate();
  }

  Future<void> checkForVenueListUpdate() async {
    try {
      _venueListInfo = await fetchLatestVenueListInfo();
      setState(() {
        venues = _venueListInfo!.venues;
      });
 
     if (_isUpdating) {
        await sendVenueList(widget.settingsCharacteristic);
        await saveVenueListToIsar(venues);
      }

    } catch (e) {
      print('Error checking for venue list update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
        child: Row(
          children: [
            Text(
          _isUpdating ? 'Update In Progress...' : 'Up To Date',
          style: TextStyle(color: const Color.fromARGB(255, 108, 244, 113), fontSize: 18),
            ),
            const SizedBox(width: 6),
          ],
        ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: const Text('Startline Coordinates'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView.builder(
          itemCount: venues.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150, // used to keep track name aligned
                      child: Text(
                        venues[index].name,
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'LAT 1:',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        venues[index].lat1.toStringAsFixed(6),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                      child: Text(
                        '|',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'LON 1:',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        venues[index].lon1.toStringAsFixed(6),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'LAT 2:',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        venues[index].lat2.toStringAsFixed(6),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                      child: Text(
                        '|',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: Text(
                        'LON 2:',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        venues[index].lon2.toStringAsFixed(6),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.exit_to_app,
              color: Colors.blue,
              size: 26,
            ),
            const SizedBox(width: 6),
            const Text(
              'EXIT',
              style: TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------------

  Future<void> sendVenueList(BluetoothCharacteristic c) async {
    try {
      final venueJson = {
        "cmd": "SAVE_VENUES",
        "count": venues.length,
        "venues": venues.map((v) => v.toJson()).toList(),
      };

      final jsonString = jsonEncode(venueJson);
      final jsonBytes = utf8.encode(jsonString);
      final totalBytes = jsonBytes.length;

      print("📦 Venue JSON is $totalBytes bytes long");

      const int chunkSize = 500;
      final int totalChunks = (totalBytes / chunkSize).ceil();

      // Send header first
      final header = jsonEncode({
        "cmd": "START_VENUE_TRANSFER",
        "totalBytes": totalBytes,
        "version": _venueListInfo!.version,
      });

      print('header: $header');

      await c.write(utf8.encode(header), withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 100));

      // Now send chunks
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end =
            (start + chunkSize > totalBytes) ? totalBytes : start + chunkSize;

        final chunk = jsonBytes.sublist(start, end);
        await c.write(chunk, withoutResponse: false);

        print("✅ Sent chunk ${i + 1}/$totalChunks (${chunk.length} bytes)");
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print("✅ All venue chunks sent");
    } catch (e) {
      print("❌ Failed to send venues list: $e");
    }

    setState(() {
      _isUpdating = false;
    });
  }
//--------------------------------------------------------------------------------------
Future<void> saveVenueListToIsar(List<Venue> venueList) async {
    final isar = Isar.getInstance();

    final models = venueList.map((v) {
      return VenueModel()
        ..name = v.name
        ..code = v.code;
    }).toList();

    await isar?.writeTxn(() async {
      await isar.venueModels.clear(); // optional
      await isar.venueModels.putAll(models);
    });
  }

  //--------------------------------------------------------------------------------------
}
