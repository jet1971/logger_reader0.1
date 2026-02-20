import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/current_timestamp_provider.dart';
import 'package:ble1/data_logger/provider/index_provider.dart';
import 'package:ble1/data_logger/log_viewer/graph_screens/metric_line_chart.dart';

class RightArrowIntent extends Intent {
  const RightArrowIntent();
}

class LeftArrowIntent extends Intent {
  const LeftArrowIntent();
}

class EscIntent extends Intent {
  const EscIntent();
}

class _SpaceIntent extends Intent {
  const _SpaceIntent();
}

const leftReservedSize = 52.0;
int touchResponseTimestamp =
    0; // Global variable to store the timestamp of the touch response
bool curserModifierSet = true;
int markerIndex = 0;

List<FlSpot> _convertToSpotsWithFilter(List<Map<String, dynamic>> dataLog,
    String dataName, String timestamp, double threshold) {
  List<FlSpot> points = [];
  String lastParsed = ''; // Store the last parsed values to prevent duplicates
  double lastValidPoint = 0; // To hold the last valid point(rpm value)

  for (int i = 0; i < dataLog.length; i++) {
    String currentParsed =
        "${(dataLog[i][dataName])},${(dataLog[i][timestamp])},";
    // //  print('currentParsed $currentParsed');

    // Check if any of the values are empty or invalid
    if (dataLog[i][dataName] == null || dataLog[i][timestamp] == null) {
      //    print("Skipping invalid data at index $i:}");
      continue; // Skip to the next iteration
    }

    double data = (dataLog[i][dataName]);
    int elapsedTime = (dataLog[i][timestamp]);

    if (points.isEmpty) {
      lastValidPoint = data;
      points.add(FlSpot(elapsedTime.toDouble(), data));
      lastParsed = currentParsed;
    } else {
      double difference = (data - lastValidPoint).abs();
      if (difference <= threshold) {
        points.add(FlSpot(elapsedTime.toDouble(), data));
        lastValidPoint = data;
        lastParsed = currentParsed;
      } else {
        data = lastValidPoint;
        points.add(FlSpot(elapsedTime.toDouble(), data));
        print("Skipping... $difference");
        print("last valid data was added as filler so chart aligns");
      }
    }
  }
  return points;
}

class ZoomedGraphs extends ConsumerStatefulWidget {
  const ZoomedGraphs({super.key});

  @override
  ConsumerState<ZoomedGraphs> createState() => _ZoomedGraphsState();
}

class _ZoomedGraphsState extends ConsumerState<ZoomedGraphs> {
  int touchIndex =
      0; // Shared cursor position (used by both charts, and track plot)

  final FocusNode focusNode =
      FocusNode(); // Focus node for capturing keyboard events

  late TransformationController _transformationController;
  final bool _isPanEnabled = true;
  final bool _isScaleEnabled = true;

