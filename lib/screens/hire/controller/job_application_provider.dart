import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/animation_check_widget.dart';

class JobApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  List<String> skills = [];
  String selectedJobType = "Full-time";
  String selectedExperienceLevel = "Fresher";
  String selectedEmploymentType = "Permanent";
  String selectedShiftSchedule = "Day shift";

  void addSkill(String skill) {
    if (skill.isNotEmpty) {
      skills.add(skill);
      notifyListeners();
    }
  }


  void removeSkill(String skill) {
    skills.remove(skill);
    notifyListeners();
  }

  Future<void> submitJob({
    required String jobTitle,
    required String companyName,
    required String location,
    required String jobDescription,
    required String salary,
    required BuildContext context,
    required VoidCallback onFormClear,
  }) async {
    if (jobTitle.isEmpty ||
        companyName.isEmpty ||
        location.isEmpty ||
        skills.isEmpty ||
        jobDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and add skills.')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Fetch current job count
      DocumentReference jobIdCounterRef =
      _firestore.collection('hiring').doc('countJobId');
      DocumentSnapshot snapshot = await jobIdCounterRef.get();

      int jobCount = 1;
      if (snapshot.exists) {
        jobCount = snapshot['count'] + 1;
      }

      // Create custom job ID
      String customJobId = 'Hr-$jobCount';

      // Add job entry
      await _firestore.collection('hiring').doc(customJobId).set({
        'jobTitle': jobTitle,
        'companyName': companyName,
        'location': location,
        'skills': skills,
        'salary': salary,
        'jobType': selectedJobType,
        'experienceLevel': selectedExperienceLevel,
        'employmentType': selectedEmploymentType,
        'shiftSchedule': selectedShiftSchedule,
        'jobDescription': jobDescription,
        'isPublished': false,
        'publishTime': null,
        'closeHiring': false,
        'closeTime': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update job count
      await jobIdCounterRef.set({'count': jobCount});

      isLoading = false;
      notifyListeners();

      // Show success dialog
      showSuccessPopup(context);
      onFormClear();

    } catch (e) {
      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void clearSkills() {
    skills.clear();

    notifyListeners();
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            AnimatedCheck(),
            SizedBox(height: 16),
            Text(
              'Submission Successful!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('OK'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
