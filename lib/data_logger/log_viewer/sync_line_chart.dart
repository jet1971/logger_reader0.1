import 'package:ble1/data_logger/provider/max_value_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/current_timestamp_provider.dart';
import 'package:ble1/data_logger/provider/index_provider.dart';

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

double roundUpToNext10(double number) {
  // used for mph axis, rounds scale up to next 10, eg if value 61.5 axis will be 70
  return (number / 10).ceil() * 10;
}

double roundUpToNext1000(num number) {
  // used for rpm axis, rounds scale up to next 1000
 // return (number).ceil() * 1000;
  return (number / 1000).ceil() * 1000;
}

class SyncedLineChart extends ConsumerStatefulWidget {
  const SyncedLineChart({super.key});

  @override
  ConsumerState createState() => SyncedLineChartState();
}

class SyncedLineChartState extends ConsumerState<SyncedLineChart> {
  int touchIndex =
      0; // Shared cursor position (used by both charts, and track plot)

  @override
  Widget build(BuildContext context) {
   // final data = ref.watch(dataLogProvider.notifier).allData;
    final maxValues = ref.watch(maxValueProvider);
    print(maxValues.maxSpeed);
    print(maxValues.maxRpm);

        final fastestLap = ref.watch(dataLogProvider.notifier).getFastestLap();
    // final fastestLapData = ref.watch(dataLogProvider.notifier).getLap(fastestLap);
   // final data = ref.watch(dataLogProvider.notifier).getLap(2);

      // Watch selected lap number (triggers rebuilds)
    final selectedLap = ref.watch(selectedLapProvider);

// Watch raw data log state to trigger updates on data changes
 //   final rawData = ref.watch(dataLogProvider);

// Call method to extract the selected lap (does NOT trigger rebuilds on its own)
    final lapData = ref.read(dataLogProvider.notifier).getLap(selectedLap);


    // Convert data to FlSpots

    List<FlSpot> rpmSpots = _convertToSpotsWithFilter(
        lapData,
        'rpm',
        'timestamp',
       40500); //dataName, timestamp, threshold, if for example the rpm is 1000 and the next is 10000, it will be skipped

    List<FlSpot> gpsSpots = _convertToSpotsWithFilter(
        lapData,
        'speed',
        'timestamp',
        20); //dataName, timestamp, threshold, if for example the speed is 10 and the next is 100, it will be skipped
    //  print('rpmSpots $rpmSpots');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // First LineChart (RPM Data)
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    showingIndicators: <int>[touchIndex],
                    spots: rpmSpots, // Using rpmSpots
                    //   spots: testSpots,
                    belowBarData: BarAreaData(show: false),
                    color: Colors.blue,
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                 minY: 0,
           //     maxY: roundUpToNext1000(maxValues.maxRpm), // function to round up the axis to the next 10
                maxY: 10000,

                lineTouchData: LineTouchData(
                  // touchSpotThreshold: 1,
                  handleBuiltInTouches: false,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideVertically: true,
                    getTooltipColor: (LineBarSpot touchedBarSpot) {
                      return Colors.blueAccent;
                    },
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          'RPM: ${touchedSpot.x.toString()}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),

                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    setState(() {
                      if (touchResponse != null &&
                          touchResponse.lineBarSpots != null) {
                        // Update the touchIndex based on the closest x value in the data
                        int touchResponseTimestamp =
                            touchResponse.lineBarSpots![0].x.toInt();

                        ref
                            .read(currentTimeStampProvider.notifier)
                            .setScreenPositionTimeStamp(
                                touchResponseTimestamp); // get the timstamp of the current screen position and set in the provider
                        // logger first screen wants a index not a timestamp...
                        touchIndex = _findClosestSpotIndex(
                            rpmSpots, touchResponse.lineBarSpots![0].x);

                        ref.read(indexProvider.notifier).setIndex(touchIndex);

                        //    print('Top touch: ${touchResponse.lineBarSpots![0].x}');
                        //     print('Top $touchIndex');
                      }
                    });
                  },
                ),
                titlesData: const FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
//----------------------------------------------------------------------------------------------------------------
                  leftTitles: AxisTitles(
                    axisNameWidget:
                        Text('RPM', style: TextStyle(color: Colors.white)),
                    sideTitles: SideTitles(
                      showTitles: true,
                      // interval: 1000,
                      reservedSize: 50,
                      getTitlesWidget: mphTitlesWidget,
                    ),
                  ),

//----------------------------------------------------------------------------------------------------------------
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData:
                    FlBorderData(show: true, border: Border.all(width: 0.2)),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          // Second LineChart (Speed Data)-------------------------------------------------------------------------------
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    showingIndicators: <int>[touchIndex],
                    spots: gpsSpots, // Using gpsSpots
                    belowBarData: BarAreaData(show: false),
                    color: Colors.red,
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                maxY: roundUpToNext10(maxValues
                    .maxSpeed), // function to round up the axis to the next 10
                lineTouchData: LineTouchData(
                  //    touchSpotThreshold: 1,
                  handleBuiltInTouches: false,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot touchedBarSpot) {
                      return Colors.redAccent;
                    },
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          'Speed: ${touchedSpot.x.toString()} MPH',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    setState(() {
                      if (touchResponse != null &&
                          touchResponse.lineBarSpots != null) {
                        // Update the touchIndex based on the closest x value in the data
                        int touchResponseTimestamp =
                            touchResponse.lineBarSpots![0].x.toInt();
                        ref
                            .read(currentTimeStampProvider.notifier)
                            .setScreenPositionTimeStamp(
                                touchResponseTimestamp); // get the timstamp of the current screen position and set in the provider
                        // logger first screen wants a index not a timestamp...

                        touchIndex = _findClosestSpotIndex(
                            gpsSpots, touchResponse.lineBarSpots![0].x);

                        ref.read(indexProvider.notifier).setIndex(touchIndex);

                        // print('touch: ${touchResponse.lineBarSpots![0].x}');
                        //  print('bottom: $touchIndex');
                      }
                    });
                  },
                ),

