import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:silent_application/location_helper.dart';
import 'package:silent_application/speech_service.dart';
import 'package:silent_application/firebase_alert_service.dart';
import 'package:silent_application/alert_notifier_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "anonymous";

  @override
  void initState() {
    super.initState();
    _speechService.initialize(onTrigger: _triggerSOS);
  }

  Future<void> _triggerSOS(String _) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 SOS Triggered! Sending alerts...')),
    );

    final location = Location();
    final locationData = await location.getLocation();

    if (locationData.latitude != null && locationData.longitude != null) {
      final lat = locationData.latitude!;
      final lng = locationData.longitude!;
      final mapsUrl = generateMapsUrl(lat, lng);
      final message = '🚨help! My location: $mapsUrl';

      debugPrint("📍 Google Maps URL: $mapsUrl");

      // Store alert in Firebase
      await FirebaseAlertService.sendAlert(
        userEmail: userEmail,
        message: message,
        lat: lat,
        lng: lng,
      );

      // Notify all contacts via email
      await AlertNotifierService.sendAlertToContacts(message);
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Silent Help'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.deepPurple.shade800,
              Colors.pink.shade700,
              Colors.redAccent.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hearing, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Say "Help" or press the button to send an SOS alert.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _triggerSOS("manual"),
                icon: const Icon(Icons.warning_amber_rounded, size: 32),
                label: const Text('SEND SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickNav(context, Icons.contacts, 'Contacts', '/contacts'),
                  _buildQuickNav(context, Icons.map, 'Location', '/location'),
                  _buildQuickNav(context, Icons.history, 'History', '/history'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickNav(BuildContext context, IconData icon, String label, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

