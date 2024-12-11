// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../constants.dart';
// import 'verification.dart';
//
// class SurveyDataScreen extends StatefulWidget {
//   @override
//   _SurveyDataScreenState createState() => _SurveyDataScreenState();
// }
//
// class _SurveyDataScreenState extends State<SurveyDataScreen> {
//   List<String> uniqueDepartments = [];
//   String? selectedDepartment;
//   List<DocumentSnapshot> departmentResponses = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUniqueDepartments();
//   }
//
//   Future<void> fetchUniqueDepartments() async {
//     try {
//       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('360')
//           .doc('nu63wFPHMPW0GGpQnRR1')
//           .collection('360 Survey Data')
//           .get();
//
//       print('all docs ${querySnapshot.docs.length}');
//
//       final allDepartments = querySnapshot.docs
//           .map((doc) => doc['related_department'] as String)
//           .toSet()
//           .toList();
//
//       setState(() {
//         uniqueDepartments = allDepartments;
//       });
//     } catch (e) {
//       print('Error fetching unique departments: $e');
//     }
//   }
//
//   Future<void> fetchDepartmentData(String department) async {
//     final currentMonth = DateFormat('MMMM').format(DateTime.now());
//     final currentYear = DateFormat('yyyy').format(DateTime.now());
//
//     try {
//       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('360')
//           .doc('nu63wFPHMPW0GGpQnRR1')
//           .collection('360 Survey Data')
//           .where('related_department', isEqualTo: department)
//           .where('survey_month', isEqualTo: '$currentMonth $currentYear')
//           .get();
//
//       setState(() {
//         departmentResponses = querySnapshot.docs;
//         selectedDepartment = department;
//       });
//     } catch (e) {
//       print('Error fetching department data: $e');
//     }
//   }
//
//   void goToQuestionReviewScreen(String docId) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QuestionReviewScreen(responseId: docId),
//       ),
//     );
//   }
//
//   Future<void> releaseResults() async {
//     final currentMonth = DateFormat('MMMM').format(DateTime.now());
//     final selectedSurveyMonth = currentMonth;
//
//     final verifiedResponses = departmentResponses.where((doc) =>
//         doc['verification_status'] == 'Verified' &&
//         doc['Response_by_email'] != null);
//
//     int docCounter = 1;
//
//     for (var document in verifiedResponses) {
//       String email = document['Response_by_email'];
//
//       try {
//         DocumentSnapshot profileDoc = await FirebaseFirestore.instance
//             .collection('profiles')
//             .doc(email)
//             .collection('360_Monthly_Score')
//             .doc(selectedSurveyMonth)
//             .get();
//
//         if (profileDoc.exists) {
//           var data = profileDoc.data() as Map<String, dynamic>;
//
//           await FirebaseFirestore.instance
//               .collection('360')
//               .doc('nu63wFPHMPW0GGpQnRR1')
//               .collection('360 Survey Score')
//               .doc('S-$docCounter')
//               .set({
//             'email': email,
//             'survey_month': selectedSurveyMonth,
//             'total_achieved_score': data['total_achieved_score'] ?? 0.0,
//             'total_out_of': data['total_out_of_score'] ?? 0.0,
//             'percentage': data['percentage'] ?? 0.0,
//             'related_department': selectedDepartment,
//             'L3_Score': data['L3_total_score'] ?? 0.0,
//             'L2_Score': data['L2_total_score'] ?? 0.0,
//             'l3TotalOutof': data['l3TotalOutof'] ?? 0.0,
//             'L2_total_score': data['l2TotalOutof'] ?? 0.0,
//             'totalDirectOutof': data['ScoreFromDirectReview'] ?? 0.0,
//             'ScoreFromDirectReview': data['ScoreFromDirectReview'] ?? 0.0,
//           });
//
//           print('Stored successfully: S-$docCounter for $email');
//           docCounter++;
//         } else {
//           print('No score data found for $email in $selectedSurveyMonth');
//         }
//       } catch (e) {
//         print('Failed to store data for $email: $e');
//       }
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Results released successfully!')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//
//         const Text(
//           "360 Reviews",
//           style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryBlue),
//         ),
//         const SizedBox(height: 20),
//
//             Column(
//               children: [
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: uniqueDepartments.length,
//                   itemBuilder: (context, index) {
//                     String department = uniqueDepartments[index];
//                     bool isExpanded = department == selectedDepartment;
//
//                     return ExpansionTile(
//                       title: Text(department),
//                       initiallyExpanded: isExpanded,
//                       onExpansionChanged: (bool expanded) {
//                         if (expanded) {
//                           fetchDepartmentData(department);
//                         } else {
//                           setState(() {
//                             selectedDepartment = null;
//                             departmentResponses = [];
//                           });
//                         }
//                       },
//                       children: [
//                         if (isExpanded)
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: departmentResponses.length,
//                             itemBuilder: (context, index) {
//                               var document = departmentResponses[index];
//                               String responseByEmail =
//                               document['Response_by_email'];
//                               String verificationStatus =
//                               document['verification_status'];
//
//                               return ListTile(
//                                 title: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(responseByEmail),
//                                     if (verificationStatus == 'Verified')
//                                       Icon(Icons.check, color: Colors.green),
//                                   ],
//                                 ),
//                                 onTap: () {
//                                   goToQuestionReviewScreen(document.id);
//                                 },
//                               );
//                             },
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             ),
//
//             Align(
//           alignment: Alignment.bottomCenter,
//           child: ElevatedButton(
//             onPressed: releaseResults,
//             child: const Text("Release Results"),
//           ),
//         )
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import 'verification.dart'; // Replace with your verification logic

