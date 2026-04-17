// lib/widgets/animated_card.dart
import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int delay;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = 0,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: this.child,
          ),
        ),
      ),
    );
  }
}