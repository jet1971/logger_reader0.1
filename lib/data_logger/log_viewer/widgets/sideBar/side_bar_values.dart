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

    final targetTimestamp =
        ref.watch(currentTimeStampProvider); // Current index

    num? findClosestEntry({
      required int? targetTimestamp,
      required List<Map<String, dynamic>> data,
      required String timestampKey,
      required String valueKey,
    }) {
      if (targetTimestamp == null) return null;
      if (data.isEmpty) return null;

      final validData = data.where((entry) {
        return entry[timestampKey] != null && entry[valueKey] != null;
      }).toList();
      if (validData.isEmpty) return null;

      final closestData = validData.reduce((closest, current) {
        final closestTs = closest[timestampKey] as int;
        final currentTs = current[timestampKey] as int;
        return (currentTs - targetTimestamp).abs() <
                (closestTs - targetTimestamp).abs()
            ? current
            : closest;
      });

      // Now it could be a double or int in the map
      final rawValue = closestData[valueKey];
      // If you truly want to unify it, you'd store them all as double or int, but at least
      // num? can hold either
      return rawValue as num?;
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
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'speed',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'Throttle (%)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'tps',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'RPM:',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
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
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'coolantTemperature',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'Airbox Temp (C)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'airTemperature',
              ).toString(),
              valuesTextColor: valueTextColor),
                  const SizedBox(height: 20),
          ValuesText(
              title: 'Airbox Pressure (PSI)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'airboxPressure',
              ).toString(),
              valuesTextColor: valueTextColor),
                  const SizedBox(height: 20),
          ValuesText(
              title: 'Oil Pressure (PSI)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'oilPressure',
              ).toString(),
              valuesTextColor: valueTextColor),
          const SizedBox(height: 20),
          ValuesText(
              title: 'AFR ( :1 )',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'afr',
              ).toString(),
              valuesTextColor: valueTextColor),
      
          const SizedBox(height: 20),
          ValuesText(
              title: 'Battery (Volts)',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                 valueKey: 'batteryVoltage',              
              ).toString(),
              valuesTextColor: valueTextColor),
                       const SizedBox(height: 20),
          ValuesText(
              title: 'Spare',
              value: findClosestEntry(
                targetTimestamp: targetTimestamp,
                data: ref.watch(dataLogProvider.notifier).allData,
                timestampKey: 'timestamp',
                valueKey: 'spare',
              ).toString(),
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
