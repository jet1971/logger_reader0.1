import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({
    super.key,
    required this.qsSettingsCharacteristic,
    required this.qsLiveDataCharacteristic,
  });

  final BluetoothCharacteristic qsSettingsCharacteristic;
  final BluetoothCharacteristic qsLiveDataCharacteristic;

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(13, 12, 10, 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: <Color>[
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 59, 82, 232),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Icon(
                      Icons.electric_bolt,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  Stack(
                    children: [
                      // Glow effect layers
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Text(
                          'QUICKSHIFT PRO',
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            color: Color.fromARGB(200, 59, 82, 232),
                          ),
                        ),
                      ),
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Text(
                          'QUICKSHIFT PRO',
                          style: GoogleFonts.orbitron(
                            fontSize: 18,
                            color: Color.fromARGB(255, 25, 213, 238),
                          ),
                        ),
                      ),
                      // Main text
                      Text(
                        'QUICKSHIFT PRO',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2.0),
                          color: const Color.fromARGB(255, 50, 241, 60),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Connected',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: const Color.fromARGB(189, 255, 255, 255),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(
                color: const Color.fromARGB(128, 68, 154, 246),
                height: 1,
              ),
              ///////////////////////////////////////////////////////////////////////////////////////////////////////
              SizedBox(height: 15),
              Text(
                'Control Panel v1',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 172, 170, 170),
                ),
              ),
              ////////////////////////////////////////////// Radial Gauge ////////////////////////////////////////////////////////
              SizedBox(height: 15),
              Stack(
                children: [
                  Positioned(
                    left: 37,
                    top: 39,
                    child: Text(
                      '30',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        color: Color.fromARGB(198, 254, 255, 255),
                      ),
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 2,
                        ),
                        //  color: const Color.fromARGB(255, 50, 241, 60),
                      ),
                    ),
                  ),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 49, 234, 240),
                        width: 3,
                      ),
                      //  color: const Color.fromARGB(255, 50, 241, 60),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    child: Container(
                      width: 17.0,
                      height: 17.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        //border: Border.all(color: Colors.amber, width: 2),
                        color: const Color.fromARGB(255, 49, 234, 240),

                        //  color: const Color.fromARGB(255, 50, 241, 60),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  border: Border.all(
                    width: .5,
                    color: Color.fromARGB(128, 68, 154, 246),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.fromARGB(255, 19, 26, 38),
                      Color.fromARGB(255, 25, 34, 49),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(width: 6),
                        Text(
                          'RPM MULTIPLIER',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color.fromARGB(231, 255, 255, 255),
                          ),
                        ),
                        Spacer(),
                        Text(
                          '10234',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Color.fromARGB(255, 49, 234, 240),
                          ),
                        ),
                        SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ),

              //////////////////////////////////////////////// Settings //////////////////////////////////////////////////////
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SettingsContainer(
                    title: "CUT DURATION",
                    icon: Icon(
                      Icons.av_timer_outlined,
                      color: Color.fromARGB(255, 49, 234, 240),
                      size: 17,
                    ),
                    value: 60,
                    unit: "ms",
                  ),

                  ///////////////////////////////////////// Push Pull Container ///////////////////////////////
                  SizedBox(width: 1),

                  Container(
                    width: 160,
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                        width: .5,
                        color: Color.fromARGB(128, 68, 154, 246),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color.fromARGB(255, 19, 26, 38),
                          Color.fromARGB(255, 25, 34, 49),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'DIRECTION',
                                  style: GoogleFonts.orbitron(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: const Color.fromARGB(
                                      231,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_back_sharp,
                                  color: Color.fromARGB(255, 49, 234, 240),
                                  size: 17,
                                ),
                                Icon(
                                  Icons.arrow_forward_sharp,
                                  color: Color.fromARGB(255, 49, 234, 240),
                                  size: 17,
                                ),
                              ],
                            ),
                            Text(
                              'PUSH',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Color.fromARGB(255, 49, 234, 240),
                              ),
                            ),
                            Text(
                              'PULL',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                color: Color.fromARGB(189, 255, 255, 255),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              ////////////////////////////////// Rest of the settings containers ///////////////////////////////////////////////////
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SettingsContainer(
                    title: "MIN CUT RPM",
                    icon: Icon(
                      Icons.speed,
                      color: Color.fromARGB(255, 49, 234, 240),
                      size: 17,
                    ),
                    value: 4000,
                    unit: "RPM",
                  ),
                  SizedBox(width: 1),
                  SettingsContainer(
                    title: "SHIFT AGAIN",
                    icon: Icon(
                      Icons.av_timer_outlined,
                      color: Color.fromARGB(255, 49, 234, 240),
                      size: 17,
                    ),
                    value: 250,
                    unit: "ms",
                  ),
                ],
              ),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SettingsContainer(
                    title: "SHIFTLIGHT ON",
                    icon: Icon(
                      Icons.speed,
                      color: Color.fromARGB(255, 49, 234, 240),
                      size: 17,
                    ),
                    value: 13300,
                    unit: "rpm",
                  ),
                  SizedBox(width: 1),
                  SettingsContainer(
                    title: "SET PIN",
                    icon: Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 49, 234, 240),
                      size: 17,
                    ),
                    value: 1234,
                    unit: "",
                  ),
                ],
              ),

              ///////////////////////////////////////////////////////////////////////////////////////
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // width: 260,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    border: Border.all(
                      width: .5,
                      color: Color.fromARGB(128, 68, 154, 246),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment(.5, 0.01),
                      colors: <Color>[
                        Color.fromARGB(255, 19, 26, 38),
                        Color.fromARGB(255, 25, 34, 49),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.check_sharp,
                        color: Color.fromARGB(255, 49, 234, 240),
                        size: 27,
                        fontWeight: FontWeight.bold,
                      ),
                      Text(
                        'APPLY SETTNGS',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          //  color: Color.fromARGB(255, 49, 234, 240),
                          color: Color.fromARGB(255, 49, 234, 240),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String title;
  final int value;
  final String unit;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(width: .5, color: Color.fromARGB(128, 68, 154, 246)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.fromARGB(255, 19, 26, 38),
            Color.fromARGB(255, 25, 34, 49),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: const Color.fromARGB(231, 255, 255, 255),
                    ),
                  ),
                  Spacer(),
                  icon,
                ],
              ),
              Text(
                value.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  color: Color.fromARGB(255, 49, 234, 240),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: Color.fromARGB(231, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
