import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedBackFuntion {

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    List<Map<String, dynamic>> questions = [];

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;

      if (userEmail == null) {
        print('User not logged in');
        return questions;
      }

      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userEmail)
          .get();

      if (!userDocSnapshot.exists) {
        print('User profile document does not exist');
        return questions;
      }

      final userProfile = userDocSnapshot.data();
      final employeeLevel = userProfile?['employee_level'];

      if (employeeLevel == null) {
        print('Employee level not found in profile');
        return questions;
      }

      final currentMonth = DateFormat('MMMM').format(DateTime.now());
      print('Fetching questions for month: $currentMonth, employee level: $employeeLevel');

      final feedbackDocSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userEmail)
          .collection('Feedback-Form')
          .doc(currentMonth)
          .get();

      if (!feedbackDocSnapshot.exists) {
        print('Feedback form document does not exist');
        return questions;
      }

      final feedbackData = feedbackDocSnapshot.data();

      if (feedbackData != null && feedbackData.containsKey('Questions')) {
        final allQuestions = List<Map<String, dynamic>>.from(feedbackData['Questions']);
        print('Total questions retrieved: ${allQuestions.length}');

        questions = allQuestions.where((question) {
          final assignedLevels = List<String>.from(question['Assigned_leavel_of_work'] ?? []);
          return assignedLevels.contains(employeeLevel);
        }).toList();

        print('Filtered questions for employee level $employeeLevel: ${questions.length}');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }

    return questions;
  }

  Future<void> submitForm(Map<String, dynamic> answers) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;
      //final userName = currentUser?.displayName;

      if (userEmail == null) {
        print('User not logged in');
        return;
      }

      final currentMonth = DateFormat('MMMM').format(DateTime.now());
      final currentYear = DateFormat('yyyy').format(DateTime.now());
      final surveyMonthYear = "$currentMonth $currentYear";

      final feedbackDocRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(userEmail)
          .collection('Feedback-Form')
          .doc(currentMonth);

      final feedbackDocSnapshot = await feedbackDocRef.get();

      if (!feedbackDocSnapshot.exists) {
        print("Feedback form document does not exist");
        return;
      }

      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userEmail)
          .get();

      if (!userDocSnapshot.exists) {
        print('User profile document does not exist');
        return;
      }

      final userProfile = userDocSnapshot.data();
      final employeeLevel = userProfile?['employee_level'];
      final userName = userProfile?['name'];
      final userdepart = userProfile?['department'];

      if (employeeLevel == null) {
        print('Employee level not found in profile');
        return;
      }

      List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(feedbackDocSnapshot.data()?['Questions'] ?? []);
      print("Initial Questions from Firestore: $questions");

      questions = questions.where((question) {
        final assignedLevels = List<String>.from(question['Assigned_leavel_of_work'] ?? []);
        return assignedLevels.contains(employeeLevel);
      }).toList();

      print("Filtered Questions: $questions");
      print("Answers provided: $answers");

      List<Map<String, dynamic>> responseArray = [];

      for (var question in questions) {
        final questionId = question['question_Id'];
        final questionType = question['question_type'];
        final targetDepartment = question['target_department'] ?? "General";
        final targetLevelOfWork = question['Target_level_of_work'] ?? "Unknown";

        List<Map<String, dynamic>> options = [];

        if (question.containsKey('Values ') || question.containsKey('Values')) {
          options = List<Map<String, dynamic>>.from(question['Values '] ?? question['Values']);
        }

        if (answers.containsKey(questionId)) {
          switch (questionType) {
            case 'Rating':
              question['achived_point'] = answers[questionId] ?? 0;
              break;

            case 'MCQ':
              final selectedOptionValue = answers[questionId];
              final selectedOption = options.firstWhere(
                    (option) => option['Value'] == selectedOptionValue,
                orElse: () => {},
              );

              if (selectedOption.isNotEmpty) {
                question['achived_point'] = selectedOption['Value'] ?? 0;
                question['selected_option_qid'] = selectedOption['Op_id'] ?? null;
              } else {
                print('Selected option not found for question ID: $questionId');
              }
              break;

            case 'Open':
              question['describeable_answer'] = answers[questionId] ?? '';
              question['achived_point'] = '';
              break;

          }
        }

        Map<String, dynamic> response = {
          "Feedback Survey Month & Year": surveyMonthYear,
          "Date of Response": DateTime.now(),
          "Response ID": "",
          "Employee Department": targetDepartment,
          "Question ID": questionId,
          "Question Type": questionType,
          "Question Description": question['question_name'] ?? "",
          "Answer in Description": questionType == "describable"
              ? question['describeable_answer']
              : null,
          "Selected Option ID": questionType == "multiChoose"
              ? options.firstWhere(
                (option) => option['Value'] == answers[questionId],
            orElse: () => {},
          )['Q_id']
              : null,
          "Selected Option Name": questionType == "multiChoose"
              ? options.firstWhere(
                (option) => option['Value'] == answers[questionId],
            orElse: () => {},
          )['question']
              : null,
          "Rating": questionType == "Rating" || questionType == "MCQ"
              ? question['achived_point']
              : null,
          "Total Rating of Question": question['total_points'] ?? 0,
          "Status": "Unverified",
          "Response Verified": null,
          "Response Verification Date": null,
          // "Response Verified By": null,
          "Response Checker Email ID": null,
          "Targted Level of Work": targetLevelOfWork,

        };

        responseArray.add(response);
      }

      await feedbackDocRef.update(
          {
            'Questions': questions,
            'Form Submitted' : true,
          }
      );
      print("Updated questions in Feedback-Form");

      final surveyCollection = FirebaseFirestore.instance.collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru').collection('FeedBack Survey Data');
      final querySnapshot = await surveyCollection.get();

      int nextResponseId = 1;

      if (querySnapshot.docs.isNotEmpty) {
        final allResponseIds = querySnapshot.docs.map((doc) {
          final responseId = doc['Response ID'] ?? '';
          final numericPart = int.tryParse(responseId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return numericPart;
        }).toList();

        final maxId = allResponseIds.isNotEmpty ? allResponseIds.reduce((a, b) => a > b ? a : b) : 0;
        nextResponseId = maxId + 1;
      }

      final newResponseId = "R-$nextResponseId";

      await surveyCollection.doc(newResponseId).set({
        'Response ID': newResponseId,
        'Response By': userName,
        'Response By Email': userEmail,
        'Submission Date': DateTime.now(),
        'TargetDepartment' : userdepart,
        'Responses': responseArray,
        'Response_Status': 'Pending',
      });

      print("Feedback survey data saved with ID: $newResponseId");
    } catch (e) {
      print("Error submitting feedback: $e");
    }
  }

  Future<void> releaseResult(String department) async {
    try {
      final feedbackDocs = await FirebaseFirestore.instance
          .collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru')
          .collection('FeedBack Survey Data')
          .where('TargetDepartment', isEqualTo: department)
          .get();

      final allVerified = feedbackDocs.docs.every((doc) => doc['Response_Status'] == "Verified");
      if (!allVerified) {
        throw Exception("Not all feedback documents are verified.");
      }

      final Map<String, Map<String, double>> levelScores = {};

      for (var doc in feedbackDocs.docs) {
        final responses = List<Map<String, dynamic>>.from(doc['Responses']);

        final verifiedResponses = responses.where((question) => question['Response_Status'] == 'Verified').toList();

        for (var question in verifiedResponses) {
          final levelOfWork = question['Targted Level of Work'] ?? "Unknown";
          final score = double.tryParse(question['Rating'].toString()) ?? 0.0;
          final outOf = double.tryParse(question['Total Rating of Question'].toString()) ?? 0.0;

          if (!levelScores.containsKey(levelOfWork)) {
            levelScores[levelOfWork] = {
              "Total Score": 0.0,
              "Total Out Of": 0.0,
            };
          }

          levelScores[levelOfWork]!["Total Score"] = (levelScores[levelOfWork]!["Total Score"] ?? 0.0) + score;
          levelScores[levelOfWork]!["Total Out Of"] = (levelScores[levelOfWork]!["Total Out Of"] ?? 0.0) + outOf;
        }
      }

      final List<Map<String, dynamic>> departmentScores = [];
      levelScores.forEach((level, data) {
        final totalScore = data["Total Score"]!;
        final totalOutOf = data["Total Out Of"]!;
        final percentage = totalOutOf > 0 ? (totalScore / totalOutOf) * 100 : 0.0;

        departmentScores.add({
          "Level of Designation": level,
          "Score": totalScore,
          "Score Out Of": totalOutOf,
          "Percentage": percentage,
        });
      });

      final departmentScoreCollection = FirebaseFirestore.instance.collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru').collection('FF department Vise score');
      final querySnapshot = await departmentScoreCollection.orderBy('Score ID', descending: true).limit(1).get();
      int nextScoreId = 1;

      if (querySnapshot.docs.isNotEmpty) {
        final lastScoreId = querySnapshot.docs.first['Score ID'];
        final lastIdNumber = int.tryParse(lastScoreId.split('-').last) ?? 0;
        nextScoreId = lastIdNumber + 1;
      }

      final departmentScoreId = "SL-$nextScoreId";

      final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());
      final currentDate = DateTime.now();

      final departmentResultData = {
        "Score ID": departmentScoreId,
        "FF Survey Month & Year": currentMonthYear,
        "Date of Scoring": currentDate,
        "Department Name": department,
        "Scores": departmentScores,
      };

      await departmentScoreCollection.doc(departmentScoreId).set(departmentResultData);

      final employeeScoreCollection = FirebaseFirestore.instance.collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru').collection('FF employees Wise score');
      final employeeScoreQuery = await employeeScoreCollection.orderBy('Score ID', descending: true).limit(1).get();
      int nextEmployeeScoreId = 1;

      if (employeeScoreQuery.docs.isNotEmpty) {
        final lastEmployeeScoreId = employeeScoreQuery.docs.first['Score ID'];
        final lastIdNumber = int.tryParse(lastEmployeeScoreId.split('-').last) ?? 0;
        nextEmployeeScoreId = lastIdNumber + 1;
      }

      for (var scoreData in departmentScores) {
        final level = scoreData["Level of Designation"];
        final percentage = scoreData["Percentage"];
        final Score = scoreData['Score'];
        final outOf = scoreData["Score Out Of"];

        final profilesSnapshot = await FirebaseFirestore.instance
            .collection('profiles')
            .where('department', isEqualTo: department)
            .where('employee_level', isEqualTo: level)
            .get();

        final employees = profilesSnapshot.docs.map((doc) {
          return {
            "email": doc.id,
            "level": doc['employee_level'] ?? "Unknown",
            "department": doc['department'],
          };
        }).toList();

        for (var employee in employees) {
          final employeeScoreId = "SE-$nextEmployeeScoreId";
          nextEmployeeScoreId++;

          final employeeResultData = {
            "Score ID": employeeScoreId,
            "FF Survey Month & Year": currentMonthYear,
            "Date of Scoring": currentDate,
            "Employee Email": employee['email'],
            "Employee Name" : employee['name'],
            "Level of Designation": level,
            "Department Name": department,
            "Employee Count at LOD (Department Specific)": employees.length,
            "Overall Score %": percentage,
            "totalScore" : Score,
            "TotalOutOf" : outOf
          };

          try {
            await employeeScoreCollection.doc(employeeScoreId).set(employeeResultData);
          } catch (e) {
            print("Error writing data for ${employee['email']}: $e");
          }
        }
      }

      print("Employee-wise scores released successfully.");
    } catch (e) {
      print("Error releasing result: $e");
      throw e;
    }
  }


}

