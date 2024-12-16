import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateResumeStatus{

  Future<void> updateResumeStatus(String jobId, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring/$jobId/applications') // Navigate to the specific application
          .doc(applicationId) // Use the applicationId to find the document
          .update({'resumeStatus': newStatus}); // Update the resumeStatus field

      print('Resume status updated to $newStatus');
    } catch (e) {
      print('Error updating resume status: $e');
      throw e;
    }
  }
  Future<void> updateCandidateStatus(
      BuildContext context, String jobId, String applicationId, String newStatus) async {
    try {
      await updateResumeStatus(jobId, applicationId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resume marked as $newStatus')),
      );

      Navigator.of(context).pop(); // Close dialog after status update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


}