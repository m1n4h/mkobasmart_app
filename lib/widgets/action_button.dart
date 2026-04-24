// lib/widgets/action_button.dart
import 'package:flutter/material.dart';
import '../screens/category/category_list_screen.dart';

class CategoryNavigationButton extends StatelessWidget {
  const CategoryNavigationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CategoryListScreen()),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.grid_view_rounded, // Better icon for categories/inventory
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Categories",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}