  @override
  void initState() {
    // _reloadData();
    _transformationController = TransformationController();
    // Request focus for keyboard interaction
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose(); // Dispose of the focus node
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLap = ref.watch(selectedLapProvider);
    final lapData = ref.read(dataLogProvider.notifier).getLap(selectedLap);

    List<FlSpot> afrSpots = _convertToSpotsWithFilter(
        lapData,
        'afr',
        'timestamp',
        20); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');

    List<FlSpot> rpmSpots = _convertToSpotsWithFilter(
        lapData,
        'rpm',
        'timestamp',
        40500); //dataName, timestamp, threshold, if for example the rpm is 1000 and the next is 10000, it will be skipped

    List<FlSpot> speedSpots = _convertToSpotsWithFilter(
        lapData,
        'speed',
        'timestamp',
        20); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');

    List<FlSpot> tpsSpots = _convertToSpotsWithFilter(
        lapData,
        'tps',
        'timestamp',
        200); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');

    List<FlSpot> engineTemperatureSpots = _convertToSpotsWithFilter(
        lapData,
        'coolantTemperature',
        'timestamp',
        2000); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');
    List<FlSpot> oilTemperatureSpots = _convertToSpotsWithFilter(
        lapData,
        'oilTemperature',
        'timestamp',
        2000); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');

    // Ensure focus is requested after build so focus isn't lost when parent widgets
    // change.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!focusNode.hasFocus) focusNode.requestFocus();
    });

    // Use Shortcuts/Actions entirely (avoid KeyboardListener) so we don't
    // attach the same `focusNode` to multiple Focus widgets and create
    // ancestor loops. Add a `SpaceIntent` to handle the space key.
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const LeftArrowIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const RightArrowIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const EscIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const _SpaceIntent(),
      },
      child: Actions(
        actions: {
          RightArrowIntent: CallbackAction<RightArrowIntent>(
            onInvoke: (intent) {
              {
                setState(() {
                  touchIndex += 1; // Regular Right Arrow
                  ref.read(indexProvider.notifier).setIndex(touchIndex);

                  ref
                      .read(currentTimeStampProvider.notifier)
                      .setScreenPositionTimeStamp(
                        rpmSpots.isNotEmpty &&
                                touchIndex >= 0 &&
                                touchIndex < rpmSpots.length
                            ? rpmSpots[touchIndex].x.toInt()
                            : 0,
                      );
                });
              }
              return null;
            },
          ),

          LeftArrowIntent: CallbackAction<LeftArrowIntent>(
            onInvoke: (intent) {
              {
                setState(() {
                  touchIndex -= 1; // Regular Left Arrow
                  ref.read(indexProvider.notifier).setIndex(
                      touchIndex); // set the index in the provider, needed for the track plot

                  ref
                      .read(currentTimeStampProvider
                          .notifier) // get the current timestamp from the provider, needed for updating values in left values panel
                      .setScreenPositionTimeStamp(
                        rpmSpots.isNotEmpty &&
                                touchIndex >= 0 &&
                                touchIndex < rpmSpots.length
                            ? rpmSpots[touchIndex].x.toInt()
                            : 0,
                      );
                });
              }
              return null;
            },
          ),
          EscIntent: CallbackAction<EscIntent>(
            onInvoke: (intent) {
              _transformationReset();
              return null;
            },
          ),
          _SpaceIntent: CallbackAction<_SpaceIntent>(
            onInvoke: (intent) {
              setState(() {
                curserModifierSet = !curserModifierSet;
              });
              return null;
            },
          ),

          //---------------------------------------------------------------------------------------------
        },
        child: Focus(
          autofocus: true,
          focusNode: focusNode,
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                curserModifierSet = false; // Reset shift when focus is lost
              });
            }
          },
          child: GestureDetector(
            onDoubleTapDown: (details) {
              _zoomAtPosition(details.localPosition);
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    spacing: 1,
                    children: [
                      MetricLineChart(
                        minY: 0,
                        maxY: speedSpots.isNotEmpty
                            ? speedSpots
                                    .map((spot) => spot.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                10
                            : 180,
                        spots: speedSpots,
                        yLabel: 'Speed',
                        color: Colors.green,
                        dashLineColour: Colors.green,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder:
                            (x) => // build bottom titles based on x value (timestamp)
                                x.toInt().toString(), // or format timestamp

                        // Center the chart on the current touch position when scaling
                        onTouch: (idx, x, y) {
                          // Update the touch index and timestamp in the provider when a touch event occurs
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      ),
                      MetricLineChart(
                        minY: 0,
                        maxY: rpmSpots.isNotEmpty
                            ? rpmSpots
                                    .map((spot) => spot.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                500
                            : 16000,
                        spots: rpmSpots,
                        yLabel: 'RPM',
                        color: Colors.blue,
                        dashLineColour: Colors.amber,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder: (x) =>
                            x.toInt().toString(), // or format timestamp
                        onTouch: (idx, x, y) {
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      ),
                      MetricLineChart(
                        minY: 10,
                        maxY: afrSpots.isNotEmpty
                            ? afrSpots
                                    .map((spot) => spot.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                2
                            : 20,
                        spots: afrSpots,
                        yLabel: 'AFR',
                        showBottomTitle: false,
                        color: Colors.amber,
                        dashLineColour: Colors.amber,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder: (x) =>
                            x.toInt().toString(), // or format timestamp
                        onTouch: (idx, x, y) {
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      ),
                      MetricLineChart(
                        minY: 0,
                        maxY: 110,
                        spots: tpsSpots,
                        yLabel: 'TPS',
                        showBottomTitle: false,
                        color: Colors.white,
                        dashLineColour: Colors.white,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder: (x) =>
                            x.toInt().toString(), // or format timestamp
                        onTouch: (idx, x, y) {
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      ),
                      MetricLineChart(
                        minY: 0,
                        maxY: 110,
                        spots: engineTemperatureSpots,
                        yLabel: 'Engine Temp',
                        showBottomTitle: false,
                        color: Colors.red,
                        dashLineColour: Colors.amber,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder: (x) =>
                            x.toInt().toString(), // or format timestamp
                        onTouch: (idx, x, y) {
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      ),
                      MetricLineChart(
                        minY: 0,
                        maxY: oilTemperatureSpots.isNotEmpty
                            ? oilTemperatureSpots
                                    .map((spot) => spot.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                10
                            : 110,

                        spots: oilTemperatureSpots,
                        yLabel: 'Oil Temp',
                        showBottomTitle: false,
                        color: const Color.fromARGB(255, 54, 206, 244),
                        dashLineColour: Colors.amber,
                        panEnabled: _isPanEnabled,
                        scaleEnabled: _isScaleEnabled,
                        transformationController: _transformationController,
                        touchIndex: touchIndex,
                        bottomTitleBuilder: (x) =>
                            x.toInt().toString(), // or format timestamp
                        onTouch: (idx, x, y) {
                          final ts = x.toInt();
                          ref
                              .read(currentTimeStampProvider.notifier)
                              .setScreenPositionTimeStamp(ts);
                          ref.read(indexProvider.notifier).setIndex(idx);
                          setState(() => touchIndex = idx);
                        },
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 20,
                  child: _TransformationButtons(
                    controller: _transformationController,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------------------------------------------------

  void _transformationZoomIn() {
    setState(() {
      _transformationController.value *= Matrix4.diagonal3Values(
        1.1,
        1.1,
        1,
      );
    });
  }

  void _zoomAtPosition(Offset position) {
    // Calculate the focal point in the transformed coordinate space
    final currentMatrix = _transformationController.value;

    // Get the size of the transformation widget (approximate)
    final focalX = position.dx;
    final focalY = position.dy;

    // Create zoom transformation centered at the tap point
    final zoom = Matrix4.identity()
      ..translate(focalX, focalY)
      ..scale(2.1, 2.1, 1.0)
      ..translate(-focalX, -focalY);

    setState(() {
      _transformationController.value = currentMatrix * zoom;
    });
  }

  void _transformationReset() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14),
        Text(
          'Bitcoin Price History',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          '2023/12/19 - 2024/12/17',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }
}

class _TransformationButtons extends StatelessWidget {
  const _TransformationButtons({
    required this.controller,
  });

  final TransformationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(63, 0, 0, 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 0,
          ),
          Tooltip(
            message: 'Zoom in',
            child: IconButton(
              icon: const Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onPressed: _transformationZoomIn,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Move left',
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: _transformationMoveLeft,
                ),
              ),
              Tooltip(
                message: 'Reset zoom',
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: _transformationReset,
                ),
              ),
              Tooltip(
                message: 'Move right',
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: _transformationMoveRight,
                ),
              ),
            ],
          ),
          Tooltip(
            message: 'Zoom out',
            child: IconButton(
              icon: const Icon(
                Icons.minimize,
                size: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onPressed: _transformationZoomOut,
            ),
          ),
        ],
      ),
    );
  }

  void _transformationReset() {
    controller.value = Matrix4.identity();
  }

  void _transformationZoomIn() {
    controller.value *= Matrix4.diagonal3Values(
      1.1,
      1.1,
      1,
    );
  }

  void _transformationMoveLeft() {
    controller.value *= Matrix4.translationValues(
      20,
      0,
      0,
    );
  }

  void _transformationMoveRight() {
    controller.value *= Matrix4.translationValues(
      -20,
      0,
      0,
    );
  }

  void _transformationZoomOut() {
    controller.value *= Matrix4.diagonal3Values(
      0.9,
      0.9,
      1,
    );
  }
}

// Helper method to find the closest spot index based on x-coordinate
int _findClosestSpotIndex(List<FlSpot> spots, double xValue) {
  int closestIndex = 0;
  double minDistance = (spots[0].x - xValue).abs();

  for (int i = 1; i < spots.length; i++) {
    double distance = (spots[i].x - xValue).abs();
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = i;
    }
  }
  return closestIndex;
}
