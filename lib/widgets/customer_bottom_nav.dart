// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
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
    
    final List<BottomNavItem> navItems = [
      BottomNavItem(
        label: 'dashboard'.tr(context),
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
      ),
      BottomNavItem(
        label: 'transactions'.tr(context),
        icon: Icons.swap_horiz_outlined,
        activeIcon: Icons.swap_horiz,
      ),
      BottomNavItem(
        label: 'debts'.tr(context),
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment,
      ),
      BottomNavItem(
        label: 'budget'.tr(context),
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet,
      ),
        
      BottomNavItem(
        label: 'more'.tr(context),
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navItems.length,
              (index) => _buildNavItem(
                  context: context, // ✅ ADD THIS
                item: navItems[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
      required BuildContext context, // ✅ ADD THIS

    required BottomNavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon above
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            // Label below
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}