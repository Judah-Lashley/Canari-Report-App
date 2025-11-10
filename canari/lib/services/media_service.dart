import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'report_$timestamp.jpg';

      // Upload to Supabase Storage bucket named 'report-images'
      await _client.storage.from('report-images').upload(fileName, imageFile);

      // Get public URL
      final publicUrl = _client.storage
          .from('report-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('❌ Supabase image upload failed: $e');
      return null;
    }
  }
}
