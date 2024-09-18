import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class WorkProfileScreen extends StatefulWidget {
  const WorkProfileScreen({super.key});

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
                LabelValueRow(label: "Location", value: "-"),
                LabelValueRow(label: "Band", value: "-"),
                LabelValueRow(label: "Cost Centre", value: "-"),
                LabelValueRow(label: "Category", value: "-"),
                LabelValueRow(label: "Department", value: "-"),
                LabelValueRow(label: "Work Email", value: "-"),
                LabelValueRow(label: "Designation", value: "-"),
                LabelValueRow(label: "Joining Date", value: "-"),
                LabelValueRow(label: "Work Experience", value: "-"),
                LabelValueRow(label: "Reporting Manager", value: "-"),
                LabelValueRow(label: "Confirmation Date", value: "-"),
                LabelValueRow(label: "Retirement Age", value: "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
