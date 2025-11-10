import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';

class ReportFormScreen extends StatefulWidget {
  final String? placeName;
  final double? latitude;
  final double? longitude;

  const ReportFormScreen({
    super.key,
    this.placeName,
    this.latitude,
    this.longitude,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService();

  String incidentType = 'Illegal dumping';
  String severity = 'moderate';
  String description = '';
  File? selectedImage;
  bool isSubmitting = false;
  DateTime? selectedDate;
  late LatLng reportLocation;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      reportLocation = LatLng(widget.latitude!, widget.longitude!);
    } else {
      LocationService.getCurrentLocation().then((position) {
        setState(() {
          reportLocation = position != null
              ? LatLng(position.latitude, position.longitude)
              : const LatLng(10.654, -61.502); // fallback: Trinidad
        });
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    try {
      String? imageUrl;
      if (selectedImage != null) {
        imageUrl = await _supabaseService.uploadImage(selectedImage!);
        if (imageUrl == null) {
          throw Exception("Image upload failed");
        }
      }

      await _supabaseService.submitReport(
        incidentType: incidentType,
        description: description,
        latitude: reportLocation.latitude,
        longitude: reportLocation.longitude,
        severity: severity,
        mediaUrl: imageUrl,
        placeName: widget.placeName,
        reportDate: selectedDate ?? DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Report submitted successfully!')),
      );

      setState(() {
        selectedImage = null;
        description = '';
        selectedDate = null;
        isSubmitting = false;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      setState(() => isSubmitting = false);
    }
  }

  Widget buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Location:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: reportLocation,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('reportLocation'),
                position: reportLocation,
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            },
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final position = await LocationService.getCurrentLocation();
            if (position != null) {
              setState(() {
                reportLocation = LatLng(position.latitude, position.longitude);
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(reportLocation),
                );
              });
            }
          },
          icon: const Icon(Icons.my_location),
          label: const Text('Use Current Location'),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Report'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildMapSection(),
              DropdownButtonFormField<String>(
                value: incidentType,
                items:
                    [
                          'Illegal dumping',
                          'Road hazard',
                          'Noise complaint',
                          'Water leak',
                          'Other',
                        ]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => incidentType = value!),
                decoration: const InputDecoration(labelText: 'Incident Type'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a description'
                    : null,
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: severity,
                items: ['low', 'moderate', 'high']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => severity = value!),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
              const SizedBox(height: 12),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: TextEditingController(
                  text: selectedDate == null
                      ? ''
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(selectedImage!, height: 150),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitReport,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
