import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String? title;
  final String value;
  final double? fontSize; // Font size for both title and value
  final FontWeight? fontWeight; // Font weight for the title
  final Color? titleColor; // Color for the title text
  final Color? valueColor; // Color for the value text
 final Icon? icon;
  const TextWidget({
    Key? key,
    this.title,
    required this.value,
    this.fontSize = 16.0, // Default font size
    this.fontWeight = FontWeight.bold, // Default font weight
    this.titleColor = Colors.black, // Default color for the title
    this.valueColor = Colors.black, // Default color for the value
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize, // Set the font size for the title
              color: titleColor, // Set the color for the title
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize, // Set the font size for the value
                color: valueColor, // Set the color for the value
              ),
            ),
          ),
        ],
      ),
    );
  }
}
