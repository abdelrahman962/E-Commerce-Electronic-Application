import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await FirebaseFirestore.instance.collection("products").add(productData);
  }

}
