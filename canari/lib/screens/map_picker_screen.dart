import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'report_form_screen.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();

  final LatLng _initialPosition = const LatLng(10.6918, -61.2225); // Trinidad
  Set<Marker> _markers = {};

  String? selectedPlaceName;
  double? selectedLat;
  double? selectedLng;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _moveToLocation(double lat, double lng, String description) {
    final newPosition = LatLng(lat, lng);
    mapController.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('searched_location'),
          position: newPosition,
          infoWindow: InfoWindow(title: description),
        ),
      };
      selectedLat = lat;
      selectedLng = lng;
      selectedPlaceName = description;
    });
  }

  void _goToReportForm() {
    if (selectedLat != null &&
        selectedLng != null &&
        selectedPlaceName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportFormScreen(
            placeName: selectedPlaceName!,
            latitude: selectedLat!,
            longitude: selectedLng!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location first")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select a Location'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 10,
              ),
              markers: _markers,
              onTap: (LatLng tappedPoint) {
                setState(() {
                  _markers = {
                    Marker(
                      markerId: const MarkerId('tapped_location'),
                      position: tappedPoint,
                      infoWindow: const InfoWindow(title: "Custom Location"),
                    ),
                  };
                  selectedLat = tappedPoint.latitude;
                  selectedLng = tappedPoint.longitude;
                  selectedPlaceName = "Custom Location";
                });

                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(tappedPoint, 15),
                );
              },
            ),
          ),

          // 🔍 Search Bar
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: "YOUR_API_KEY_HERE", // 🔑 Replace with your key
                inputDecoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search for a location...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                debounceTime: 800,
                isLatLngRequired: true,
                countries: ["tt"],
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  final lat = double.parse(prediction.lat!);
                  final lng = double.parse(prediction.lng!);
                  _moveToLocation(lat, lng, prediction.description ?? '');
                },
                itemClick: (Prediction prediction) {
                  _searchController.text = prediction.description!;
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),

          // 🧭 Confirm Button
          Positioned(
            bottom: 20,
            left: 40,
            right: 40,
            child: ElevatedButton.icon(
              onPressed: _goToReportForm,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Continue to Report Form"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
