import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FormProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final experienceController = TextEditingController();
  final contactController = TextEditingController();
  final expectedSalaryController = TextEditingController();

  String? selectedGraduation;

  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      // Handle form submission
      debugPrint("Form submitted with data:");
      debugPrint("First Name: ${firstNameController.text}");
      debugPrint("Last Name: ${lastNameController.text}");
      debugPrint("Email: ${emailController.text}");
      debugPrint("Address: ${addressController.text}");
      debugPrint("Graduation: $selectedGraduation");
      debugPrint("Experience: ${experienceController.text}");
      debugPrint("Contact: ${contactController.text}");
      debugPrint("Expected Salary: ${expectedSalaryController.text}");
    } else {
      debugPrint("Form validation failed");
    }
  }
}