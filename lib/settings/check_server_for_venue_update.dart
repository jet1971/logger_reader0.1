
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ble1/data_logger/models/venue.dart';

Future<VenueListInfo> fetchLatestVenueListInfo() async {
  final url = 'http://jtmc.co.uk/data_logger/venues.txt';
  final resp = await http.get(Uri.parse(url));

  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch venues: ${resp.statusCode}');
  }

  final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;

  // returns both version and venues
  return VenueListInfo.fromJson(jsonMap);
}
