class ServerFileDetails {
  ServerFileDetails({
    required this.venue,
    required this.day,
    required this.month,
    required this.year,
    required this.time,
    required this.fastestLap,
    required this.fileSize,
    required this.fileName,
  });

  final String venue;
  final String day;
  final String month;
  final String year;
  final String time;
  final String fastestLap;
  final String fileSize;
  final String fileName;

  // Create a factory method to construct ServerFileDetails from JSON
  factory ServerFileDetails.fromJson(Map<String, dynamic> json) {
    return ServerFileDetails(
      venue: json['venue'] ?? 'Unknown',
      day: json['day'] ?? '00',
      month: json['month'] ?? '00',
      year: json['year'] ?? '0000',
      time: json['time'] ?? '00:00',
      fastestLap: json['fastestLap'] ?? '00:00.00', // Dummy
      fileSize: json['fileSize']?.toString() ?? '0',
      fileName: json['fileName'] ?? 'Unknown',
    );
  }
}
