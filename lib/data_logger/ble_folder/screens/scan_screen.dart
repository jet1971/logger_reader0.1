// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble1/data_logger/server_folder/choose_datalog_download.dart';
import 'device_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

// UUID of the service you are looking for
  final Guid targetServiceUUID = Guid('BAAD');
  bool _hasNavigated = false; // Add this flag to ensure navigation happens once

bool _isBluetoothCheckInProgress =
      false; // Prevents multiple Bluetooth checks

  Future<void> checkBluetoothStateAndPermissions() async {
    if (_isBluetoothCheckInProgress) return; // Prevents duplicate calls
    _isBluetoothCheckInProgress = true;

    try {
      // Check if Bluetooth is available
      bool isBluetoothAvailable = await FlutterBluePlus.isSupported;
      if (!isBluetoothAvailable) {
        print("Bluetooth not available");
        return;
      }

      // Check if Bluetooth is on
      bool isBluetoothOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      if (!isBluetoothOn) {
        print("Bluetooth is off. Please turn it on.");
        return;
      }

      // Request necessary permissions if required
      await FlutterBluePlus.turnOn();

      // Proceed to scan if all checks pass
      await onScanPressed();
    } catch (e) {
      print("Error checking Bluetooth state: $e");
    } finally {
      _isBluetoothCheckInProgress = false;
    }
  }

  @override
  void initState() {
    super.initState();
    //   Future.delayed(const Duration(seconds: 1), () {
    //  onScanPressed();
    // });

    checkBluetoothStateAndPermissions().then((_) {
      onScanPressed();
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      // Filter devices that advertise the specific service
      final filteredDevices = results.where((result) {
        return result.advertisementData.serviceUuids
            .contains(targetServiceUUID);
      }).toList();

      // Automatically connect to the first device that has the service
      if (filteredDevices.isNotEmpty && !_hasNavigated) {
        _hasNavigated = true; // Set this flag to prevent repeated navigation
        FlutterBluePlus
            .stopScan(); // Stop the scan once we find a matching device
        onConnectPressed(filteredDevices.first.device);
      }

      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> onScanPressed() async {
    if (_isScanning) return; // Avoid duplicate scan start requests
    _isScanning = true;

    try {
      var withServices = [targetServiceUUID]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [targetServiceUUID], // Filter by the target service UUID
      );
    } catch (e) {
      print("Error starting scan: $e");
    } finally {
      _isScanning = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) async {
    try {
      await device.connect();
      await device.discoverServices(); // Ensure the services are discovered

      // Check if the device has the specific service before navigating
      List<BluetoothService> services = await device.discoverServices();

      // UUID of the characteristic you are looking for
      final Guid readFileCharacteristicUUID = Guid('F00D');
      BluetoothCharacteristic? readFileDetailCharacteristic;

      final Guid deleteFileCharacteristicUUID = Guid('D00D');
      BluetoothCharacteristic? deleteFileCharacteristic;

      final Guid downloadFileCharacteristicUUID = Guid('A00D');
      BluetoothCharacteristic? downloadFileCharacteristic;

      for (BluetoothService service in services) {
        if (service.uuid == targetServiceUUID) {
          // Find the characteristic in the service
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid == readFileCharacteristicUUID) {
              readFileDetailCharacteristic = characteristic;
              print('Found Read File Characteristic');
            } else if (characteristic.uuid == deleteFileCharacteristicUUID) {
              deleteFileCharacteristic = characteristic;
              print('Found Delete File Characteristic');
            } else if (characteristic.uuid == downloadFileCharacteristicUUID) {
              downloadFileCharacteristic = characteristic;
              print('Found Download File Characteristic');

              break;
            }
          }
          if (readFileDetailCharacteristic != null &&
              deleteFileCharacteristic != null &&
              downloadFileCharacteristic != null) {
            break; // Break out of the inner loop if both are found
          }
        }
      }

      // Check if the characteristic is found before navigating
      if (readFileDetailCharacteristic != null &&
          deleteFileCharacteristic != null &&
          downloadFileCharacteristic != null &&
          mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => //DeviceScreen(device: device)
                ChooseLogDownload(
              readFileDetailCharacteristic: readFileDetailCharacteristic!,
              deleteFileCharacteristic: deleteFileCharacteristic!,
              downloadFileCharacteristic: downloadFileCharacteristic!,
            ),
          ),
        );
      } else {
        print("Target service or characteristic not found.");
      }
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Connect Error:", e),
          success: false);
    }
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed, child: const Text("SCAN"));
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeviceScreen(device: d),
                settings: const RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
