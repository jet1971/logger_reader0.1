// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:ble1/data_logger/log_viewer/widgets/gps_plot/logger_first_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/chosen_data_provider.dart';

class GPSMapPainter extends CustomPainter {
  GPSMapPainter(this.points, this.gpsPoints, this.ref);

  final List<Offset> points;
  final List<Map<String, dynamic>> gpsPoints;
  final WidgetRef ref;

  double lowThreshold = 0;
  double mediumThreshold = 50;
  double highThreshold = 100;

  @override
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (points.isEmpty) return;

    final chosenDataCategory = ref.watch(chosenDataProvider);

    switch (chosenDataCategory) {
      case 'speed':
        mediumThreshold = 70;
        highThreshold = 140;
      case 'tps':
        mediumThreshold = 50;
        highThreshold = 95;
      case 'coolantTemperature':
        mediumThreshold = 50;
        highThreshold = 90;
      default:
        mediumThreshold = 150;
        highThreshold = 150;
    }

    final paintLow = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintMedium = Paint()
      ..color = const Color.fromARGB(255, 242, 154, 47)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintHigh = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);

      if (gpsPoints[i][chosenDataCategory] >= highThreshold) {
        canvas.drawPath(path, paintHigh);
      } else if (gpsPoints[i][chosenDataCategory] >= mediumThreshold) {
        canvas.drawPath(path, paintMedium);
      } else {
        canvas.drawPath(path, paintLow);
      }

      path.reset();
      path.moveTo(points[i].dx, points[i].dy);
    }

    // for (var point in points) {
    //   canvas.drawCircle(point, 2, Paint()..color = Colors.black);
    //   print(point);
    // }

    canvas.drawCircle(
        points[markerIndex],
        8,
        Paint()
          ..color = const Color.fromARGB(
              255, 244, 11, 11)); // adds the red marker to plot
  }
  // }

  //   for (var i = 0; i < points.length; i++) {
  //     canvas.drawCircle(points[i], 3, Paint()..color = Colors.black);
  //   }
  // }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
