import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled; // Add enabled property
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled, // Set enabled state here
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.primaryBlue.withOpacity(0.4)
              : Colors.grey.withOpacity(0.6), // Grey out label when disabled
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: enabled ? AppColors.primaryBlue : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: enabled ? AppColors.primaryBlue : Colors.grey,
              )
            : null,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.6),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
