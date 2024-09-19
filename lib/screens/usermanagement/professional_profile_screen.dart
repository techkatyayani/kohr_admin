import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final Employee? employee;
  const ProfessionalProfileScreen({super.key, this.employee});

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
            Text(
              "Professional Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "Highest Education Qualification",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  LabelValueRow(label: "Degree", value: "-"),
                  LabelValueRow(label: "Specialization", value: "-"),
                  LabelValueRow(label: "Collage", value: "-"),
                  LabelValueRow(label: "Time", value: "-"),
                ],
              ),
            ),
            Text(
              "Post Work Experience",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  LabelValueRow(label: "Title", value: "-"),
                  LabelValueRow(label: "Location", value: "-"),
                  LabelValueRow(label: "Time", value: "-"),
                  LabelValueRow(label: "Description", value: "-"),
                ],
              ),
            ),
            LabelValueRow(
                label: "Employee Code",
                value: formatValue(widget.employee?.employeeCode)),
          ],
        ),
      ),
    );
  }
}
