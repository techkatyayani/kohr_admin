import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import 'verification.dart';

class SurveyDataScreen extends StatefulWidget {
  @override
  _SurveyDataScreenState createState() => _SurveyDataScreenState();
}

class _SurveyDataScreenState extends State<SurveyDataScreen> {
  List<String> uniqueDepartments = [];
  String? selectedDepartment;
  List<DocumentSnapshot> departmentResponses = [];

  @override
  void initState() {
    super.initState();
    fetchUniqueDepartments();
  }

  Future<void> fetchUniqueDepartments() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('360')
          .doc('nu63wFPHMPW0GGpQnRR1')
          .collection('360 Survey Data')
          .get();

      print('all docs ${querySnapshot.docs.length}');

      final allDepartments = querySnapshot.docs
          .map((doc) => doc['related_department'] as String)
          .toSet()
          .toList();

      setState(() {
        uniqueDepartments = allDepartments;
      });
    } catch (e) {
      print('Error fetching unique departments: $e');
    }
  }

  Future<void> fetchDepartmentData(String department) async {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    final currentYear = DateFormat('yyyy').format(DateTime.now());

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('360')
          .doc('nu63wFPHMPW0GGpQnRR1')
          .collection('360 Survey Data')
          .where('related_department', isEqualTo: department)
          .where('survey_month', isEqualTo: '$currentMonth $currentYear')
          .get();

      setState(() {
        departmentResponses = querySnapshot.docs;
        selectedDepartment = department;
      });
    } catch (e) {
      print('Error fetching department data: $e');
    }
  }

  void goToQuestionReviewScreen(String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionReviewScreen(responseId: docId),
      ),
    );
  }

  Future<void> releaseResults() async {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    final selectedSurveyMonth = currentMonth;

    final verifiedResponses = departmentResponses.where((doc) =>
        doc['verification_status'] == 'Verified' &&
        doc['Response_by_email'] != null);

    int docCounter = 1;

    for (var document in verifiedResponses) {
      String email = document['Response_by_email'];

      try {
        DocumentSnapshot profileDoc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(email)
            .collection('360_Monthly_Score')
            .doc(selectedSurveyMonth)
            .get();

        if (profileDoc.exists) {
          var data = profileDoc.data() as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection('360')
              .doc('nu63wFPHMPW0GGpQnRR1')
              .collection('360 Survey Score')
              .doc('S-$docCounter')
              .set({
            'email': email,
            'survey_month': selectedSurveyMonth,
            'total_achieved_score': data['total_achieved_score'] ?? 0.0,
            'total_out_of': data['total_out_of_score'] ?? 0.0,
            'percentage': data['percentage'] ?? 0.0,
            'related_department': selectedDepartment,
            'L3_Score': data['L3_total_score'] ?? 0.0,
            'L2_Score': data['L2_total_score'] ?? 0.0,
            'l3TotalOutof': data['l3TotalOutof'] ?? 0.0,
            'L2_total_score': data['l2TotalOutof'] ?? 0.0,
            'totalDirectOutof': data['ScoreFromDirectReview'] ?? 0.0,
            'ScoreFromDirectReview': data['ScoreFromDirectReview'] ?? 0.0,
          });

          print('Stored successfully: S-$docCounter for $email');
          docCounter++;
        } else {
          print('No score data found for $email in $selectedSurveyMonth');
        }
      } catch (e) {
        print('Failed to store data for $email: $e');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Results released successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const Text(
          "360 Reviews",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 20),

            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueDepartments.length,
                  itemBuilder: (context, index) {
                    String department = uniqueDepartments[index];
                    bool isExpanded = department == selectedDepartment;

                    return ExpansionTile(
                      title: Text(department),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (bool expanded) {
                        if (expanded) {
                          fetchDepartmentData(department);
                        } else {
                          setState(() {
                            selectedDepartment = null;
                            departmentResponses = [];
                          });
                        }
                      },
                      children: [
                        if (isExpanded)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: departmentResponses.length,
                            itemBuilder: (context, index) {
                              var document = departmentResponses[index];
                              String responseByEmail =
                              document['Response_by_email'];
                              String verificationStatus =
                              document['verification_status'];

                              return ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(responseByEmail),
                                    if (verificationStatus == 'Verified')
                                      Icon(Icons.check, color: Colors.green),
                                  ],
                                ),
                                onTap: () {
                                  goToQuestionReviewScreen(document.id);
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),

            Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: releaseResults,
            child: const Text("Release Results"),
          ),
        )
      ],
    );
  }
}
