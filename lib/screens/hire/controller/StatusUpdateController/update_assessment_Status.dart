import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateAssessmentStatus{

  Future<void> updateAssessmentStatus(String jobId, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring/$jobId/applications') // Navigate to the specific application
          .doc(applicationId) // Use the applicationId to find the document
          .update({'assessmentStatus': newStatus}); // Update the resumeStatus field

      print('Resume status updated to $newStatus');
    } catch (e) {
      print('Error updating Assessment status: $e');
      throw e;
    }
  }
  Future<void> updateCandidateAssessmentStatus(
      BuildContext context, String jobId, String applicationId, String newStatus) async {
    try {
      await updateAssessmentStatus(jobId, applicationId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assessment marked as $newStatus')),
      );

      Navigator.of(context).pop(); // Close dialog after status update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


}