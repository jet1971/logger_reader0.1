import 'package:ble1/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/current_timestamp_provider.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';

class ValuesText extends StatelessWidget {
  const ValuesText(
      {super.key,
      required this.title,
      required this.value,
      required this.valuesTextColor});

  final String title;
  final String value;
  final Color valuesTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: valuesTextColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valuesTextColor,
          ),
        ),
      ],
    );
  }
}

class SideBarValues extends ConsumerStatefulWidget {
  const SideBarValues({super.key});

  @override
  ConsumerState<SideBarValues> createState() => _SideBarValuesState();
}

class _SideBarValuesState extends ConsumerState<SideBarValues> {
  @override
  Widget build(BuildContext context) {
//-----------------------------------------------------------------------------------------------------
    double value = 0;
    final targetTimestamp =
        ref.watch(currentTimeStampProvider); // Current index
    // final speed = ref.watch(dataLogProvider.notifier).gpsData[1000]['speed'];
    //final speed = 22;
    // final engTempData = ref.watch(dataLogProvider.notifier).temperatureData; // The list of maps
    // final rpmData =
    //     ref.watch(dataLogProvider.notifier).rpmData; // The list of maps

    double? findClosestEntry({
      required int? targetTimestamp,
      required List<Map<String, dynamic>> data,
      required String timestampKey,
      required String valueKey,
    }) {
      if (targetTimestamp == null) {
        print('The Current Timestamp is null');
        return null; // Indicate that no valid data was found
      }

      if (data.isEmpty) {
        print('speed is empty');
        return null;
      }

      // Filter out invalid entries
      final validData = data.where((entry) {
        return entry[timestampKey] != null && entry[valueKey] != null;
      }).toList();

      if (validData.isEmpty) {
        print('No valid data available');
        return null;
      }

      // Find the closest entry
      final closestData = validData.reduce((closest, current) {
        final closestTimestamp = closest[timestampKey] as int;
        final currentTimestamp = current[timestampKey] as int;

        return (currentTimestamp - targetTimestamp).abs() <
                (closestTimestamp - targetTimestamp).abs()
            ? current
            : closest;
      });
      value = closestData[valueKey] as double;
      return value; // Return the closest data
    }
//-----------------------------------------------------------------------------------------------------

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

//-----------------------------------------------------------------------------------------------------
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF21222D),
      ),
      child: Column(
        children: [
          ValuesText(
              title: 'Speed: (mph)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).gpsData,
                timestampKey: 'timestamp',
                valueKey: 'speed',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'RPM:',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).rpmData,
                timestampKey: 'timestamp',
                valueKey: 'rpm',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'Eng Temp (C)',
              //value: engTemp.toString(),
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).temperatureData,
                timestampKey: 'timestamp',
                valueKey: 'temperature',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          const ValuesText(
              title: 'Airbox Temp (C)',
              value: '14',
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          const ValuesText(
              title: 'AFR ( :1 )',
              value: '12.77',
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          const ValuesText(
              title: 'Oil Pressure (PSI)',
              value: '63',
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'Elapsed Time',
              value: formatMilliseconds(targetTimestamp ??
                  0), // added ?? 0 after restart for some reason,
              valuesTextColor: valueTextColor),
        ],
      ),
    );
  }
}
