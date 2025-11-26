import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_commerce_app/pages/home_page.dart';
import 'package:e_commerce_app/widget/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/pages/order_page.dart';
import 'package:e_commerce_app/pages/profile_page.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget> pages;
  late HomePage homePage;
  late OrderPage orderPage;
  late ProfilePage profilePage;
  int currentIndex = 0;
  @override
  void initState() {
    homePage = const HomePage();
    orderPage = const OrderPage();
    profilePage = const ProfilePage();
    pages = [homePage, orderPage, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: AppColors.primaryBlue,
        animationDuration: Duration(milliseconds: 500),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