//-------------------------------------------------------------------------------------------------
                titlesData: const FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
//-------------------------------------------------------------------------------------------------

                  leftTitles: AxisTitles(
                    axisNameWidget: Text('Speed MPH',
                        style: TextStyle(color: Colors.white)),
                    sideTitles: SideTitles(
                      interval: 10,
                      reservedSize: 50,
                      showTitles: true,
                      getTitlesWidget: mphTitlesWidget,
                    ),
                  ),

//-------------------------------------------------------------------------------------------------
                  bottomTitles: AxisTitles(
                    axisNameWidget:
                        Text('Time', style: TextStyle(color: Colors.white)),
                    sideTitles: SideTitles(
                      interval: 40000,
                      reservedSize: 30,
                      showTitles: true,
                      getTitlesWidget: elapsedTimeTitlesWidget,
                    ),
                  ),
                ),

//-------------------------------------------------------------------------------------------------
                borderData:
                    FlBorderData(show: true, border: Border.all(width: 0.2)),
//-------------------------------------------------------------------------------------------------
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
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
}

Widget mphTitlesWidget(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(' ${value.toInt()}', style: style),
  );
}

// Widget elapsedTimeTitlesWidget(double value, TitleMeta meta) {
//   const style = TextStyle(
//     color: Colors.white,
//     fontSize: 12,
//   );
//   return SideTitleWidget(
//     axisSide: meta.axisSide,
//     child: Text(' ${value.toInt()}', style: style),
//   );
// }

Widget elapsedTimeTitlesWidget(double value, TitleMeta meta) {
  String text = ' ${formatMilliseconds(value.toInt())}';
  // switch (value.toInt()/1000) {
  //   case 0:
  //     text = 'Jan';
  //     break;
  //   case 1000:
  //     text = 'Feb';
  //     break;
  //   case 2000:
  //     text = 'Mar';
  //     break;
  //   case 3000:
  //     text = 'Apr';
  //     break;
  //   case 4000:
  //     text = 'May';
  //     break;
  //   case 5000:
  //     text = 'Jun';
  //     break;
  //   case 6000:
  //     text = 'Jul';
  //     break;
  //   case 7000:
  //     text = 'Aug';
  //     break;
  //   case 18000:
  //     text = 'Sep';
  //     break;
  //   case 19000:
  //     text = 'Oct';
  //     break;
  //   case 110000:
  //     text = 'Nov';
  //     break;
  //   case 111000:
  //     text = 'Dec';
  //     break;
  //   default:
  //     return Container();
  // }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 12,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
