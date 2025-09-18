import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  void _fetchLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final location = await _locationService.getLocation();
    setState(() {
      _currentLocation = location;
    });

    _locationService.onLocationChanged.listen((newLocation) {
      setState(() {
        _currentLocation = newLocation;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(newLocation.latitude!, newLocation.longitude!),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Live Location')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                  infoWindow: const InfoWindow(title: 'You are here'),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
