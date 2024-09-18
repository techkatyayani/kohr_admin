import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

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
            Text(
              "Personal Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            LabelValueRow(label: "First Name", value: "Saksham"),
            LabelValueRow(label: "Middle Name", value: "-"),
            LabelValueRow(label: "Last Name", value: "Gupta"),
            LabelValueRow(label: "Gender", value: "-"),
            LabelValueRow(label: "Birthday", value: "-"),
            LabelValueRow(label: "Father's Name", value: "-"),
            LabelValueRow(label: "Age", value: "-"),
          ],
        ),
      ),
    );
  }
}
