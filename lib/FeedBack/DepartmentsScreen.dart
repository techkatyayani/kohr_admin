
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(
          "FeedBack departments",
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue),
        ),

        SizedBox(height: 10,),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru').collection('FeedBack Survey Data').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            final docs = snapshot.data!.docs;
            final departments = docs.map((doc) => doc['TargetDepartment'] as String).toSet();

            return Column(
              children: departments.map((department) {
                return ExpansionTile(
                  title: Text(department),
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('FeedBack Form').doc('lbKYsR8dnXn3BBbKL8ru')
                          .collection('FeedBack Survey Data')
                          .where('TargetDepartment', isEqualTo: department)
                          .get(),
                      builder: (context, departmentSnapshot) {
                        if (departmentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (departmentSnapshot.hasError ||
                            !departmentSnapshot.hasData ||
                            departmentSnapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No feedback available."));
                        }

                        final feedbackDocs = departmentSnapshot.data!.docs;

                        final allVerified = feedbackDocs.every((doc) => doc['Response_Status'] == "Verified");

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: feedbackDocs.length,
                              itemBuilder: (context, index) {
                                final doc = feedbackDocs[index];
                                final email = doc['Response By'];
                                final verificationStatus = doc['Response_Status'];

                                return ListTile(
                                  title: Text(email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: verificationStatus == "Verified" ? Colors.green : Colors.grey,
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.arrow_forward),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FeedbackDetailScreen(
                                          feedbackDocId: doc.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: allVerified
                                  ? () async {
                                try {
                                  await _funtion.releaseResult(department);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Result released successfully!")),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              }
                                  : null,
                              child: const Text("Release Result"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}













