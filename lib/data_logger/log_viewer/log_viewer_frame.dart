import 'package:ble1/data_logger/log_viewer/engine_data_graph.dart';
import 'package:ble1/data_logger/log_viewer/example_graph.dart';
import 'package:ble1/data_logger/log_viewer/widgets/gps_plot/logger_first_screen.dart';
import 'package:ble1/data_logger/log_viewer/sync_line_chart.dart';
import 'package:ble1/data_logger/log_viewer/widgets/debug.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/another_example.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/side_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ble1/util/responsive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/chosen_content_provider.dart';

class LogViewerFrame extends ConsumerWidget {
  const LogViewerFrame({
    super.key,
    required this.fileName,
  });
  final String fileName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Responsive.isDesktop(context);
    final chosenContent = ref.watch(chosenContentProvider);

    Widget mainContent;
    if (chosenContent == 'track_report') {
      mainContent = const LoggerFirstScreen();
    } else if (chosenContent == 'engine_data') {
      mainContent = const EngineDataGraph();
    } else if (chosenContent == 'suspension_data') {
      mainContent =  const DebugWidget();
    } else if (chosenContent == 'section_times') {
      mainContent =  const SyncedLineChart();
    } 
    else {
      mainContent = const LoggerFirstScreen();
    }

    return Scaffold(
      // drawer: !isDesktop
      //     ? const SizedBox(
      //         width: 250,
      //         child: SideMenuWidget(),
      //       )
      //     : null,
      // endDrawer: Responsive.isMobile(context)
      //     ? SizedBox(
      //         width: MediaQuery.of(context).size.width * 0.8,
      //         child: const SummaryWidget(),
      //       )
      //     : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: SideBar(                      // SideMenuWidget(),
                    fileName: fileName,
                  ),
                ),
              ),
            Expanded(
              flex: 8,
              child: mainContent,                       //  mainContent,

              // LoggerFirstScreen(fileName: fileName,),

              //  child: EngineDataGraph(),
              //   child: LineChartSample4(),

              // if (isDesktop)
              // const  Expanded(
              //     flex: 3,
              //    //  child: SummaryWidget(),
              //     child: Text('SUMMARY WIDGET'),
              //   ),
            ),
          ],
        ),
      ),
    );
  }
}
