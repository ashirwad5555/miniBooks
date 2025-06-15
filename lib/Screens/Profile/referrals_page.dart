// Create a new file: lib/Screens/Profile/referrals_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_books/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Theme/mytheme.dart';

class ReferralsPage extends StatefulWidget {
  const ReferralsPage({super.key});

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  bool _isLoading = true;
  List<dynamic> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? '';

      if (email.isEmpty) {
        throw Exception('User not logged in');
      }

      // Log the API call for debugging
      print('Fetching referrals for email: $email');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/referrals?email=$email'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Referrals API response status: ${response.statusCode}');
      print('Referrals API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // The server returns referrals in the 'referrals' field
          _referrals = List<dynamic>.from(data['referrals'] ?? []);
          _isLoading = false;
        });
      } else {
        String errorMessage = 'Failed to load referrals';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (_) {}

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error loading referrals: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load referrals: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Referrals'),
        flexibleSpace: Container(
          decoration: AppTheme.getGradientDecoration(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _referrals.isEmpty
              ? _buildEmptyState()
              : _buildReferralsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Referrals Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your referral code to invite friends',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _referrals.length,
      itemBuilder: (context, index) {
        final referral = _referrals[index];
        DateTime? date;

        // Handle different date formats
        try {
          if (referral['date'] != null) {
            date = DateTime.parse(referral['date']);
          }
        } catch (e) {
          print('Error parsing date: $e');
        }

        final formattedDate = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : 'Unknown date';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.gradientStart.withOpacity(0.2),
              child: Text(
                referral['name'] != null &&
                        referral['name'].toString().isNotEmpty
                    ? referral['name'][0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: AppTheme.gradientStart,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              referral['name'] ?? 'Unknown User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(referral['email'] ?? 'No email'),
                const SizedBox(height: 4),
                Text(
                  'Joined: $formattedDate',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
