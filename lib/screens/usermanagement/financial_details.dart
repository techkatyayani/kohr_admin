import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/models/employee_model.dart';
import 'package:Kohr_Admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:Kohr_Admin/screens/usermanagement/widgets/label_row.dart';
import 'package:flutter/material.dart';

class FinancialDetailsScreen extends StatefulWidget {
  final Employee? employee;
  const FinancialDetailsScreen({super.key, this.employee});

  @override
  State<FinancialDetailsScreen> createState() => _FinancialDetailsScreenState();
}

class _FinancialDetailsScreenState extends State<FinancialDetailsScreen> {
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
            const Text(
              "Financial Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Column(
              children: [
                LabelValueRow(
                    label: "Bank Name",
                    value: formatValue(widget.employee?.bankName)),
                LabelValueRow(
                    label: "Bank Account NUmber",
                    value: formatValue(widget.employee?.bankAccountNumber)),
                LabelValueRow(
                    label: "IFSC Code",
                    value: formatValue(widget.employee?.ifscCode)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
