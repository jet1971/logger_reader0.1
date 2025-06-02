// ignore_for_file: avoid_print
import 'package:ble1/data_logger/log_viewer/widgets/gps_plot/g_p_s_map_painter.dart';
import 'package:ble1/data_logger/provider/max_value_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/current_timestamp_provider.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';
import 'package:ble1/data_logger/provider/index_provider.dart';

class RightArrowIntent extends Intent {
  const RightArrowIntent();
}

class LeftArrowIntent extends Intent {
  const LeftArrowIntent();
}

bool curserModifierSet = true;
int markerIndex = 0;

class LoggerFirstScreen extends ConsumerWidget {
  const LoggerFirstScreen({
    super.key,
   // required this.fileName,
  });

  //final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedLap = ref.watch(selectedLapProvider);
    final rawData = ref.watch(dataLogProvider);
    //final lapData = ref.watch(dataLogProvider.notifier).getLap(selectedLap);
 
    final parsedFilename = ref.watch(
        filenameProvider); // This will give the formatted filename or null
   
    markerIndex = ref.watch(indexProvider); //markerIndex = ref.watch(indexProvider);

    return Scaffold(
      body: GPSMap(
      //  dataLog: lapData,
        parsedFilename: parsedFilename!,
      ),
    );
  }
}

class GPSMap extends ConsumerStatefulWidget {
  const GPSMap(
      {required this.parsedFilename,
      super.key
      });

  //final List<Map<String, dynamic>> dataLog;
  //final List<GPSPoint> dataLog;
  final String parsedFilename;

  @override
  ConsumerState<GPSMap> createState() => GPSMapState();
}

