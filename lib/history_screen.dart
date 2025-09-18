import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? "anonymous";

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sos_alerts')
              .where('email', isEqualTo: userEmail)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No alerts found.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              );
            }

            final alerts = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final data = alerts[index].data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp).toDate();
                final location = data['mapsUrl'] ?? "Unknown location";
                final status = data['status'] ?? "Pending";

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      status == 'sent' ? Icons.check_circle : Icons.schedule,
                      color: status == 'sent' ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      '${timestamp.toLocal()}'.split('.')[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      location,
                      style: const TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      status == 'sent' ? 'Delivered' : 'Pending',
                      style: TextStyle(
                        color: status == 'sent' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Optionally launch Google Maps
                      if (data['mapsUrl'] != null) {
                        final Uri url = Uri.parse(data['mapsUrl']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Map URL: ${url.toString()}')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
