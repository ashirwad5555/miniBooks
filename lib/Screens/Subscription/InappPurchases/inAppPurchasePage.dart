import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:mini_books/NavBar/nav_bar.dart';
import 'package:mini_books/Services/premium_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppPurchasePage extends StatefulWidget {
  const InAppPurchasePage({super.key, required this.title});
  final String title;

  @override
  State<InAppPurchasePage> createState() => _InAppPurchasePageState();
}

class _InAppPurchasePageState extends State<InAppPurchasePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;
  bool _isPurchasePending = false;

  // Define your product IDs here
  static const Set<String> _productIds = {'premium_subscription'};

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('Error in purchase stream: $error');
      },
    );
    _initInAppPurchase();
  }

  Future<void> _initInAppPurchase() async {
    // TEMPORARY DEBUG CODE - REMOVE FOR PRODUCTION
    // Force _isAvailable to true for testing the UI
    setState(() {
      _isAvailable = true; // Force this to true for testing
      _isLoading = false;
    });

    // Add a mock product for testing
    if (_products.isEmpty) {
      _products = [
        ProductDetails(
          id: 'premium_subscription',
          title: 'Premium Subscription',
          description: 'Lifetime Premium Access',
          price: 'Rs. 1,500.00',
          rawPrice: 1500.0,
          currencyCode: 'INR',
          currencySymbol: '₹',
        )
      ];
    }

    // Comment out the rest of the method for UI testing
    // Uncomment for actual store integration
    /*
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
      return;
    }

    // Configure iOS platform-specific options (if applicable)
    if (Platform.isIOS) {
      try {
        // Get the iOS platform addition
        final InAppPurchaseStoreKitPlatformAddition iosAddition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

        // Set the delegate - using an instance of our own class that implements the correct interface
        // Only include iOS-specific code if needed
        // iOS-specific configuration
        await iosAddition.setDelegate(PaymentQueueDelegate());
      } catch (e) {
        debugPrint('Failed to configure iOS platform: $e');
      }
    }

    try {
      final ProductDetailsResponse productDetailsResponse =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (productDetailsResponse.error != null) {
        setState(() {
          _isAvailable = false;
          _isLoading = false;
        });
        return;
      }

      if (productDetailsResponse.productDetails.isEmpty) {
        setState(() {
          _isAvailable = false;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _products = productDetailsResponse.productDetails;
        _isAvailable = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error querying product details: $e');
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
    }
    */
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          setState(() {
            _isPurchasePending = true;
          });
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify the purchase on server and deliver the product
          await _verifyPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          setState(() {
            _isPurchasePending = false;
          });
          _handleError(purchaseDetails.error!);
          break;
        case PurchaseStatus.canceled:
          setState(() {
            _isPurchasePending = false;
          });
          break;
      }

      // Complete the purchase if needed
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Here you would typically verify the purchase with your backend
    // After verification, update the user's subscription status

    // For demonstration purposes, we'll just show a success message
    // and navigate to the main screen after a successful purchase
    setState(() {
      _isPurchasePending = false;
    });

    // Show success toast
    Fluttertoast.showToast(
      msg: "Premium subscription activated successfully!",
      toastLength: Toast.LENGTH_SHORT,
    );

    // Save premium status to local storage and update backend
    await _savePremiumStatus();

    // Navigate to home screen
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const FluidNavBarDemo()),
        (route) => false,
      );
    }
  }

  Future<void> _savePremiumStatus() async {
    // Get current user email from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email != null) {
      // Save premium status locally and update backend
      await PremiumService.savePremiumStatus(email: email);
    } else {
      // Fallback if no email found (should not happen in a proper login flow)
      Fluttertoast.showToast(
        msg:
            "Warning: Unable to update subscription status on server. Please contact support.",
        toastLength: Toast.LENGTH_LONG,
      );

      // Still save locally
      await PremiumService.savePremiumStatus(email: "unknown@example.com");
    }
  }

  void _handleError(IAPError error) {
    Fluttertoast.showToast(
      msg: "Purchase failed: ${error.message}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<void> _buyProduct(ProductDetails product) async {
    // TEMPORARY DEBUG HANDLER - REMOVE FOR PRODUCTION
    // This simulates a successful purchase for testing
    Fluttertoast.showToast(
      msg: "Simulating purchase in test mode",
      toastLength: Toast.LENGTH_SHORT,
    );

    // Simulate successful purchase after a delay
    await Future.delayed(const Duration(seconds: 2));
    await _verifyPurchase(PurchaseDetails(
      productID: product.id,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'test',
        serverVerificationData: 'test',
        source: 'test',
      ),
      transactionDate: DateTime.now().toString(),
      status: PurchaseStatus.purchased,
      purchaseID: 'test_purchase',
    ));

    // Comment this out during testing
    /*
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      // Start the purchase flow
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        Fluttertoast.showToast(
          msg: "Purchase could not be initiated",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    */
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4A8A), Color(0xFF76C7C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _buildPurchaseContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseContent() {
    if (!_isAvailable) {
      return _buildErrorView(
          "In-app purchases are not available on this device");
    }

    if (_products.isEmpty) {
      return _buildErrorView("Products not found");
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://img.freepik.com/premium-vector/secure-payment-credit-card-icon-with-shield-secure-transaction-vector-stock-illustration_100456-11325.jpg',
                    height: 100,
                    width: 300,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unlock Premium Features',
                  style: TextStyle(
                    color: Color(0xFF4A4A8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Get unlimited access to premium eBooks and exclusive content',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                // Use a safe check before accessing _products[0]
                _products.isNotEmpty
                    ? _buildPriceWidget(_products[0])
                    : _buildDefaultPriceWidget(),
                const SizedBox(height: 25),
                _buildFeaturesList(),
                const SizedBox(height: 30),
                _isPurchasePending
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _products.isNotEmpty
                            ? () => _buyProduct(_products[0])
                            : null, // Disable the button if no products
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF76C7C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shadowColor: Colors.black26,
                          elevation: 8,
                        ),
                        child: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Not now',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment will be charged to your Google Play account',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // Add this new method for when no product is available
  Widget _buildDefaultPriceWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rs. 1500',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A8A),
            ),
          ),
          Text(
            ' - Lifetime Access',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceWidget(ProductDetails product) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rs. 1500',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A8A),
            ),
          ),
          const Text(
            ' - Lifetime Access',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Unlimited access to premium eBooks',
      'Ad-free reading experience',
      'Exclusive content updates',
      'Offline reading',
      'Priority customer support'
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF76C7C0),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

/// iOS payment queue delegate implementation
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return true;
  }
}
