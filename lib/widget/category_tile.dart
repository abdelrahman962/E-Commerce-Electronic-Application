import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String image;
  final bool isSelected;

  const CategoryTile({
    super.key,
    required this.image,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(left: isSelected ? 10 : 0),
            child: Icon(
              Icons.arrow_forward,
              size: isSelected ? 28 : 18,
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              weight: isSelected ? 800 : 400,
            ),
          ),
        ],
      ),
    );
  }
}
