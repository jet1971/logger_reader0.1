// ignore_for_file: avoid_print

import 'package:ble1/data_logger/log_viewer/widgets/gps_plot/logger_first_screen.dart';
import 'package:flutter/material.dart';

class GPSMapPainter extends CustomPainter {
  GPSMapPainter(this.points, this.gpsPoints);

  final List<Offset> points;
  //final List<GPSPoint> gpsPoints;
  final List<Map<String, dynamic>> gpsPoints;
  final double highSpeedThreshold = 41.0;
  final double mediumSpeedThreshold = 25.0;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (points.isEmpty) return;

    final paintLowSpeed = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintMediumSpeed = Paint()
      ..color = const Color.fromARGB(255, 242, 154, 47)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintHighSpeed = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);

      if (gpsPoints[i]['speed'] > highSpeedThreshold) {
        canvas.drawPath(path, paintHighSpeed);
      } else if (gpsPoints[i]['speed'] > mediumSpeedThreshold) {
        canvas.drawPath(path, paintMediumSpeed);
      } else {
        canvas.drawPath(path, paintLowSpeed);
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
