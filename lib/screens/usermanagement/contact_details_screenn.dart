import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class ContactDetailsScreenn extends StatefulWidget {
  final Employee? employee;
  const ContactDetailsScreenn({super.key, this.employee});

  @override
  State<ContactDetailsScreenn> createState() => _ContactDetailsScreennState();
}

class _ContactDetailsScreennState extends State<ContactDetailsScreenn> {
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
              "Contact Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            LabelValueRow(
                label: "Personal Email",
                value: formatValue(widget.employee?.email)),
          ],
        ),
      ),
    );
  }
}
