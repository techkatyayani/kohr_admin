import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dashboardScreens/MainDashboardScreens/widgets/animation_check_widget.dart';

class JobApplicationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  List<String> skills = [];
  String selectedJobType = "Full-time";
  String selectedExperienceYears= "0";
  String selectedExperienceMonths='0';
  String selectedEmploymentType = "Permanent";
  String selectedShiftSchedule = "Day shift";
  String selectedDepartment ="Development Department";
  String selectedRecruiter = 'Aditi Rajput';
  String selectedHiringEmployees= '1-5';




  TextEditingController experienceController = TextEditingController();
  String selectedExperience = '0';  // Store the number of experience (e.g., '2')
  String selectedExperienceUnit = 'Years';  // 'Years' or 'Months'
  String get experienceLevel {
    return '$selectedExperience ${selectedExperienceUnit}';
  }


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
      _firestore.collection('Masterdata').doc('countJobId');
      DocumentSnapshot snapshot = await jobIdCounterRef.get();

      int jobCount = 1;
      if (snapshot.exists) {
        jobCount = snapshot['count'] + 1;
      }

      // Create custom job ID
      String customJobId = 'Hr-$jobCount';
     // DateTime parsedDate = DateFormat('MM/dd/yyyy hh:mm a').parse(formValidateDate);



      // Add job entry
      await _firestore.collection('hiring').doc(customJobId).set({
        'futureHiring':true,
        'jobId':customJobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'location': location,
        'skills': skills,
        'salary': salary,
        'jobType': selectedJobType,
        'experienceLevel': experienceLevel,
        'employmentType': selectedEmploymentType,
        'shiftSchedule': selectedShiftSchedule,
        'jobDescription': jobDescription,
        'department':selectedDepartment,
        'recruiter':selectedRecruiter,
        'requiredEmployees':selectedHiringEmployees,
        'isPublished': false,
        'publishTime': null,
        'closeHiring': false,
        'closeTime': null,
        'createdAt': FieldValue.serverTimestamp(),
        //'formValidateDate':  Timestamp.fromDate(parsedDate),
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
