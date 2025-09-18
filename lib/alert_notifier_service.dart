import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertNotifierService {
  static Future<void> sendAlertToContacts(String message) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userEmail = currentUser.email;
    final contactsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('contacts');

    final contactsSnapshot = await contactsRef.get();
    final contacts = contactsSnapshot.docs;

    // ⚠️ Replace with your actual Gmail & App Password
    final smtpServer = gmail('your_email@gmail.com', 'your_app_password');

    for (var contact in contacts) {
      final data = contact.data();
      final recipientEmail = data['email'];

      if (recipientEmail != null) {
        final email = Message()
          ..from = const Address('your_email@gmail.com', 'Silent Help')
          ..recipients.add(recipientEmail)
          ..subject = '🚨 SOS Alert'
          ..text = message;

        try {
          await send(email, smtpServer);
          print("✅ Email sent to $recipientEmail");
        } catch (e) {
          print("❌ Failed to send email to $recipientEmail: $e");
        }
      }
    }
  }
}
