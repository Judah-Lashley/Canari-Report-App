import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/report_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yshddxrtqrewnjmesogr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzaGRkeHJ0cXJld25qbWVzb2dyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MDEzNzcsImV4cCI6MjA3ODI3NzM3N30.LPIV4P5OA08RRRaWDVf8V4i0hx6wgyMt2EGkUNP4kOY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citizen Report',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
      routes: {
        '/report': (context) => const ReportFormScreen(),
        '/maptest': (context) => const MapTestScreen(),
      },
    );
  }
}

// --- Minimal Google Map Test Screen ---
class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(10.654, -61.502); // Trinidad center

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Test'),
        backgroundColor: Colors.green[700],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 10.0),
      ),
    );
  }
}
