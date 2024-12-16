import 'package:Kohr_Admin/screens/hire/controller/fetchSelectedcandidates.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/OnBoardingScreens/model/candidate_model.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/OnBoardingScreens/widget/onboard_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CandidateModel>> fetchAllApplications() async* {
    final jobDocs = await _firestore.collection('hiring').get();

    List<Future<List<CandidateModel>>> jobFutures =
        jobDocs.docs.map((jobDoc) async {
      final jobId = jobDoc.id;
      final applicationsSnapshot = await _firestore
          .collection('hiring/$jobId/applications')
          .where('resumeStatus', isEqualTo: 'Selected')
          .where('callStatus', isEqualTo: 'Received')
          .where('assessmentStatus', isEqualTo: 'Pass')
          .where('techRoundStatus', isEqualTo: 'Selected')
          .where('hrRoundStatus', isEqualTo: 'Selected')
          .get();

      return applicationsSnapshot.docs.map((doc) {
        return CandidateModel.fromFirestore(
            doc); // Use fromFirestore instead of fromJson
      }).toList();
    }).toList();

    final results = await Future.wait(jobFutures);
    yield results.expand((list) => list).toList();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'OnBoarding',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          Container(
            height: MediaQuery.of(context).size.height - 100,
            padding: const EdgeInsets.all(20),
            child: StreamBuilder(
              stream: fetchAllApplications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error ${snapshot.error}'),
                  );
                } else {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      return OnboardCard(
                        candidateModel: data,
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
