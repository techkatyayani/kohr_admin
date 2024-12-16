import 'package:flutter/material.dart';

class JobDescriptionTextField extends StatefulWidget {
  final TextEditingController controller;

  const JobDescriptionTextField({Key? key, required this.controller})
      : super(key: key);

  @override
  _JobDescriptionTextFieldState createState() =>
      _JobDescriptionTextFieldState();
}

class _JobDescriptionTextFieldState extends State<JobDescriptionTextField> {
  // For Text styling and alignment
  TextAlign _textAlign = TextAlign.left;
  bool _isBold = false;
  Color _textColor = Colors.black;

  // Function to toggle bold style
  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    _applyTextStyle();
  }

  // Function to change text color for selected text
  void _changeTextColor(Color color) {
    setState(() {
      _textColor = color;
    });
    _applyTextStyle();
  }

  // Function to change text alignment
  void _changeTextAlign(TextAlign alignment) {
    setState(() {
      _textAlign = alignment;
    });
  }

  // Function to apply text styling (bold, color)
  void _applyTextStyle() {
    final textSelection = widget.controller.selection;
    if (textSelection.isValid) {
      final currentText = widget.controller.text;
      final selectedText = currentText.substring(textSelection.start, textSelection.end);

      // We cannot directly apply rich text to TextField, but we can use this as an illustration
      widget.controller.text = currentText.replaceRange(textSelection.start, textSelection.end, selectedText);
      widget.controller.selection = textSelection;
    }
  }

  // Function to show a simple color picker dialog
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Text Color"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorOptionButton(
                color: Colors.black,
                label: 'Black',
                onTap: () => _changeTextColor(Colors.black),
              ),
              ColorOptionButton(
                color: Colors.blue,
                label: 'Blue',
                onTap: () => _changeTextColor(Colors.blue),
              ),
              ColorOptionButton(
                color: Colors.red,
                label: 'Red',
                onTap: () => _changeTextColor(Colors.red),
              ),
              ColorOptionButton(
                color: Colors.orange,
                label: 'Orange',
                onTap: () => _changeTextColor(Colors.orange),
              ),
              ColorOptionButton(
                color: Colors.green,
                label: 'Green',
                onTap: () => _changeTextColor(Colors.green),
              ),
              ColorOptionButton(
                color: Colors.purple,
                label: 'Purple',
                onTap: () => _changeTextColor(Colors.purple),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300], // No border color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for toolbar with icons
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.format_align_left),
                onPressed: () => _changeTextAlign(TextAlign.left),
              ),
              IconButton(
                icon: Icon(Icons.format_align_center),
                onPressed: () => _changeTextAlign(TextAlign.center),
              ),
              IconButton(
                icon: Icon(Icons.format_align_right),
                onPressed: () => _changeTextAlign(TextAlign.right),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: _isBold ? Colors.blue : Colors.black,
                ),
                onPressed: _toggleBold,
              ),
              IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: () {
                  _showColorPicker(context); // Open color picker
                },
              ),
            ],
          ),
          // The actual TextField for job description with dynamic styling
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: 'Job Description',
                labelStyle: TextStyle(
                  color: Colors.grey, // Custom label style
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Enter job description here',
                // Custom decoration
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue, // Focused border color
                    width: 2,
                  ),
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                color: _textColor, // Dynamically change color
              ),
              textAlign: _textAlign, // Dynamically change alignment
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget to show color options
class ColorOptionButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const ColorOptionButton({
    Key? key,
    required this.color,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
