import 'package:flutter/material.dart';

import '../Controller/FirebaseFuntions.dart';

class DepartmentDropdown extends StatelessWidget {
  final Future<List<String>> future;
  final String? selectedValue;
  final Function(String?) onChanged;

  const DepartmentDropdown({
    Key? key,
    required this.future,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No departments available");
        }

        final departments = snapshot.data!;
        return DropdownButton<String>(
          value: selectedValue,
          hint: const Text("Select Department"),
          underline: const SizedBox(),
          items: departments.map((dept) {
            return DropdownMenuItem(
              value: dept,
              child: Text(dept),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
