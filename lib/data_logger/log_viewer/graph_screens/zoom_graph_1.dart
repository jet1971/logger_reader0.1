import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
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

    return KeyboardListener(
        focusNode: FocusNode(),
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

        //---------------------------------------------------------------------------------------------

        child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                  const LeftArrowIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight):
                  const RightArrowIntent(),
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
                  //---------------------------------------------------------------------------------------------
                },
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() {
                        curserModifierSet =
                            false; // Reset shift when focus is lost
                      });
                    }
                  },
                  child: Focus(
                    autofocus: true,
                    focusNode: focusNode,
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Column(
                            spacing: 1,
                            children: [
                              // LayoutBuilder(
                              //   builder: (context, constraints) {
                              //     final width = constraints.maxWidth;
                              //     return width >= 380
                              //         ? Row(
                              //             children: [
                              //               const SizedBox(width: leftReservedSize),
                              //               // const _ChartTitle(),
                              //               const Spacer(),
                              //               Center(
                              //                 child: _TransformationButtons(
                              //                   controller: _transformationController,
                              //                 ),
                              //               ),
                              //             ],
                              //           )
                              //         : Column(
                              //             children: [
                              //               //   const _ChartTitle(),
                              //               const SizedBox(height: 16),
                              //               _TransformationButtons(
                              //                 controller: _transformationController,
                              //               ),
                              //             ],
                              //           );
                              //   },
                              // ),
                      
                              MetricLineChart(
                                minY: 0,
                                maxY: 180,
                                spots: speedSpots,
                                yLabel: 'Speed',
                                color: Colors.green,
                                dashLineColour: Colors.green,
                                panEnabled: _isPanEnabled,
                                scaleEnabled: _isScaleEnabled,
                                transformationController:
                                    _transformationController,
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
                                  maxY: 14000,
                                spots: rpmSpots,
                                yLabel: 'RPM',
                                color: Colors.blue,
                                dashLineColour: Colors.amber,
                                panEnabled: _isPanEnabled,
                                scaleEnabled: _isScaleEnabled,
                                transformationController:
                                    _transformationController,
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
                                    maxY: 20,
                                spots: afrSpots,
                                yLabel: 'AFR',
                                showBottomTitle: false,
                                color: Colors.amber,
                                dashLineColour: Colors.amber,
                                panEnabled: _isPanEnabled,
                                scaleEnabled: _isScaleEnabled,
                                transformationController:
                                    _transformationController,
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
                                maxY: 100,
                                spots: tpsSpots,
                                yLabel: 'TPS',
                                showBottomTitle: false,
                                color: Colors.white,
                                dashLineColour: Colors.white,
                                panEnabled: _isPanEnabled,
                                scaleEnabled: _isScaleEnabled,
                                transformationController:
                                    _transformationController,
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
                                minY: 30,
                                maxY: 110,
                                spots: engineTemperatureSpots,
                                yLabel: 'Engine Temp',
                                showBottomTitle: false,
                                color: Colors.red,
                                dashLineColour: Colors.amber,
                                panEnabled: _isPanEnabled,
                                scaleEnabled: _isScaleEnabled,
                                transformationController:
                                    _transformationController,
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
                ))));
  }

  //-------------------------------------------------------------------------------------------------
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
