import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// #$ GamifyProgressBar — barra fina arredondada com trilho escuro,
// usada no XP global, nas missões e nos atributos.
class GamifyProgressBar extends StatelessWidget {
  final double ratio; // #p 0..1
  final Color color;
  final double height;

  const GamifyProgressBar({
    super.key,
    required this.ratio,
    this.color = AppColors.primaryGreen,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: height, color: AppColors.border),
              Container(
                height: height,
                width: constraints.maxWidth * ratio.clamp(0, 1),
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
