import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ContactSetupScreen extends StatefulWidget {
  const ContactSetupScreen({super.key});

  @override
  _ContactSetupScreenState createState() => _ContactSetupScreenState();
}

class _ContactSetupScreenState extends State<ContactSetupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();

  List<Map<String, dynamic>> contacts = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      _loadContacts();
    }
  }

  Future<void> _loadContacts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('contacts')
          .get();

      setState(() {
        contacts = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'],
            'email': data['email'],
            'number': data['number'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }

  Future<void> _addContact() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final number = numberController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && number.isNotEmpty && userEmail != null) {
      final newContact = {
        'name': name,
        'email': email,
        'number': number,
      };

      final contactRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('contacts');

      try {
        final docRef = await contactRef.add(newContact);
        setState(() {
          contacts.add({'id': docRef.id, ...newContact});
          nameController.clear();
          emailController.clear();
          numberController.clear();
        });

        _showSuccessDialog();
      } catch (e) {
        print('Error adding contact: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: const Text("Your emergency contact has been saved successfully!"),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _removeContact(String docId, int index) async {
    if (userEmail == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .collection('contacts')
          .doc(docId)
          .delete();

      setState(() {
        contacts.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact removed')),
      );
    } catch (e) {
      print('Error removing contact: $e');
    }
  }

  Future<void> _sendAlertToContacts(String message) async {
    final smtpServer = gmail('your_email@gmail.com', 'your_email_password');

    for (var contact in contacts) {
      final email = contact['email'];

      final mail = Message()
        ..from = const Address('your_email@gmail.com', 'Silent Help')
        ..recipients.add(email)
        ..subject = '🚨 SOS Alert'
        ..text = message;

      try {
        final sendReport = await send(mail, smtpServer);
        print('Alert sent to $email: ${sendReport.toString()}');
      } catch (e) {
        print('Failed to send alert to $email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple, // Deep Purple
              Colors.redAccent,  // Red
              Colors.orange,     // Orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.2, 0.5, 0.8],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addContact,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Contact', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: contacts.isEmpty
                  ? const Center(child: Text("No contacts added yet.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Card(
                          color: Colors.white.withOpacity(0.8),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.contact_mail, color: Colors.redAccent),
                            title: Text(contact['name'] ?? '', style: const TextStyle(color: Colors.deepPurple)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${contact['email']}', style: const TextStyle(color: Colors.deepPurple)),
                                Text('Phone: ${contact['number']}', style: const TextStyle(color: Colors.deepPurple)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeContact(contact['id'], index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