class GPSMapState extends ConsumerState<GPSMap> {
  // late final List<GPSPoint> gpsPoints;
  late  List<Map<String, dynamic>> gpsPoints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedLap = ref.watch(selectedLapProvider);
    gpsPoints = ref.read(dataLogProvider.notifier).getLap(selectedLap);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialTapPosition();
    });
  }

  Offset? tappedPosition;
  String? tappedInfo;
  final FocusNode focusNode =
      FocusNode(); // Focus node for capturing keyboard events
  int currentMarkerIndex = 0; // Track the current marker index

  @override
  void initState() {
    super.initState();
    //code to lock screen only in landscape,
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialTapPosition();
    });
    // Request focus for keyboard interaction
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    focusNode.dispose(); // Dispose of the focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final selectedLap = ref.watch(selectedLapProvider);
    gpsPoints = ref.watch(dataLogProvider.notifier).getLap(selectedLap);

    if (gpsPoints.isEmpty) {
      return const Center(child: Text('No data for this lap'));
    }

    
    final double minLat = gpsPoints
        .map((p) => p['latitude'])
        .reduce((a, b) => a < b ? a : b); // Find the minimum latitude
    final double maxLat =
        gpsPoints.map((p) => p['latitude']).reduce((a, b) => a > b ? a : b);
    final double minLon =
        gpsPoints.map((p) => p['longitude']).reduce((a, b) => a < b ? a : b);
    final double maxLon =
        gpsPoints.map((p) => p['longitude']).reduce((a, b) => a > b ? a : b);

    return KeyboardListener(
      focusNode: FocusNode(), // Listen for key events
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          // Detect when the Space key is pressed
          if (event.logicalKey == LogicalKeyboardKey.space) {
            print('Spaced press');
            setState(() {
              curserModifierSet = !curserModifierSet;
            });
          }
        }
      },
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const LeftArrowIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight):
              const RightArrowIntent(),
        },
        child: Actions(
          actions: {
            RightArrowIntent: CallbackAction<RightArrowIntent>(
              onInvoke: (intent) {
                print('Right Arrow Pressed');
                if (curserModifierSet) {
                  _moveMarker(30); // Shift + Right Arrow
                } else {
                  _moveMarker(1); // Regular Right Arrow
                }
                return null;
              },
            ),
            LeftArrowIntent: CallbackAction<LeftArrowIntent>(
              onInvoke: (intent) {
                print('Left Arrow Pressed');
                if (curserModifierSet) {
                  _moveMarker(-30); // Shift + Left Arrow
                } else {
                  _moveMarker(-1); // Regular Left Arrow
                }
                return null;
              },
            ),
          },
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  curserModifierSet = false; // Reset shift when focus is lost
                });
              }
            },
            child: Focus(
              autofocus: true,
              focusNode: focusNode,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double padding = 35.0;
                  final double usableWidth = constraints.maxWidth - 2 * padding;
                  final double usableHeight =
                      constraints.maxHeight - 2 * padding;

                  final screenPoints = gpsPoints.map((point) {
                    return _mapCoordToScreen(
                      Offset(point['latitude'], point['longitude']),
                      usableWidth,
                      usableHeight,
                      minLat,
                      maxLat,
                      minLon,
                      maxLon,
                      padding,
                    );
                  }).toList();

                  return Zoom(
                    initTotalZoomOut: true,
                    maxScale: 10.5,
                    centerOnScale: false,
                    child: GestureDetector(
                      onTapUp: (details) {
                        _handleTap(details.localPosition, screenPoints);
                      },
                      child: Container(
                        color: const Color(
                            //  0xFF15131C), // change the backgroung color of the track plot
                            0xFF21222D),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: Size(
                                  constraints.maxWidth, constraints.maxHeight),
                              painter: GPSMapPainter(screenPoints, gpsPoints),
                            ),
                            Positioned(
                                left: 5,
                                bottom: 0,
                                child: Column(
                                  children: [
                                    Text(
                                      constraints.maxWidth < 200
                                          ? // display venu
                                          widget.parsedFilename
                                          : '',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                )),
                            Positioned(
                                right: 20,
                                bottom: 20,
                                child: Column(
                                  children: [
                                    constraints.maxWidth > 200
                                        ? Text(
                                            curserModifierSet
                                                ? // display venu
                                                'Fast curser mode on, press spacebar to reset'
                                                : '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          )
                                        : const Text('')
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _moveMarker(int direction) {
    setState(() {
      // Update marker index
      markerIndex = (markerIndex + direction) %
          gpsPoints
              .length; // the modulus operator stops the index going out of bounds, eg: 2552 max 2550

      //  currentMarkerIndex = (currentMarkerIndex + direction) % gpsPoints.length;
      ref.read(currentTimeStampProvider.notifier).setScreenPositionTimeStamp(
          gpsPoints[markerIndex][
              'timestamp']); // get the timstamp of the current screen position and set in the provider

      if (markerIndex < 0) {
        markerIndex += gpsPoints.length; // Wrap around
      }

      if (markerIndex >= gpsPoints.length) {
        currentMarkerIndex = 0; // Wrap around
      }

      // Update marker position
      final gpsPoint = gpsPoints[currentMarkerIndex];
      tappedPosition = _mapCoordToScreen(
        Offset(gpsPoint['latitude'], gpsPoint['longitude']),
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
        gpsPoints.map((p) => p['latitude']).reduce((a, b) => a < b ? a : b),
        gpsPoints.map((p) => p['latitude']).reduce((a, b) => a > b ? a : b),
        gpsPoints.map((p) => p['longitude']).reduce((a, b) => a < b ? a : b),
        gpsPoints.map((p) => p['longitude']).reduce((a, b) => a > b ? a : b),
        20.0,
      );

      // Update marker info
      // tappedInfo =
      //     "Speed: ${gpsPoint.speed} mph, Time Elapsed: ${formatMilliseconds(gpsPoint.timestamp)}";
    });
  }

  Offset _mapCoordToScreen(
    Offset gpsCoord,
    double width,
    double height,
    double minLat,
    double maxLat,
    double minLon,
    double maxLon,
    double padding,
  ) {
    double xScale = width / (maxLon - minLon);
    double yScale = height / (maxLat - minLat);

    // return Offset(x, y);
    double x = padding + (gpsCoord.dy - minLon) * xScale;
    double y = padding + (maxLat - gpsCoord.dx) * yScale;
    return Offset(x, y);
  }

  String formatMilliseconds(int milliseconds) {
    // Calculate minutes, seconds, and remaining milliseconds
    int minutes = (milliseconds ~/ 60000); // 1 minute = 60000 ms
    int seconds = ((milliseconds % 60000) ~/ 1000);
    int remainingMilliseconds = (milliseconds % 1000);

    // Format the time as 'minutes:seconds.milliseconds'
    String formattedTime =
        '$minutes:${seconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(3, '0')}';

    return formattedTime;
  }

  void _handleTap(Offset tapPosition, List<Offset> screenPoints) {
    // tapPosition is whats returned from the Guesture detector,
    const double tolerance = 10.0;

    for (int i = 0; i < screenPoints.length; i++) {
      if ((screenPoints[i] - tapPosition).distance <= tolerance) {
        setState(() {
          markerIndex = i;

          tappedPosition = screenPoints[i];
          tappedInfo = "${gpsPoints[i]['speed']} mph, "
              "Time Elapsed: ${formatMilliseconds(gpsPoints[i]['timestamp'])}";

          ref
              .read(currentTimeStampProvider.notifier)
              .setScreenPositionTimeStamp(gpsPoints[i][
                  'timestamp']); // get the timstamp of the current screen position and set in the provider
        });
        return;
      }
    }
  }

  void _setInitialTapPosition() {
    markerIndex =
        gpsPoints // Find the point (index) with the maximum speed, this is what's now used for the red marker
            .asMap()
            .entries
            .reduce((a, b) => a.value['speed'] > b.value['speed'] ? a : b)
            .key;

    final maxSpeed = gpsPoints.map((p) => p['speed']).reduce((a, b) => a > b ? a : b);

    //final rpmData = ref.watch(dataLogProvider.notifier).allData;
    final maxRpm = gpsPoints.map((p) => p['rpm']).reduce((a, b) => a > b ? a : b);

    // Set the initial tap position and info
    setState(() {
      // ref.read(currentTimeStampProvider.notifier).setScreenPositionTimeStamp(
      //     gpsPoints[markerIndex][
      //         'timestamp']); // get the timstamp of the current screen position and set in the provider
      ref.read(maxValueProvider.notifier).setMaxSpeedValue(
          maxSpeed); // set max speed in a provider, use in other screens, eg scale axis in graphs, set curser positions?

      ref.read(maxValueProvider.notifier).setMaxRpmValue(
          maxRpm); // set max rpm in a provider, use in other screens,eg scale axis in graphs
    });
  }
}