// Future<void> releaseResult(String department) async {
//   try {
//     final feedbackDocs = await FirebaseFirestore.instance
//         .collection('FeedBack Survey Data')
//         .where('TargetDepartment', isEqualTo: department)
//         .get();
//
//     final allVerified = feedbackDocs.docs.every((doc) => doc['Response_Status'] == "Verified");
//     if (!allVerified) {
//       throw Exception("Not all feedback documents are verified.");
//     }
//
//     final Map<String, Map<String, double>> levelScores = {};
//
//     for (var doc in feedbackDocs.docs) {
//       final responses = List<Map<String, dynamic>>.from(doc['Responses']);
//       for (var question in responses) {
//         final levelOfWork = question['Targted Level of Work'] ?? "Unknown";
//         final score = double.tryParse(question['Rating'].toString()) ?? 0.0;
//         final outOf = double.tryParse(question['Total Rating of Question'].toString()) ?? 0.0;
//
//         if (!levelScores.containsKey(levelOfWork)) {
//           levelScores[levelOfWork] = {
//             "Total Score": 0.0,
//             "Total Out Of": 0.0,
//           };
//         }
//
//         levelScores[levelOfWork]!["Total Score"] = (levelScores[levelOfWork]!["Total Score"] ?? 0.0) + score;
//         levelScores[levelOfWork]!["Total Out Of"] = (levelScores[levelOfWork]!["Total Out Of"] ?? 0.0) + outOf;
//       }
//     }
//
//     final List<Map<String, dynamic>> departmentScores = [];
//     levelScores.forEach((level, data) {
//       final totalScore = data["Total Score"]!;
//       final totalOutOf = data["Total Out Of"]!;
//       final percentage = totalOutOf > 0 ? (totalScore / totalOutOf) * 100 : 0.0;
//
//       departmentScores.add({
//         "Level of Designation": level,
//         "Score": totalScore,
//         "Score Out Of": totalOutOf,
//         "Percentage": percentage,
//       });
//     });
//
//     final departmentScoreCollection = FirebaseFirestore.instance.collection('department Vise score');
//     final querySnapshot = await departmentScoreCollection.orderBy('Score ID', descending: true).limit(1).get();
//     int nextScoreId = 1;
//
//     if (querySnapshot.docs.isNotEmpty) {
//       final lastScoreId = querySnapshot.docs.first['Score ID'];
//       final lastIdNumber = int.tryParse(lastScoreId.split('-').last) ?? 0;
//       nextScoreId = lastIdNumber + 1;
//     }
//
//     final departmentScoreId = "SL-$nextScoreId";
//
//     final currentMonthYear = DateFormat('MMMM yyyy').format(DateTime.now());
//     final currentDate = DateTime.now();
//
//     final departmentResultData = {
//       "Score ID": departmentScoreId,
//       "FF Survey Month & Year": currentMonthYear,
//       "Date of Scoring": currentDate,
//       "Department Name": department,
//       "Scores": departmentScores,
//     };
//
//
//     await departmentScoreCollection.doc(departmentScoreId).set(departmentResultData);
//
//     final employeeScoreCollection = FirebaseFirestore.instance.collection('employees Wise score');
//     final employeeScoreQuery = await employeeScoreCollection.orderBy('Score ID', descending: true).limit(1).get();
//     int nextEmployeeScoreId = 1;
//
//     if (employeeScoreQuery.docs.isNotEmpty) {
//       final lastEmployeeScoreId = employeeScoreQuery.docs.first['Score ID'];
//       final lastIdNumber = int.tryParse(lastEmployeeScoreId.split('-').last) ?? 0;
//       nextEmployeeScoreId = lastIdNumber + 1;
//     }
//
//     for (var scoreData in departmentScores) {
//       final level = scoreData["Level of Designation"];
//       final percentage = scoreData["Percentage"];
//       final Score = scoreData['Score'];
//       final outOf = scoreData["Score Out Of"];
//
//       print('department $department and $level');
//
//       final profilesSnapshot = await FirebaseFirestore.instance
//           .collection('profiles')
//           .where('department', isEqualTo: department)
//           .where('employee_level', isEqualTo: level)
//           .get();
//
//       print("Profiles fetched count ${profilesSnapshot.docs.length}");
//
//
//       final employees = profilesSnapshot.docs.map((doc) {
//         return {
//           "email": doc.id,
//           "level": doc['employee_level'] ?? "Unknown",
//           "department": doc['department'],
//         };
//       }).toList();
//
//       print("Profiles fetched for $level: ${employees.length} employees.");
//
//       for (var employee in employees) {
//         final employeeScoreId = "SE-$nextEmployeeScoreId";
//         nextEmployeeScoreId++;
//
//         final employeeResultData = {
//           "Score ID": employeeScoreId,
//           "FF Survey Month & Year": currentMonthYear,
//           "Date of Scoring": currentDate,
//           "Employee Email": employee['email'],
//           "Employee Name" : employee['name'],
//           "Level of Designation": level,
//           "Department Name": department,
//           "Employee Count at LOD (Department Specific)": employees.length,
//           "Overall Score %": percentage,
//           "totalScore" : Score,
//           "TotalOutOf" : outOf
//         };
//
//         try {
//           await employeeScoreCollection.doc(employeeScoreId).set(employeeResultData);
//           print("Data written for ${employee['email']} with ID: $employeeScoreId");
//         } catch (e) {
//           print("Error writing data for ${employee['email']}: $e");
//         }
//       }
//     }
//
//     print("Employee-wise scores released successfully.");
//   } catch (e) {
//     print("Error releasing result: $e");
//     throw e;
//   }
// }

