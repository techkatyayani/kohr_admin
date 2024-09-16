import 'package:flutter/material.dart';
import 'package:kohr_admin/colors.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: AppColors.primaryBlue.withOpacity(0.4),
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderSide: const BorderSide(
        //     color: AppColors.primaryBlue,
        //     width: 1.5,
        //   ),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: AppColors.primaryBlue,
              )
            : null,
      ),
    );
  }
}
