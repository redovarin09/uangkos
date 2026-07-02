import 'package:flutter/material.dart';
import 'package:uang_kos/core/constants/app_colors.dart';
import 'package:uang_kos/core/constants/app_strings.dart';

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text(AppStrings.labelCatatBayar),
    );
  }
}
