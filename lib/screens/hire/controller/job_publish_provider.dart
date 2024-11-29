import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublishProvider extends ChangeNotifier{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasPendingApplications(String jobId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('hiring')
        .doc(jobId)
        .collection('applications')
        .where('status', isEqualTo: 'Pending')
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> updateHiringStatus(String jobId, bool isPublished) async {
    try {
      await _firestore.collection('hiring').doc(jobId).update({
        'isPublished': isPublished,
        if (isPublished)
          'publishTime': FieldValue.serverTimestamp(),
        if (!isPublished) ...{
          'closeTime': FieldValue.serverTimestamp(),
          'closeHiring': true,
        }
      });

      String message = isPublished
          ? 'Job published successfully!'
          : 'Job closed successfully!';



    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Failed to update job status: $e'),
      //   backgroundColor: Colors.red,
      // ));
    }
  }
}