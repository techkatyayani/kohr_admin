import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Controller/FirebaseFuntions.dart';


class QuestionReviewScreen extends StatefulWidget {
  final String responseId;
  const QuestionReviewScreen({super.key, required this.responseId});

  @override
  _QuestionReviewScreenState createState() => _QuestionReviewScreenState();
}

class _QuestionReviewScreenState extends State<QuestionReviewScreen> {
  List<Map<String, dynamic>> questions = [];
  List<bool> selectedQuestions = [];
  bool selectAll = false;

  KpiFunctions _functions = KpiFunctions();

  @override
  void initState() {
    super.initState();
    print('docID : ${widget.responseId}');
    fetchQuestionsforverification();
  }


  Future<void> fetchQuestionsforverification() async {
    final surveyDoc = FirebaseFirestore.instance
        .collection('360').doc('nu63wFPHMPW0GGpQnRR1')
        .collection('360 Survey Data')
        .doc(widget.responseId);

    final snapshot = await surveyDoc.get();
    if (snapshot.exists) {
      final surveyData = snapshot.data();
      setState(() {
        questions = List<Map<String, dynamic>>.from(surveyData?['Questions'] ?? []);
        selectedQuestions = List<bool>.filled(questions.length, false);
      });
    } else {
      print("Document does not exist in 360 Survey Data collection.");
    }
  }

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (int i = 0; i < selectedQuestions.length; i++) {
        selectedQuestions[i] = selectAll;
      }
    });
  }

  void verifySelected() async {
    List<Map<String, dynamic>> scoreAchieved = [];
    for (int i = 0; i < questions.length; i++) {
      if (selectedQuestions[i]) {
        questions[i]['verification_status'] = 'Verified';

        if (questions[i]['question_type'] == 'Employee Rating') {
          List<Map<String, dynamic>> employeeRatings = List<Map<String, dynamic>>.from(questions[i]['EmployeeRating'] ?? []);

          for (int j = 0; j < employeeRatings.length; j++) {
            if (employeeRatings[j]['verification_status'] == 'Verified') {
              _functions.calculateEmployeeRatingScore(employeeRatings[j], scoreAchieved, widget.responseId);
            }
          }

          questions[i]['EmployeeRating'] = employeeRatings;
        } else {
          _functions.calculateScore(questions[i], scoreAchieved, widget.responseId);
        }
      } else {
        questions[i]['verification_status'] = 'Unverified';
      }
    }

    final surveyDoc = FirebaseFirestore.instance.collection('360').doc('nu63wFPHMPW0GGpQnRR1').collection('360 Survey Data').doc(widget.responseId);
    await surveyDoc.update({
      'Questions': questions,
      'verification_status' : 'Verified'
    });

    await _functions.storeScoresInRelevantProfiles(scoreAchieved);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Responses"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(selectAll ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: toggleSelectAll,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final questionText = "${question['question_Id']} - ${question['question_name']}";
          final answer = question['achived_point'] ?? question['description'] ?? '';
          final employeeRatings = List<Map<String, dynamic>>.from(question['EmployeeRating'] ?? []);

          bool isEmployeeRating = question['question_type'] == 'Employee Rating';

          final isVerified = question['verification_status'] == 'Verified';

          return Column(
            children: [
              ListTile(
                title: Text(questionText),
                subtitle: Text("Answer: $answer"),
                trailing: Switch(
                  value: isVerified,
                  onChanged: (value) {
                    setState(() {
                      question['verification_status'] = value ? 'Verified' : 'Unverified';
                      selectedQuestions[index] = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
              if (isEmployeeRating && isVerified)
                ...employeeRatings.map((employeeRating) {
                  final memberName = employeeRating['MemberEmail'];
                  final rating = employeeRating['Rating'] ?? 0;

                  final employeeIsVerified = employeeRating['verification_status'] == 'Verified';

                  return ListTile(
                    title: Text("Employee: $memberName"),
                    subtitle: Text("Rating: $rating"),
                    trailing: Switch(
                      value: employeeIsVerified,
                      onChanged: (value) {
                        setState(() {
                          employeeRating['verification_status'] = value ? 'Verified' : 'Unverified';
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: verifySelected,
          child: const Text("Verify Now"),
        ),
      ),
    );
  }
}

