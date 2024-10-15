import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? icon;
  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: AppColors.primaryBlue.withOpacity(0.4),
          ),
        ),
        // const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
              // enabledBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(
              //     color: AppColors.primaryBlue,
              //     width: 1.5,
              //   ),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              // focusedBorder: OutlineInputBorder(
              //   // borderSide: const BorderSide(
              //   //   color: AppColors.primaryBlue,
              //   //   width: 2.0,
              //   // ),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              hintText: labelText
              // filled: true,
              // fillColor: Colors.grey[100],
              // prefixIcon: icon != null
              //     ? Icon(
              //         icon,
              //         color: AppColors.primaryBlue,
              //       )
              //     : null,
              ),
        ),
      ],
    );
  }
}
