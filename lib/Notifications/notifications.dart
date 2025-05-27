import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format dates

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'New Update Available',
      'description': 'Version 2.0 is now available for download.',
      'time': DateFormat('jm').format(DateTime.now().subtract(const Duration(hours: 3))),
    },
    {
      'title': 'Account Activity',
      'description': 'Your account was logged in from a new device.',
      'time': DateFormat('jm').format(DateTime.now().subtract(const Duration(hours: 3))),
    },
    {
      'title': 'Subscription Expiring',
      'description': 'Your subscription will expire in 3 days. Renew now!',
      'time': DateFormat('jm').format(DateTime.now().subtract(const Duration(days: 1))),
    },
    {
      'title': 'Welcome!',
      'description': 'Thank you for signing up! Explore the new features today.',
      'time': DateFormat('jm').format(DateTime.now().subtract(const Duration(days: 2))),
    },
  ];

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.shade200,
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['description']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              notification['time']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

