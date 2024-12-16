import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateCallingStatus{

  Future<void> updateCallingStatus(String jobId, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring/$jobId/applications') // Navigate to the specific application
          .doc(applicationId) // Use the applicationId to find the document
          .update({'callStatus': newStatus}); // Update the resumeStatus field

      print('Resume status updated to $newStatus');
    } catch (e) {
      print('Error updating Calling status: $e');
      throw e;
    }
  }
  Future<void> updateCandidateCallStatus(
      BuildContext context, String jobId, String applicationId, String newStatus) async {
    try {
      await updateCallingStatus(jobId, applicationId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling marked as $newStatus')),
      );

      Navigator.of(context).pop(); // Close dialog after status update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


}