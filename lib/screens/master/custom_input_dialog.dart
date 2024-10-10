import 'package:flutter/material.dart';

class CustomInputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final void Function(String value) onSave;

  const CustomInputDialog({
    Key? key,
    required this.title,
    this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CustomInputDialog> createState() => _CustomInputDialogState();
}

class _CustomInputDialogState extends State<CustomInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Enter Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_nameController.text); // Trigger the callback
              Navigator.of(context).pop(); // Close the dialog after saving
            }
          },
        ),
      ],
    );
  }
}

Future<void> showCustomInputDialog({
  required BuildContext context,
  required String title,
  String? initialValue,
  required void Function(String value) onSave,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomInputDialog(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      );
    },
  );
}
