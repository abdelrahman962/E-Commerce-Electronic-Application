import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:path/path.dart' as path;

class AddProduct extends StatefulWidget {
  final bool isEditMode;
  final String? productId;
  final Map<String, dynamic>? initialData;

  const AddProduct({
    super.key,
    this.isEditMode = false,
    this.productId,
    this.initialData,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController priceController;

  String? selectedCategory;
  final List<String> categories = ["Watch", "Headphones", "Laptop"];

  final List<String> networkImages = [
    'https://i.postimg.cc/ZRm1Js66/smart-watch.png',
    'https://i.postimg.cc/tgWKQGZS/classic_watch.png',
    'https://i.postimg.cc/Ss4wm1c6/sport_watch.png',
    'https://i.postimg.cc/K8n6CyMh/i_Phone_16_Pro_Black_Titanium_Flat_cropped.webp',
    'https://i.postimg.cc/SKCBFb25/galaxy_s32.png',
    'https://i.postimg.cc/d1FzJNGT/REDMI.png',
    'https://i.postimg.cc/q7yPVH6g/On_ear_headphones.png',
    'https://i.postimg.cc/DzL9k3JC/earbuds.png',
    'https://i.postimg.cc/wvzS94Dg/Over_ear_noise_cancelling.png',
  ];

  String? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData?["name"] ?? "");
    descController = TextEditingController(text: widget.initialData?["description"] ?? "");
    priceController = TextEditingController(text: widget.initialData?["price"]?.toString() ?? "");

    selectedCategory = widget.initialData?["category"];
    selectedImage = widget.initialData?["image"]; 
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    if (selectedCategory == null ||
        nameController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      String imageUrl = selectedImage!;
      if (!selectedImage!.startsWith('http')) {
        final byteData = await DefaultAssetBundle.of(context).load(selectedImage!);
        final bytes = byteData.buffer.asUint8List();

        final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}${path.extension(selectedImage!)}';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putData(bytes);
        imageUrl = await storageRef.getDownloadURL();
      }

      final productData = {
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'category': selectedCategory,
        'image': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEditMode && widget.productId != null) {
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productId)
            .update(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated successfully!"), backgroundColor: Colors.green),
        );
      } else {
        productData['createdAt'] = FieldValue.serverTimestamp();
        await DatabaseMethods().addProduct(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!"), backgroundColor: Colors.green),
        );
      }

      if (mounted) Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: networkImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final imgUrl = networkImages[index];
        final isSelected = imgUrl == selectedImage;

        return GestureDetector(
          onTap: () => setState(() => selectedImage = imgUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                width: isSelected ? 4 : 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imgUrl, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),

    appBar: widget.isEditMode
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA), 
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Add Product",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Product Preview", style: AppWidget.semiBoldTextFieldStyle()),
          const SizedBox(height: 12),
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                color: Colors.grey[100],
              ),
              child: selectedImage == null
                  ? const Icon(Icons.image, size: 60, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(selectedImage!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 25),

          Text("Select Product Image", style: AppWidget.semiBoldTextFieldStyle()),
          const SizedBox(height: 12),
          buildImageGrid(),
          const SizedBox(height: 30),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Product Name",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Price (\$)",
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category",
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCategory = value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                widget.isEditMode ? "Update Product" : "Add Product",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}}