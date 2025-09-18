import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:silent_application/location_helper.dart';

class FirebaseAlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send emergency alert to Firestore
  static Future<void> sendAlert({
    required String userEmail,
    required String message,
    required double lat,
    required double lng,
  }) async {
    try {
      await _firestore.collection('sos_alerts').add({
        'email': userEmail,
        'timestamp': Timestamp.now(),
        'location': {
          'lat': lat,
          'lng': lng,
        },
        'mapsUrl': generateMapsUrl(lat, lng),
        'message': message,
        'status': 'sent', // optional field for tracking
      });
      print("✅ Alert saved to Firebase");
    } catch (e) {
      print("❌ Failed to send alert to Firebase: $e");
    }
  }
}
