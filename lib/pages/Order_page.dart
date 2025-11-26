import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Stream<List<Map<String, dynamic>>> getMyOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]); 
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)  
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data["createdAt"] as Timestamp?;
        return {
          "name": data["productName"] ?? "Unknown Product",
          "price": data["productPrice"] ?? 0,
          "image": data["productImage"] ?? "",
          "description": "${data["productName"] ?? "Product"} (Purchased)",
          "orderId": data["orderId"] ?? "",
          "date": timestamp?.toDate() ?? DateTime.now(),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
              child: 
                 
                 Center(child: Text(
                    
                    "My Orders",
                    style: AppWidget.boldTextFieldStyle().copyWith(fontSize: 24),
                  ),
                 ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMyOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        Text(
                          "No orders yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your purchased items will appear here",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                         
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  order["image"],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/default.jpg",
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                order["name"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),

                              const Spacer(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${order["price"]}",
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Paid",
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _formatDate(order["date"]),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return "Today";
    if (difference.inDays == 1) return "Yesterday";
    if (difference.inDays < 7) return "${difference.inDays} days ago";
    return "${date.day}/${date.month}/${date.year}";
  }
}