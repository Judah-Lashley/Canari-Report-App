import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDebugScreen extends StatelessWidget {
  const MapDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Debug')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(10.654, -61.502),
          zoom: 12,
        ),
      ),
    );
  }
}