class SurveyDataScreen extends StatefulWidget {
  @override
  _SurveyDataScreenState createState() => _SurveyDataScreenState();
}

class _SurveyDataScreenState extends State<SurveyDataScreen> {
  List<String> uniqueDepartments = [];
  String? selectedDepartment;
  List<DocumentSnapshot> departmentResponses = [];
  bool allVerified = false; // Track if all responses are verified
  bool isResultReleased = false;
  bool isLoading = false;
  List<bool> _isHovered = [];

  @override
  void initState() {
    super.initState();
    fetchUniqueDepartments();
    fetchResultReleaseStatus();
  }

  Future<void> fetchResultReleaseStatus() async {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    try {
      final resultDoc = await FirebaseFirestore.instance
          .collection('360')
          .doc('nu63wFPHMPW0GGpQnRR1')
          .collection('Result')
          .doc(currentMonth)
          .get();

      setState(() {
        isResultReleased = resultDoc.data()?['isResultReleased'] ?? false;
      });
    } catch (e) {
      print('Error fetching result release status: $e');
    }
  }

  // Future<void> checkResultsReleased() async {
  //   try {
  //     final releaseDoc = await FirebaseFirestore.instance
  //         .collection('360')
  //         .doc('nu63wFPHMPW0GGpQnRR1')
  //         .get();
  //
  //     setState(() {
  //       isReleased = releaseDoc.data()?['results_released'] ?? false;
  //       print('Results Released Status: $isReleased');
  //     });
  //   } catch (e) {
  //     print('Error fetching release status: $e');
  //   }
  // }

  Future<void> fetchUniqueDepartments() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('360')
          .doc('nu63wFPHMPW0GGpQnRR1')
          .collection('360 Survey Data')
          .get();

      final allDepartments = querySnapshot.docs
          .map((doc) => doc['related_department'] as String)
          .toSet()
          .toList();

      setState(() {
        uniqueDepartments = allDepartments;
      });

