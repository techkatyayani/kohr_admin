import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class KpiFunctions {


  Future<void> copy360FormToProfiles() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference sourceCollection = firestore
        .collection('profiles')
        .doc('praveen.dev@katyayaniorganics.com')
        .collection('Feedback-Form');

    CollectionReference targetCollection = firestore
        .collection('profiles')
        .doc('vaibhaw.dev@katyayaniorganics.com')
        .collection('Feedback-Form');



    try {
      QuerySnapshot sourceDocs = await sourceCollection.get();

      for (var doc in sourceDocs.docs) {
        await targetCollection.doc(doc.id).set(doc.data() as Map<String, dynamic>);
      }

      print("Data copied successfully from 360-Form to Profiles!");
    } catch (e) {
      print("Error copying data: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    List<Map<String, dynamic>> questions = [];

    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email;


    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    print('currentMonth  $currentMonth');
    print('currentMont  : $currentMonth and currentUser : $currentUser');

    final userDoc = FirebaseFirestore.instance
        .collection('profiles')
        .doc(userEmail)
        .collection('360-Form')
        .doc(currentMonth);

    final docSnapshot = await userDoc.get();

    print('docSnapshot ${docSnapshot.data()}');

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      print('Data retrieved: ${data.toString()}');
      if (data != null && data.containsKey('Questions')) {
        questions = List<Map<String, dynamic>>.from(data['Questions']);
        print('Questions extracted: ${questions.toString()}');
      }
    } else {
      print('Document does not exist');
    }

    return questions;
  }

  Future<List<String>> fetchDepartments() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('employees').get();
      final departments = snapshot.docs.map((doc) => doc.id).toList();
      return departments;
    } catch (e) {
      print("Error fetching departments: $e");
      return [];
    }
  }

  Future<List<Map<String, String>>> fetchMembers(String? department) async {
    if (department == null) {
      return [];
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('employees').doc(department).get();
      final data = snapshot.data();

      if (data == null || !data.containsKey('Members')) {
        print("No members found for department: $department");
        return [];
      }

      final members = (data['Members'] as List<dynamic>).map((member) {
        final memberMap = member as Map<String, dynamic>;
        return {
          'Name': memberMap['Name'] as String,
          'Email': memberMap['Email'] as String,
        };
      }).toList();


      return members;
    } catch (e) {
      print("Error fetching members for department $department: $e");
      return [];
    }
  }

  Future<void> saveToFirestore(Map<String, dynamic> data) async {
    try {

      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;

      final currentMonth = DateFormat('MMMM').format(DateTime.now());

      final userDoc = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userEmail)
          .collection('360-Form')
          .doc(currentMonth);

      print('data of submition ${data.toString()}');

      await userDoc.update(data);
      print("Data saved successfully");
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  Future<void> copyFirestoreDocToCurrentMonth() async {

    final originalDocRef = FirebaseFirestore.instance
        .collection('Masterdata')
        .doc('collections')
        .collection('Departments')
        .doc('Cex6oQb80xsM17BYwoJn')
        .collection('Feedback-Form')
        .doc('2024-11');


    String currentMonth = DateFormat('MMMM').format(DateTime.now());
    final newDocRef = FirebaseFirestore.instance
        .collection('profiles')
        .doc('praveen.dev@katyayaniorganics.com')
        .collection('Feedback-Form').doc(currentMonth);

    try {
      final originalDocSnapshot = await originalDocRef.get();
      if (originalDocSnapshot.exists) {
        final data = originalDocSnapshot.data();

        await newDocRef.set(data!);
        print("Document copied successfully to the current month: $currentMonth");
      } else {
        print("Original document does not exist.");
      }
    } catch (e) {
      print("Error copying document: $e");
    }
  }

  void calculateScore(Map<String, dynamic> question, List<Map<String, dynamic>> scoreAchieved, String responseId) {
    final verificationStatus = question['verification_status'] ?? 'Unverified';
    if (verificationStatus == 'Verified') {
      final achievedPoints = double.tryParse(question['achived_point']?.toString() ?? '0') ?? 0.0;
      final totalPoints = double.tryParse(question['total_points']?.toString() ?? '10') ?? 10.0;

      final l3Weightage = (double.tryParse(question['L3_Weightage']?.toString() ?? '0') ?? 0) / 100;
      final l2Weightage = (double.tryParse(question['L2_Weightage']?.toString() ?? '0') ?? 0) / 100;

      final l3Employees = List<String>.from(question['L3 employee'] ?? []);
      final l2Employees = List<String>.from(question['L2 employee'] ?? []);
      final questionType = question['question_type'] ?? '';
      final question_Id = question['question_Id'] ?? '';

      if (questionType == 'Rating Question') {
        for (var email in l3Employees) {
          final l3AchievedPoints = achievedPoints * l3Weightage;
          scoreAchieved.add({
            'email': email,
            'score': l3AchievedPoints,
            'out_of': totalPoints * l3Weightage,
            'score_origin': 'L3',
            'Q_id' : question_Id,
            'Response_id' : responseId
          });
        }

        for (var email in l2Employees) {
          double l2AchievedPoints = (l2Employees.length == 2)
              ? (achievedPoints * l2Weightage) / 2
              : achievedPoints * l2Weightage;

          scoreAchieved.add({
            'email': email,
            'score': l2AchievedPoints,
            'out_of': (l2Employees.length == 2) ? totalPoints * l2Weightage / 2 : totalPoints * l2Weightage,
            'score_origin': 'L2',
            'Q_id' : question_Id,
            'Response_id' : responseId
          });
        }
      }
    }
  }

  void calculateEmployeeRatingScore(Map<String, dynamic> rating, List<Map<String, dynamic>> scoreAchieved, String responseId) {
    final employeeVerificationStatus = rating['verification_status'] ?? 'Unverified';
    if (employeeVerificationStatus == 'Verified') {
      final memberEmail = rating['MemberEmail'] as String? ?? '';
      final question_Id = rating['question_Id'] ?? '';
      final ratingScore = double.tryParse(rating['Rating']?.toString() ?? '0') ?? 0.0;
      scoreAchieved.add({
        'email': memberEmail,
        'score': ratingScore,
        'out_of': 10.0,
        'score_origin': 'directScore',
        'Q_id' : question_Id,
        'Response_id' : responseId
      });
    }
  }

  Future<void> storeScoresInRelevantProfiles(List<Map<String, dynamic>> scoreAchieved) async {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());

    Map<String, List<Map<String, dynamic>>> scoresByEmail = {};
    for (var score in scoreAchieved) {
      final email = score['email'];
      if (!scoresByEmail.containsKey(email)) {
        scoresByEmail[email] = [];
      }
      scoresByEmail[email]!.add(score);
    }

    for (var entry in scoresByEmail.entries) {
      final email = entry.key;
      final newScores = entry.value;

      final profileDoc = FirebaseFirestore.instance.collection('profiles').doc(email);
      final monthlyScoreDoc = profileDoc.collection('360').doc('nu63wFPHMPW0GGpQnRR1').collection('360_Monthly_Score').doc(currentMonth);

      final existingData = await monthlyScoreDoc.get();
      List<Map<String, dynamic>> existingScores = [];

      if (existingData.exists && existingData.data() != null) {
        existingScores = List<Map<String, dynamic>>.from(existingData.data()!['My_scores'] ?? []);
      }

      final updatedScores = List<Map<String, dynamic>>.from(existingScores)..addAll(newScores);

      double totalAchieved = 0.0;
      double totalOutOf = 0.0;
      double l3TotalScore = 0.0;
      double l2TotalScore = 0.0;
      double l2TotalOutof = 0.0;
      double l3TotalOutof = 0.0;
      double totalDirectOutof = 0.0;
      double scoreFromDirectReview = 0.0;

      for (var score in updatedScores) {
        final achievedScore = score['score'] ?? 0.0;
        final outOfScore = score['out_of'] ?? 0.0;
        final scoreOrigin = score['score_origin'];

        totalAchieved += achievedScore;
        totalOutOf += outOfScore;

        if (scoreOrigin == 'L3') {
          l3TotalScore += achievedScore;
          l3TotalOutof += outOfScore;
        } else if (scoreOrigin == 'L2') {
          l2TotalScore += achievedScore;
          l2TotalOutof += outOfScore;
        } else if (scoreOrigin == 'directScore') {
          scoreFromDirectReview += achievedScore;
          totalDirectOutof += outOfScore;
        }
      }

      double percentage = (totalOutOf > 0) ? (totalAchieved / totalOutOf) * 100 : 0.0;

      await monthlyScoreDoc.set({
        'My_scores': updatedScores,
        'total_achieved_score': totalAchieved,
        'total_out_of_score': totalOutOf,
        'percentage': percentage,
        'L3_total_score': l3TotalScore,
        'l3TotalOutof' : l3TotalOutof,
        'L2_total_score': l2TotalScore,
        'l2TotalOutof' : l2TotalOutof,
        'ScoreFromDirectReview': scoreFromDirectReview,
        'totalDirectOutof' : totalDirectOutof
      });
    }
  }

  void showSuccessDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Thank you for your Feedback...",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 500,
                child: Lottie.asset(
                  'Assests/form-submitted.json',
                ),
              ),
              //const SizedBox(height: 20),
             // Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                 // Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showFailureDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Failure"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

}