import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Dark Background
        Container(color: AppColors.background),
        
        // Top Left Purple Glow
        Positioned(
          top: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 150,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Right Teal Glow
        Positioned(
          bottom: -200,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.15),
                  blurRadius: 180,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),
        
        // Center-Left Ambient Glow (Subtle)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: -200,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 150,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
