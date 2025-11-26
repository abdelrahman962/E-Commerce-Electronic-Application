import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 30,
    this.fontSize = 28,
  });

  String get _fallbackAvatar {
    final initial = name.isEmpty ? "U" : name.trim()[0].toUpperCase();
    return "https://ui-avatars.com/api/?name=$initial&background=0D8ABC&color=fff&format=png&size=256&bold=true";
  }

  Widget _buildLetterAvatar() {
    final initial = name.isEmpty ? "U" : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0D8ABC),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.isNotEmpty == true ? imageUrl! : _fallbackAvatar;

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF0D8ABC),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          placeholder: (_, __) => _buildLetterAvatar(),
          errorWidget: (_, __, ___) => _buildLetterAvatar(),
        ),
      ),
    );
  }
}