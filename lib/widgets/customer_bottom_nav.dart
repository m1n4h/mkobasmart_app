// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../localization/app_localizations.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBottomNavigationBar(
      icons: const [
        Icons.dashboard_outlined,
        Icons.swap_horiz_outlined,
        Icons.assignment_outlined,
        Icons.account_balance_wallet_outlined,
        Icons.more_horiz,
      ],
      activeIndex: currentIndex,
      gapLocation: GapLocation.none,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 16,
      rightCornerRadius: 16,
      onTap: onTap,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Colors.grey,
      splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
      elevation: 10,
      shadow: BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, -5),
      ),
    );
  }
}