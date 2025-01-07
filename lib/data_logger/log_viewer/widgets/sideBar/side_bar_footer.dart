// import 'package:flutter/material.dart';

// class SideBarFooter extends StatelessWidget {
//   const SideBarFooter({super.key, required this.fileName});
//   final String fileName;

//   @override
//   Widget build(BuildContext context) {
//     // Find positions based on expected format
//     int colonPos =
//         fileName.indexOf(':'); // Locate the time part by finding the colon

//     String venue = fileName.substring(
//         colonPos - 12,
//         colonPos -
//             10); // Extract venue initials, eg (cp = Cadwell Park), (na = not available)
//     String year =
//         fileName.substring(colonPos - 6, colonPos - 2); // Extract year (2024)
//     String month =
//         fileName.substring(colonPos - 8, colonPos - 6); // Extract month (10)
//     String day = fileName.substring(colonPos - 10, colonPos - 8); // Extract day
//     String time = fileName.substring(colonPos - 2, colonPos + 3);
//     String fastestLap = "00:00.00";

//     if (venue == 'ho') {
//       venue = 'Home';
//     } else if (venue == 'wo') {
//       venue = 'Work';
//     } else if (venue == 'na') {
//       venue = 'Venue N/A';
//     }
//     return Container(
//       width: 220,
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: const Color(0xFF171821),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             venue,
//             style: const TextStyle(color: Colors.white, fontSize: 13),
//           ),
//                const SizedBox(height: 5,),  
//           Text(
//            '$day/$month/$year',
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Text(
//              time,
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }
