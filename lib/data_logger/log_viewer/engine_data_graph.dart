import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';

List<FlSpot> _convertToSpots(List<Map<String, dynamic>> dataLog,
    String dataName, String timestamp, double threshold) {
  List<FlSpot> points = [];
  String lastParsed = ''; // Store the last parsed values to prevent duplicates
  double lastValidPoint = 0; // To hold the last valid point(rpm value)

  // Iterate through the list and try to convert every three values into a GPSPoint
  for (int i = 0; i < dataLog.length; i++) {
    // Ensure there are enough values to create a GPSPoint
    // if (i + 2 < dataLog.length) {
    String currentParsed =
        "${(dataLog[i][dataName])},${(dataLog[i][timestamp])},";
    // print('current parsed $currentParsed');
    print(dataLog[i][dataName]);

    // Check if any of the values are empty or invalid
    if (dataLog[i][dataName] == null || dataLog[i][timestamp] == null) {
      print("Skipping invalid data at index $i:}");
      continue; // Skip to the next iteration
    }

    //   // Check if this set of values is the same as the last one
    if (currentParsed != lastParsed) {
      try {
        // print("Parsing values: $currentParsed");

        double data = (dataLog[i][dataName]);
        int elapsedTime = (dataLog[i][timestamp]);

        //   Plausabilty check, if the data is masively different to last data it can't be valid
        //  Check if we have a last valid point to compare with

        double difference = (data - lastValidPoint).abs();

        // Set your threshold value
        // double threshold =
        //     17000; // make adjustable in the page settings one day?

        // If the differences exceed the threshold, skip this point
        if (difference > threshold) {
          print("Skipping point due to threshold exceedance: $difference");
          continue;
        }

        // If the point is valid and passes the threshold check, add it
        points.add(FlSpot(elapsedTime.toDouble(), data));
        lastValidPoint = data; // Update the last valid point
        //    print('lastvalidPoint $lastValidPoint');
        lastParsed = currentParsed; // Update the last parsed values
      } catch (e) {
        print(
            "Error parsing data at index $i :  ${(dataLog[i]['lat'])},${(dataLog[i]['lng'])},${(dataLog[i]['speed'])},${(dataLog[i]['timestamp'])} ");
      }
    } else {
//      print("Skipping duplicate data: $currentParsed");
    }
  }
  return points;
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  String text;
  switch (value.toInt()) {
    case 80000:
      text = 'Jan';
      break;
    case 100000:
      text = 'Feb';
      break;
    default:
      return Container();
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 4,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
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

class EngineDataGraph extends ConsumerWidget {
  const EngineDataGraph({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsData = ref.watch(dataLogProvider.notifier).gpsData;
    final rpmData = ref.watch(dataLogProvider.notifier).rpmData;

    final parsedFilename = ref.watch(
        filenameProvider); // This will give the formatted filename or null

    List<FlSpot> rpmSpots = _convertToSpots(rpmData, 'rpm', 'timestamp',
        17000); //the data, the data key, timestamp key, plausability tolerence value
 //   List<FlSpot> gpsSpots = _convertToSpots(gpsData, 'speed', 'timestamp', 1000);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 2, 10, 0),
                      child: LineChart(
                        LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots:
                                    rpmSpots, // the data......................................
                                belowBarData: BarAreaData(show: false),
                                color: Colors.blue,
                                barWidth: 1,
                                dotData: FlDotData(
                                  show: false,
                                  checkToShowDot: (spot, barData) {
                                    return spot.x == 1;
                                  },
                                ),
                              ),
                            ],
                                  lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideVertically: true,
                                getTooltipColor: (LineBarSpot touchedBarSpot) {
                                  return Colors.blueAccent;
                                },
                                getTooltipItems:
                                    (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots
                                      .map((LineBarSpot touchedSpot) {
                                    return LineTooltipItem(
                                      'RPM: ${touchedSpot.y.toString()}',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                // Update cursor position based on the touch event
                              },
                            ),
                            // minY: 0,
                            // maxY: 50,

                            titlesData: const FlTitlesData(
                              //-------------------------------------------------------------------------------------
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              //-------------------------------------------------------------------------------------
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              //-------------------------------------------------------------------------------------
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'RPM',
                                  style: TextStyle(color: Colors.white),
                                ),
                                axisNameSize: 50,
                                drawBelowEverything: false,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 25,
                                  maxIncluded: true,
                                  //space around the scale text?
                                  //  getTitlesWidget: bottomTitleWidgets,
                                ),
                              ),
                              //-------------------------------------------------------------------------------------
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles:
                                        false), //space around the scale text
                              ),
                              //-------------------------------------------------------------------------------------
                            ),
                            borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(width: 1, color: const Color.fromARGB(90, 0, 0, 0)))),
                      ),
                    ),
                  ),
                ),
                //----------------------------------------------------------------------------------------------------------
const SizedBox(height: 10,),
                Center(
                  child: AspectRatio(
                    aspectRatio: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 10, 2),
                      child: LineChart(
                        LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                            //    spots: gpsSpots,
                                color: Colors.green,
                                barWidth: 1,
                                dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (spot, barData) {
                                    return spot.x == 1; //???
                                  },
                                ),
                              ),
                            ],
                            // minY: 11,
                            // maxY: 15,
                            // extraLinesData: ExtraLinesData(
                            //   extraLinesOnTop: false,
                            //   horizontalLines: [
                            //     HorizontalLine(y: 14, color: Colors.red),
                            //     HorizontalLine(y: 12, color: Colors.blue),
                            //   ],
                            // ),
                                                            lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideVertically: true,
                                getTooltipColor: (LineBarSpot touchedBarSpot) {
                                  return Colors.blueAccent;
                                },
                                getTooltipItems:
                                    (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots
                                      .map((LineBarSpot touchedSpot) {
                                    return LineTooltipItem(
                                      'Speed: ${touchedSpot.y.toString()} MPH',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                // Update cursor position based on the touch event
                              },
                            ),
                            titlesData: const FlTitlesData(
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    'Speed MPH',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  axisNameSize: 50,
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize:
                                          25), //space around the scale text
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    'Elasped Time',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  axisNameSize: 20,
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize:
                                          30), //space around the scale text
                                )),
                            borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(width: 1, color: const Color.fromARGB(90, 0, 0, 0)))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              parsedFilename!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}