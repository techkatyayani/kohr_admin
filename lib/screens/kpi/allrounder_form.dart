import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class AllRounderForm extends StatefulWidget {
  const AllRounderForm({super.key});

  @override
  State<AllRounderForm> createState() => _AllRounderFormState();
}

class _AllRounderFormState extends State<AllRounderForm> {
  final _colleagueController = TextEditingController();
  final _companyReviewController = TextEditingController();

  Future<void> submitForm() async {}

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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Colleague',
                      controller: _colleagueController,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Company Review',
                      controller: _companyReviewController,
                    ),
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
      ),
    );
  }
}
