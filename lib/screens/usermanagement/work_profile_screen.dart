import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/models/employee_model.dart';
import 'package:Kohr_Admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:Kohr_Admin/screens/usermanagement/widgets/label_row.dart';
import 'package:flutter/material.dart';

class WorkProfileScreen extends StatefulWidget {
  final Employee? employee;
  const WorkProfileScreen({super.key, this.employee});

  @override
  State<WorkProfileScreen> createState() => _WorkProfileScreenState();
}

class _WorkProfileScreenState extends State<WorkProfileScreen> {
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
              "Work Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Column(
              children: [
                LabelValueRow(
                    label: "Location",
                    value: formatValue(widget.employee?.location)),
                LabelValueRow(
                    label: "Department",
                    value: formatValue(widget.employee?.department)),
                LabelValueRow(
                    label: "Work Email",
                    value: formatValue(widget.employee?.workEmail)),
                LabelValueRow(
                    label: "Designation",
                    value: formatValue(widget.employee?.employeeType)),
                LabelValueRow(
                    label: "Joining Date",
                    value: formatValue(widget.employee?.joiningDate)),
                LabelValueRow(
                    label: "Work Experience",
                    value: formatValue(widget.employee?.workExperience)),
                LabelValueRow(
                    label: "Reporting Manager",
                    value: formatValue(widget.employee?.reportingManager)),
                LabelValueRow(
                    label: "Confirmation Date",
                    value: formatValue(widget.employee?.confirmationDate)),
                LabelValueRow(
                    label: "Retirement Age",
                    value: formatValue(widget.employee?.retirementAge)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
