import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_books/NavBar/nav_bar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPage extends StatefulWidget {
  const RazorpayPage({super.key, required this.Title});
  final String Title;

  @override
  State<RazorpayPage> createState() => _RazorpayPageState();
}

class _RazorpayPageState extends State<RazorpayPage> {
  late Razorpay _razorpay;
  late int recamount;

  void openCheckout(amount) {
    amount = amount * 100;
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': amount,
      'name': "Mini-Books",
      'prefill': {
        'contact': '8308112825',
        'email': 'ashirwadkatkamwar@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
      print("options opened");
    } catch (e) {
      print("error in opening options");
      debugPrint('Error : e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Payment successful ${response.paymentId!}",
      toastLength: Toast.LENGTH_SHORT,
    );
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FluidNavBarDemo()));
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed: ${response.message!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "Payment successful via ${response.walletName!}",
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
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
            child: SingleChildScrollView(
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
                          'Thank you for choosing \n mini-books',
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
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              int amount = 1200;
                              recamount = amount;
                              openCheckout(amount);
                            });
                          },
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
                            'Confirm your Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
