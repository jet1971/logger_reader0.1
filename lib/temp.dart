import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temp Page'),
      ),
      body: const SliderExample(),
    );
  }
}

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  SliderExampleState createState() => SliderExampleState();
}

class SliderExampleState extends State<SliderExample> {
  double desiredValue = 50.0; // Initial desired value
  double actualValue = 25.0; // Initial actual value (can be dynamic)

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            // 'Desired Value: ${desiredValue.toStringAsFixed(1)}',
            'Set Value: ${desiredValue.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            'Actual Value: ${actualValue.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              width: 400, // sets the overall size of the slider
              height: 30,// sets the overall size of the slider
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration:  BoxDecoration(color: Colors.white,
                   
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(7)
                     ),// the background
                     
                    height: 15,
                    width: 339,
                    
                  ),
                  SliderTheme(
                    // ---------------------------------------------------------- this the actual value received
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                        pressedElevation: 0,
                      ),
                      thumbColor: Colors.blue,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 32.0),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: 100.0,
                      value: actualValue,
                      onChanged: (value) {
                        setState(() {
                          actualValue = value;
                        });
                      },
                    ),
                  ),
                  // ------------------------------------------------------------------------------------------------
                  SliderTheme(
                    // the set value

                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: const Color.fromRGBO(0, 0, 0, 0),
                      inactiveTrackColor: const Color.fromRGBO(0, 0, 0, 0),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                        pressedElevation: 0,
                      ),
                      thumbColor: Colors.blue,
                      overlayColor: const Color.fromARGB(99, 247, 236, 236),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 32.0),
                    ),
                    child: Slider(
                      value: desiredValue,
                      min: 0,
                      max: 100,
                      label: desiredValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          desiredValue = value;
                        });
                      },
                    ),
                  ),

                  // Display desired value on top
                  // Positioned(
                  //   top: 125,
                  //   child: Text(
                  //     // 'Desired Value: ${desiredValue.toStringAsFixed(1)}',
                  //     'Desired Value: ${desiredValue.toStringAsFixed(1)}',
                  //     style: const TextStyle(fontSize: 16, color: Colors.white),
                  //   ),
                  // ),
                  // Positioned(
                  //   top: 50,
                  //   child: Text(
                  //     'Actual Value: ${actualValue.toStringAsFixed(1)}',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
