import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/admin/add_product.dart';
import 'package:e_commerce_app/admin/admin_login.dart';
import 'package:e_commerce_app/pages/product_detail_page.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<Map<String, List<Map<String, dynamic>>>> getProductsStream() {
    return FirebaseFirestore.instance.collection("products").snapshots().map((snapshot) {
      Map<String, List<Map<String, dynamic>>> tempProducts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data["category"] ?? "Other";
        tempProducts.putIfAbsent(category, () => []);
        tempProducts[category]!.add({
          "id": doc.id,
          "name": data["name"] ?? "",
          "price": data["price"] ?? 0,
          "image": data["image"] ?? "",
          "description": data["description"] ?? "",
        });
      }
      return tempProducts;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout from admin panel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully"), backgroundColor: Colors.green),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProduct()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
        stream: getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final productsByCategory = snapshot.data!;
          final categories = productsByCategory.keys.toList();

          List<Map<String, dynamic>> allProducts = productsByCategory.values.expand((list) => list).toList();
          List<Map<String, dynamic>> displayedProducts = allProducts;
          if (_searchQuery.isNotEmpty) {
            displayedProducts = allProducts.where((product) {
              final name = (product["name"] ?? "").toString().toLowerCase();
              final desc = (product["description"] ?? "").toString().toLowerCase();
              return name.contains(_searchQuery) || desc.contains(_searchQuery);
            }).toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Expanded(child: _buildStatCard("Total Orders", Icons.shopping_bag, Colors.orange)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard("Total Products", Icons.inventory_2, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 30),

                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = _searchController.text.trim().toLowerCase();
                          });
                        },
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                
                if (_searchQuery.isNotEmpty) ...[
                  if (displayedProducts.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No products found for "$_searchQuery"', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) => _buildProductCard(displayedProducts[index]),
                    ),
                ]
                
                else ...[
                  ...categories.map((category) {
                    final products = productsByCategory[category]!;
                    if (products.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category, style: AppWidget.semiBoldTextFieldStyle().copyWith(fontSize: 20)),
                            Text("${products.length} items", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) => _buildProductCard(products[index]),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: product["name"],
              price: product["price"],
              image: product["image"],
              description: product["description"],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product["image"],
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset("assets/images/default.jpg", height: 110, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product["name"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product["price"]}",
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProduct(
                          isEditMode: true,
                          productId: product["id"],
                          initialData: product,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.edit, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          title.contains("Orders")
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collectionGroup("orders").snapshots(),
                  builder: (context, snapshot) => Text("${snapshot.data?.docs.length ?? 0}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("products").snapshots(),
                  builder: (context, snapshot) => Text("${snapshot.data?.docs.length ?? 0}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No products yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProduct())),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text("Add First Product", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}