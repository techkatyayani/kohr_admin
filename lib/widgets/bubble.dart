import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';

class BubbleWidget extends StatelessWidget {
  final double height;
  final double width;
  const BubbleWidget({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
        height: height,
        width: width,
      ),
    );
  }
}
