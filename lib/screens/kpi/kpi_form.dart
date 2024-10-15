import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class KpiForm extends StatefulWidget {
  const KpiForm({super.key});

  @override
  State<KpiForm> createState() => _KpiFormState();
}

class _KpiFormState extends State<KpiForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            color: AppColors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Management',
                        // controller: _colleagueController,
                      ),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      child: CustomTextField(
                        labelText: 'HR',
                        // controller: _companyReviewController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(
                      child: CustomTextField(
                        labelText: 'Manager',
                        // controller: _colleagueController,
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 35,
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        // _submitForm();
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
