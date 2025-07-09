// lib/widgets/info_chip.dart

import 'package:booq/utils/app_colors.dart';
import 'package:booq/utils/app_styles.dart';
import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
