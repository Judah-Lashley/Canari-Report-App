import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadImage(File imageFile) async {
    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _client.storage.from('report-images').upload(fileName, imageFile);
      final publicUrl = _client.storage
          .from('report-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('❌ Image upload failed: $e');
      return null;
    }
  }

  Future<void> submitReport({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    required String severity,
    String? placeName,
    String? mediaUrl,
    DateTime? reportDate,
  }) async {
    try {
      await _client.from('reports').insert({
        'incident_type': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'severity': severity,
        'place_name': placeName,
        'media_url': mediaUrl,
        'report_date':
            reportDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
      print('✅ Report submitted to Supabase');
    } catch (e) {
      print('🔥 Report submission failed: $e');
    }
  }
}
