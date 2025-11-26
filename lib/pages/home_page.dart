import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/pages/product_detail_page.dart';
import 'package:e_commerce_app/pages/category_products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/widget/category_tile.dart';
import 'package:e_commerce_app/widget/user_avatar.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final List<String> categories = ["Watch", "Headphones", "Laptop"];
  final List<String> categoryImages = [
    "assets/images/watch.jpg",
    "assets/images/headphones.jpg",
    "assets/images/laptop.png",
  ];

  String? selectedCategory;
  final Color backgroundLight = const Color(0xFFF8F9FA);

  String userName = "User";
  String userAvatar = ""; 

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>?;

      setState(() {
        userName = data?["name"] ?? "User";

        final profileImage = data?["image"] as String?;
        if (profileImage != null && profileImage.isNotEmpty) {
          userAvatar = profileImage;
        } else {
          final initial = userName.isEmpty ? "U" : userName[0].toUpperCase();
          userAvatar =
              "https://ui-avatars.com/api/?name=$initial&background=0D8ABC&color=fff&size=128&bold=true";
        }
      });
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Stream<Map<String, List<Map<String, dynamic>>>> getProductsStream() {
    return FirebaseFirestore.instance.collection("products").snapshots().map((snapshot) {
      Map<String, List<Map<String, dynamic>>> tempProducts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data["category"] ?? "Other";

        tempProducts.putIfAbsent(category, () => []);
        tempProducts[category]!.add({
          "name": data["name"] ?? "",
          "price": data["price"] ?? 0,
          "image": data["image"] ?? "",
          "description": data["description"] ?? "",
        });
      }
      return tempProducts;
    });
  }
Widget _buildInitialAvatar() {
  final String initial = userName.isEmpty || userName.trim().isEmpty
      ? "U"
      : userName.trim()[0].toUpperCase();

  return Container(
    width: 60,
    height: 60,
    color: const Color(0xFF0D8ABC),
    alignment: Alignment.center,
    child: Text(
      initial,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
          stream: getProductsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No products available"));
            }

            final productsByCategory = snapshot.data!;
            List<Map<String, dynamic>> displayedProducts = selectedCategory == null
                ? productsByCategory.values.expand((e) => e).toList()
                : productsByCategory[selectedCategory] ?? [];

            if (_searchQuery.isNotEmpty) {
              displayedProducts = displayedProducts.where((product) {
                final name = (product["name"] ?? "").toString().toLowerCase();
                final desc = (product["description"] ?? "").toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase()) ||
                    desc.contains(_searchQuery.toLowerCase());
              }).toList();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, $userName!", style: AppWidget.boldTextFieldStyle()),
                          Text("Welcome!", style: AppWidget.lightTextFieldStyle()),
                        ],
                      ),
UserAvatar(
  name: userName,
  imageUrl: userAvatar,
  radius: 30,
  fontSize: 28,
),                  ],
                  ),
                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.search, color: AppColors.accentGrey),
                          onPressed: () {
                            setState(() {
                              _searchQuery = _searchController.text.trim();
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Categories", style: AppWidget.semiBoldTextFieldStyle()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 130,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => selectedCategory = null),
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              color: selectedCategory == null ? AppColors.primaryBlue : Colors.grey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text("All", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryProductsPage(category: categories[index]),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: CategoryTile(
                                  image: categoryImages[index],
                                  isSelected: selectedCategory == categories[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Products", style: AppWidget.semiBoldTextFieldStyle()),
                    ],
                  ),
                  const SizedBox(height: 10),

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
                    itemBuilder: (context, index) {
                      final product = displayedProducts[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              name: product["name"],
                              price: product["price"],
                              image: product["image"],
                              description: product["description"],
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product["image"],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    "assets/images/default.jpg",
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product["name"],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "\$${product["price"]}",
                                    style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const SizedBox(width: 30),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}    