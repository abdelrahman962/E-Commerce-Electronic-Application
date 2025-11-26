import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB); 
  static const Color primaryDark = Color(
    0xFF1E293B,
  ); 
  static const Color accentGrey = Color(
    0xFF64748B,
  ); 
  static const Color shadowColor = Color(
    0xFFE2E8F0,
  ); 
}

class AppWidget {
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
      fontSize: 30.0,
      color: AppColors.primaryDark, 
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle lightTextFieldStyle() {
    return const TextStyle(
      fontSize: 20.0,
      color: AppColors.accentGrey, 
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle semiBoldTextFieldStyle() {
    return const TextStyle(
      fontSize: 22.0,
      color: AppColors.primaryDark, 
      fontWeight: FontWeight.bold,
    );
  }
}
