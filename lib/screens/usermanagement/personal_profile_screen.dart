import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class PersonalProfileScreen extends StatefulWidget {
  final Employee? employee;
  const PersonalProfileScreen({super.key, required this.employee});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * .02,
          vertical: size.height * .02,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          color: AppColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 10),
            LabelValueRow(
                label: "First Name",
                value: formatValue(widget.employee?.firstName)),
            LabelValueRow(
                label: "Middle Name",
                value: formatValue(widget.employee?.middleName)),
            LabelValueRow(
                label: "Last Name",
                value: formatValue(widget.employee?.lastName)),
            LabelValueRow(
                label: "Gender", value: formatValue(widget.employee?.gender)),
            LabelValueRow(
                label: "Birthday",
                value: formatValue(widget.employee?.birthday)),
            LabelValueRow(
                label: "Father's Name",
                value: formatValue(widget.employee?.fatherName)),
            LabelValueRow(
                label: "Age", value: formatValue(widget.employee?.age)),
          ],
        ),
      ),
    );
  }
}

String formatValue(String? value) {
  return (value?.trim().isEmpty ?? true) ? "-" : value!;
}
