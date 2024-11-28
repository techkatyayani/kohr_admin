import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HireDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get jobsStream => _firestore
      .collection('hiring')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> updateHiringStatus({
    required String jobId,
    required bool isPublished,
    required BuildContext context,
  }) async {
    try {
      await _firestore.collection('hiring').doc(jobId).update({
        'isPublished': isPublished,
        if (isPublished) 'publishTime': FieldValue.serverTimestamp(),
        if (!isPublished) ...{
          'closeTime': FieldValue.serverTimestamp(),
          'closeHiring': true,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPublished ? 'Job published successfully!' : 'Job closed successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update job status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, List<QueryDocumentSnapshot>> categorizeJobs(List<QueryDocumentSnapshot> jobs) {
    List<QueryDocumentSnapshot> activeJobs = [];
    List<QueryDocumentSnapshot> closedJobs = [];

    for (var job in jobs) {
      if (job['closeTime'] != null) {
        closedJobs.add(job);
      } else {
        activeJobs.add(job);
      }
    }

    return {
      'activeJobs': activeJobs,
      'closedJobs': closedJobs,
    };
  }
}
