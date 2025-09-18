import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background/flutter_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _triggerWordController = TextEditingController();
  bool _enableNotifications = true;
  bool _enableOfflineSMS = true;
  bool _enableBackgroundListening = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _triggerWordController.text = prefs.getString('triggerWord') ?? 'Help';
    setState(() {
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _enableOfflineSMS = prefs.getBool('enableOfflineSMS') ?? true;
      _enableBackgroundListening = prefs.getBool('enableBackgroundListening') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('triggerWord', _triggerWordController.text.trim());
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setBool('enableOfflineSMS', _enableOfflineSMS);
    await prefs.setBool('enableBackgroundListening', _enableBackgroundListening);

    if (_enableBackgroundListening) {
      const config = FlutterBackgroundAndroidConfig(
        notificationTitle: "Silent Help Active",
        notificationText: "Listening in background...",
        notificationImportance: AndroidNotificationImportance.high,
        enableWifiLock: true,
      );
      final initialized = await FlutterBackground.initialize(androidConfig: config);
      if (initialized) await FlutterBackground.enableBackgroundExecution();
    } else {
      await FlutterBackground.disableBackgroundExecution();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trigger Word",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _triggerWordController,
              decoration: const InputDecoration(
                hintText: 'Enter voice activation word (e.g., i need help)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text("Enable Push Notifications"),
              value: _enableNotifications,
              onChanged: (value) => setState(() => _enableNotifications = value),
            ),
            SwitchListTile(
              title: const Text("Enable Offline SMS Alerts"),
              value: _enableOfflineSMS,
              onChanged: (value) => setState(() => _enableOfflineSMS = value),
            ),
            SwitchListTile(
              title: const Text("Run in Background (Voice Trigger)"),
              value: _enableBackgroundListening,
              onChanged: (value) => setState(() => _enableBackgroundListening = value),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
