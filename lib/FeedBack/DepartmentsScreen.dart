//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../constants.dart';
// import 'Controller/FirebaseFuntion.dart';
// import 'FeedbackQuestionScreen.dart';
//
// class FeedDepartmentScreen extends StatefulWidget {
//   FeedDepartmentScreen({Key? key}) : super(key: key);
//
//   @override
//   State<FeedDepartmentScreen> createState() => _FeedDepartmentScreenState();
// }
//
// class _FeedDepartmentScreenState extends State<FeedDepartmentScreen> {
//   FeedBackFuntion _funtion = FeedBackFuntion();
//   bool _isLoading = false; // To track the loading state
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           "FeedBack departments",
//           style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryBlue),
//         ),
//         SizedBox(height: 10,), // Space between title and list
//
//         // StreamBuilder for real-time updates
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('FeedBack Form')
//               .doc('lbKYsR8dnXn3BBbKL8ru')
//               .collection('FeedBack Survey Data')
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return const Center(child: Text("No data available."));
//             }
//
//             final docs = snapshot.data!.docs;
//             final departments = docs.map((doc) => doc['TargetDepartment'] as String).toSet();
//
//             return Column(
//               children: departments.map((department) {
//                 return ExpansionTile(
//                   title: Text(department),
//                   children: [
//                     // StreamBuilder for feedbacks per department
//                     StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('FeedBack Form')
//                           .doc('lbKYsR8dnXn3BBbKL8ru')
//                           .collection('FeedBack Survey Data')
//                           .where('TargetDepartment', isEqualTo: department)
//                           .snapshots(),
//                       builder: (context, departmentSnapshot) {
//                         if (departmentSnapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//
//                         if (departmentSnapshot.hasError ||
//                             !departmentSnapshot.hasData ||
//                             departmentSnapshot.data!.docs.isEmpty) {
//                           return const Center(child: Text("No feedback available."));
//                         }
//
//                         final feedbackDocs = departmentSnapshot.data!.docs;
//
//                         final allVerified = feedbackDocs.every((doc) => doc['Response_Status'] == "Verified");
//
//                         return Column(
//                           children: [
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: feedbackDocs.length,
//                               itemBuilder: (context, index) {
//                                 final doc = feedbackDocs[index];
//                                 final email = doc['Response By'];
//                                 final verificationStatus = doc['Response_Status'];
//
//                                 return ListTile(
//                                   title: Text(email),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.check_circle,
//                                         color: verificationStatus == "Verified" ? Colors.green : Colors.grey,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       const Icon(Icons.arrow_forward),
//                                     ],
//                                   ),
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => FeedbackDetailScreen(
//                                           feedbackDocId: doc.id,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                             ElevatedButton(
//                               onPressed: allVerified
//                                   ? () => _showReleaseDialog(context, department)
//                                   : null,
//                               child: const Text("Release Result"),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   // Show the dialog when the user clicks the "Release Result" button
//   void _showReleaseDialog(BuildContext context, String department) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Release'),
//           content: const Text('Do you want to release the result for this department?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog if user clicks 'No'
//               },
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close dialog
//                 await _releaseResultWithLoader(department); // Show loader and release result
//               },
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Simulate a 2-second loader before releasing the result
//   Future<void> _releaseResultWithLoader(String department) async {
//     setState(() {
//       _isLoading = true; // Set loading state to true to show loader
//     });
//
//     // Simulate a 2-second delay to show loading
//     await Future.delayed(const Duration(seconds: 2));
//
//     // After the loader completes, release the result
//     try {
//       await _funtion.releaseResult(department);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Result released successfully!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//
//     setState(() {
//       _isLoading = false; // Set loading state to false
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import 'Controller/FirebaseFuntion.dart';
import 'FeedbackQuestionScreen.dart';

class FeedDepartmentScreen extends StatefulWidget {
  FeedDepartmentScreen({Key? key}) : super(key: key);

  @override
  State<FeedDepartmentScreen> createState() => _FeedDepartmentScreenState();
}

class _FeedDepartmentScreenState extends State<FeedDepartmentScreen> {
  FeedBackFuntion _funtion = FeedBackFuntion();
  bool _isLoading = false; // To track the loading state
  Map<String, bool> releasedDepartments =
      {}; // Store released state per department

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            "FeedBack departments",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(
          height: 10,
        ), // Space between title and list

        // StreamBuilder for real-time updates
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('FeedBack Form')
              .doc('lbKYsR8dnXn3BBbKL8ru')
              .collection('FeedBack Survey Data')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            final docs = snapshot.data!.docs;
            final departments =
                docs.map((doc) => doc['TargetDepartment'] as String).toSet();

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: departments.map((department) {
                  return ExpansionTile(
                    title: Text(department),
                    children: [
                      // StreamBuilder for feedbacks per department
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('FeedBack Form')
                            .doc('lbKYsR8dnXn3BBbKL8ru')
                            .collection('FeedBack Survey Data')
                            .where('TargetDepartment', isEqualTo: department)
                            .snapshots(),
                        builder: (context, departmentSnapshot) {
                          if (departmentSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (departmentSnapshot.hasError ||
                              !departmentSnapshot.hasData ||
                              departmentSnapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("No feedback available."));
                          }

                          final feedbackDocs = departmentSnapshot.data!.docs;
                          var result;

                          final allVerified = feedbackDocs.every(
                              (doc) => doc['Response_Status'] == "Verified");

                          return Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: feedbackDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = feedbackDocs[index];
                                  final email = doc['Response By'];
                                  final verificationStatus =
                                      doc['Response_Status'];
                                  result = doc['result'];

                                  return ListTile(
                                    title: Text(email),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: verificationStatus == "Verified"
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_forward),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FeedbackDetailScreen(
                                            feedbackDocId: doc.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('FeedBack Form')
                                    .doc('lbKYsR8dnXn3BBbKL8ru')
                                    .collection('FeedBack Survey Data')
                                    .where('TargetDepartment', isEqualTo: department)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, streamSnapshot) {
                                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (streamSnapshot.hasError || streamSnapshot.data == null || streamSnapshot.data!.docs.isEmpty) {
                                    return const Text("Error loading department data.");
                                  }

                                  // Fetch the first document
                                  final doc = streamSnapshot.data!.docs.first;
                                  final isReleased = doc.data()?['result'] == true;

                                  return ElevatedButton(
                                    onPressed: allVerified && !isReleased
                                        ? () => _showReleaseDialog(context, department)
                                        : null,
                                    child: isReleased
                                        ? const Text(
                                      "Released",
                                      style: TextStyle(color: Colors.white),
                                    ) // If result is true, show "Released"
                                        : const Text(
                                      "Release Result",
                                      style: TextStyle(color: Colors.white),
                                    ), // If result is false, show "Release Result"
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        isReleased
                                            ? Colors.grey // If result is true, background is gray (disabled)
                                            : AppColors.primaryBlue, // If result is false, background is primary blue
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // ElevatedButton(
                              //   onPressed: allVerified && !releasedDepartments.containsKey(department)
                              //       ? () => _showReleaseDialog(context, department)
                              //       : null,
                              //   child: releasedDepartments.containsKey(department)
                              //       ? const Text("Released")
                              //       : const Text("Release Result"),
                              //   style: ButtonStyle(
                              //     backgroundColor: releasedDepartments.containsKey(department)
                              //         ? MaterialStateProperty.all(Colors.grey)
                              //         : null,
                              //   ),
                              // ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showReleaseDialog(BuildContext context, String department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Release'),
          content: const Text(
              'Do you want to release the result for this department?'),
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
                await _releaseResultWithLoader(
                    department);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _releaseResultWithLoader(String department) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    try {

      await FirebaseFirestore.instance
          .collection('FeedBack Form')
          .doc('lbKYsR8dnXn3BBbKL8ru')
          .collection('FeedBack Survey Data')
          .where('TargetDepartment', isEqualTo: department)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'result': true});
        }
      });

      setState(() {
        releasedDepartments[department] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Result released successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
