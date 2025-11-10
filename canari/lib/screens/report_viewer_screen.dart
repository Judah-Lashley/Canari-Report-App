import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({super.key});

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<dynamic> reports = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final response = await _client
          .from('reports')
          .select()
          .order('report_date', ascending: false);

      setState(() {
        reports = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '❌ Failed to load reports: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submitted Reports')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(report['incident_type'] ?? 'Unknown'),
                    subtitle: Text(report['description'] ?? ''),
                    trailing: Text(report['severity'] ?? 'N/A'),
                  ),
                );
              },
            ),
    );
  }
}
