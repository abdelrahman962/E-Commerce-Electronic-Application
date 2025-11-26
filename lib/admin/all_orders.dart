import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:flutter/material.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders>
    with AutomaticKeepAliveClientMixin {   

  @override
  bool get wantKeepAlive => true;         

Stream<QuerySnapshot> getAllOrders() {
  return FirebaseFirestore.instance
      .collectionGroup("orders")
      .snapshots(); 
}

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("All Orders (Admin)",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No orders yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final orderDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final data = orderDocs[index].data() as Map<String, dynamic>;
              final timestamp = data["createdAt"] as Timestamp?;
              final amount = (data["amount"] ?? data["productPrice"] ?? 0).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data["productImage"] ?? "",
                          width: 70, height: 70, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset("assets/images/default.jpg", width: 70, height: 70, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data["productName"] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("by ${data["userName"] ?? "Guest"}", style: TextStyle(color: Colors.grey[700])),
                            Text("Email: ${data["userEmail"] ?? "N/A"}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: const Text("Paid", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}