      await checkAllVerified(); // Check if all responses are verified
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
        //_isHovered = List.filled(departmentResponses.length, false);
      });

      await checkAllVerified(); // Recheck verification status
    } catch (e) {
      print('Error fetching department data: $e');
    }
  }

  Stream<List<DocumentSnapshot>> getDepartmentResponsesStream(
      String department) {
    final currentMonth = DateFormat('MMMM').format(DateTime.now());
    final currentYear = DateFormat('yyyy').format(DateTime.now());

    return FirebaseFirestore.instance
        .collection('360')
        .doc('nu63wFPHMPW0GGpQnRR1')
        .collection('360 Survey Data')
        .where('related_department', isEqualTo: department)
        .where('survey_month', isEqualTo: '$currentMonth $currentYear')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> checkAllVerified() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('360')
          .doc('nu63wFPHMPW0GGpQnRR1')
          .collection('360 Survey Data')
          .get();

      // Check if all responses have verification_status as 'Verified'
      bool allResponsesVerified = true;
      for (var doc in querySnapshot.docs) {
        if (doc['verification_status'] != 'Verified') {
          allResponsesVerified = false;
          break;
        }
      }

      setState(() {
        allVerified = allResponsesVerified;
      });

      print('All responses verified: $allVerified');
    } catch (e) {
      print('Error checking verification status: $e');
    }
  }

  void goToQuestionReviewScreen(String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionReviewScreen(responseId: docId),
      ),
    ).then((_) async {
      await checkAllVerified(); // Recheck when returning to this screen
    });
  }

  Future<void> releaseResults() async {
    if (!allVerified) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    //await Future.delayed(const Duration(seconds: 2));

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
    await FirebaseFirestore.instance
        .collection('360')
        .doc('nu63wFPHMPW0GGpQnRR1')
        .collection('Result')
        .doc(currentMonth)
        .update({'isResultReleased': true});

    // setState(() {
    //   resultsReleased = true; // Update local state
    // });

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results released successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "360 Reviews",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
                        //getDepartmentResponsesStream(department);
                        setState(() {
                          _isHovered = List.filled(departmentResponses.length,
                              false); // Reset hover state
                        });
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: departmentResponses.length,
                          itemBuilder: (context, index) {
                            var document = departmentResponses[index];
                            String responseByEmail =
                                document['Response_by_email'];
                            String verificationStatus =
                                document['verification_status'];

                            return
                            //   MouseRegion(
                            //   onEnter: (_) {
                            //     setState(() {
                            //       _isHovered[index] = true;
                            //     });
                            //   },
                            //   onExit: (_) {
                            //     setState(() {
                            //       _isHovered[index] = false;
                            //     });
                            //   },
                            //   child: InkWell(
                            //     onTap: () {
                            //       goToQuestionReviewScreen(document.id);
                            //     },
                            //     child: ListTile(
                            //       title: Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Text(
                            //             responseByEmail,
                            //             style: TextStyle(
                            //               color: _isHovered[index]
                            //                   ? Colors.blue
                            //                   : Colors.black,
                            //             ),
                            //           ),
                            //           if (verificationStatus == 'Verified')
                            //             Icon(
                            //               Icons.check,
                            //               color: _isHovered[index]
                            //                   ? Colors.blue
                            //                   : Colors.green,
                            //             ),
                            //         ],
                            //       ),
                            //       tileColor: _isHovered[index]
                            //           ? Colors.grey[200]
                            //           : Colors.white,
                            //     ),
                            //   ),
                            // );
                              ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(responseByEmail),
                                  if (verificationStatus == 'Verified')
                                    const Icon(Icons.check, color: Colors.green),
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
        ),
        StreamBuilder<bool>(
          stream: checkAllVerifiedStream(), // Stream to check verification
          builder: (context, snapshot) {
            final isButtonEnabled = snapshot.data ?? false; // Stream data

            return Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: (isButtonEnabled && !isResultReleased)
                    ? () async {
                        _showReleaseDialog(context);
                      }
                    : null, // Disable button if not allowed
                style: ElevatedButton.styleFrom(
                  backgroundColor: isResultReleased
                      ? Colors.grey[100]
                      : Colors.blue, // Button color
                ),
                child: Text(
                  isResultReleased ? 'Released' : 'Release Result',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  // void _showReleaseDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirm Release'),
  //         content: const Text('Do you want to release the result?'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('No'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close dialog
  //               releaseResults();
  //             },
  //             child: const Text('Yes'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  void _showReleaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Release'),
          content: const Text('Do you want to release the result?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await releaseResults();
                await fetchResultReleaseStatus(); // Refresh status
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Stream<bool> checkAllVerifiedStream() {
    return FirebaseFirestore.instance
        .collection('360')
        .doc('nu63wFPHMPW0GGpQnRR1')
        .collection('360 Survey Data')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .every((doc) => doc['verification_status'] == 'Verified');
    });
  }
}
