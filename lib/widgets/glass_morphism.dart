// lib/widgets/glass_morphism.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  const GlassMorphism({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (isDark ? Colors.white : Colors.black).withOpacity(opacity),
                (isDark ? Colors.white : Colors.black).withOpacity(opacity * 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}