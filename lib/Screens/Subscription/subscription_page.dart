import 'package:flutter/material.dart';
import 'package:mini_books/Screens/Subscription/paymentGateway/razorpay_payment.dart';

import 'GooglePay/paySampleApp.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = '12 months'; // Default selected plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // Dark Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Help/FAQ action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Subscription Icon
            const Icon(Icons.card_giftcard, color: Colors.orange, size: 80),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Mini_books',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Trial Offer
            const Text(
              'Press to continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              'No ads, unlimited offline books, exclusive titles & more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // Subscription Options
            SubscriptionOption(
              duration: '1 month',
              price: 'Rs. 69.99 / month',
              isActive: selectedPlan == '1 month',
              onTap: () {
                setState(() {
                  selectedPlan = '1 month';
                });
              },
            ),
            SubscriptionOption(
              duration: '6 months',
              price: 'Rs. 419.99 / 6 months',
              isActive: selectedPlan == '6 months',
              onTap: () {
                setState(() {
                  selectedPlan = '6 months';
                });
              },
            ),
            SubscriptionOption(
              duration: '12 months',
              price: 'Rs. 12,000 / 12 months',
              discount: '16%',
              isPopular: true,
              isActive: selectedPlan == '12 months',
              onTap: () {
                setState(() {
                  selectedPlan = '12 months';
                });
              },
            ),

            const Spacer(),

            // Start Trial Button
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => RazorpayPage(
                //       Title: "userId",
                //     ),
                //   ),
                // );
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => const PayMaterialApp()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                child: Text(
                  'Start my free 14 day trial',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel anytime message
            const Text(
              'Cancel anytime.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String duration;
  final String price;
  final String? discount;
  final bool isActive;
  final bool isPopular;
  final VoidCallback onTap;

  const SubscriptionOption({super.key, 
    required this.duration,
    required this.price,
    this.discount,
    required this.isActive,
    this.isPopular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                border: isActive
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      color: isActive ? Colors.orange : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Discount Badge
          if (discount != null)
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$discount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // Most Popular Badge
          if (isPopular)
            Positioned(
              bottom: -10,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
