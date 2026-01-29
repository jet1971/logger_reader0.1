/// Models for Venue and VenueListInfo
class VenueListInfo {
  final int version;
  final List<Venue> venues;

  VenueListInfo({required this.version, required this.venues});

  factory VenueListInfo.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] is int)
        ? json['version'] as int
        : int.parse(json['version'].toString());

    final venueListRaw = json['venues'] as List<dynamic>;
    final venues = venueListRaw.map((v) => Venue.fromJson(v)).toList();

    return VenueListInfo(version: version, venues: venues);
  }
}

class Venue {
  final String name;
  final double lat1;
  final double lon1;
  final double lat2;
  final double lon2;
  final double radius;
  final String code;

  Venue({
    required this.name,
    required this.lat1,
    required this.lon1,
    required this.lat2,
    required this.lon2,
    required this.radius,
    required this.code,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'],
      lat1: json['lat1'],
      lon1: json['lon1'],
      lat2: json['lat2'],
      lon2: json['lon2'],
      radius: (json['radius'] as num).toDouble(),
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat1': lat1,
      'lng1': lon1, // ESP32 uses "lng1"
      'lat2': lat2,
      'lng2': lon2,
      'radius': radius,
      'code': code,
    };
  }
}
