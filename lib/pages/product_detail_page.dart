import 'dart:convert';

import 'package:e_commerce_app/services/constants.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce_app/services/shared_pref.dart';
import 'package:e_commerce_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ProductDetailPage extends StatefulWidget {
  final String name;
  final dynamic price;
  final String image;
  final String description;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? paymentIntent;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.image.startsWith("http")
                  ? Image.network(
                      widget.image,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset("assets/images/default.png", height: 300),
                    )
                  : Image.asset(
                      widget.image,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.name, style: AppWidget.boldTextFieldStyle()),
                      Text(
                        "\$${widget.price}",
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text("Details", style: AppWidget.semiBoldTextFieldStyle()),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => makePayment(widget.price.toString()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Buy Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> makePayment(String amount) async {


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      if (paymentIntent == null || paymentIntent!['client_secret'] == null) {
        Navigator.pop(context);
        showErrorDialog('Failed to create payment intent.');
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Abdalrahman',
        ),
      );

      Navigator.pop(context); 
      await displayPaymentSheet();
    } catch (e) {
      Navigator.pop(context);
      debugPrint('Payment exception: $e');
      showErrorDialog('Payment failed. Please try again.');
    }
  }

Future<void> displayPaymentSheet() async {
  try {
    await Stripe.instance.presentPaymentSheet();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showErrorDialog("You must be logged in to place an order.");
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    final userData = userDoc.data() ?? {};
    final userName = userData["name"] ?? "Guest";
    final userAvatar = userData["image"] ?? "";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("orders")
        .add({
      "userId": user.uid,
      "userEmail": user.email,
      "userName": userName,
      "userAvatar": userAvatar,

      "orderId": paymentIntent!['id'],
"amount": (paymentIntent!['amount'] as num) / 100,      "currency": paymentIntent!['currency'].toUpperCase(),
      "status": "completed",
      "createdAt": FieldValue.serverTimestamp(),

      "productName": widget.name,
      "productPrice": widget.price,
      "productImage": widget.image,
      "quantity": 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Successful! Order saved."),
        backgroundColor: Colors.green,
      ),
    );
  } on StripeException catch (e) {
    String msg = e.error.localizedMessage ?? "Payment failed";
    if (e.error.code == FailureCode.Canceled) msg = "Payment cancelled";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  } catch (e) {
    debugPrint("Error: $e");
    showErrorDialog("Something went wrong");
  }
}

  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${Constants.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (err) {
      debugPrint('Error charging user: $err');
      return null;
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount) * 100).toInt();
    return calculatedAmount.toString();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
