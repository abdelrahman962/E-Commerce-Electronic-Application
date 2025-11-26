import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_commerce_app/admin/home_admin.dart';
import 'package:e_commerce_app/admin/all_orders.dart';
import 'package:e_commerce_app/admin/add_product.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:e_commerce_app/admin/admin_profile.dart';
class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    AdminHomePage(),
    AllOrders(),        
    AddProduct(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        height: 65,
        color: AppColors.primaryBlue,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.primaryBlue,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          Icon(Icons.dashboard_outlined, size: 30, color: Colors.white),
          Icon(Icons.receipt_long_outlined, size: 30, color: Colors.white),
          Icon(Icons.add_box_outlined, size: 30, color: Colors.white),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
    );
  }
}