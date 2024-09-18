import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/screens/usermanagement/widgets/label_row.dart';

class FinancialDetailsScreen extends StatefulWidget {
  const FinancialDetailsScreen({super.key});

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
            Text(
              "Financial Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Column(
              children: [
                LabelValueRow(label: "PF Number", value: "-"),
                LabelValueRow(label: "UAN Number", value: "-"),
                LabelValueRow(label: "Aadhar Number", value: "-"),
                LabelValueRow(label: "EPS Contribution", value: "-"),
                LabelValueRow(label: "ESIC Number", value: "-"),
                LabelValueRow(label: "Company Bank Number", value: "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
