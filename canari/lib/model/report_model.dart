class Report {
  final String id;
  final String incidentType;
  final String description;
  final DateTime reportDate;
  final double latitude;
  final double longitude;
  final String severity;
  final String? placeName;
  final String? mediaUrl;

  Report({
    required this.id,
    required this.incidentType,
    required this.description,
    required this.reportDate,
    required this.latitude,
    required this.longitude,
    required this.severity,
    this.placeName,
    this.mediaUrl,
  });

  // Factory constructor to create a Report from Supabase row
  factory Report.fromMap(Map<String, dynamic> data) {
    return Report(
      id: data['id'] ?? '',
      incidentType: data['incident_type'] ?? '',
      description: data['description'] ?? '',
      reportDate: DateTime.parse(data['report_date']),
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      severity: data['severity'] ?? 'pending',
      placeName: data['place_name'],
      mediaUrl: data['media_url'],
    );
  }

  // Convert Report to Supabase-compatible map
  Map<String, dynamic> toMap() {
    return {
      'incident_type': incidentType,
      'description': description,
      'report_date': reportDate.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'place_name': placeName,
      'media_url': mediaUrl,
    };
  }
}
