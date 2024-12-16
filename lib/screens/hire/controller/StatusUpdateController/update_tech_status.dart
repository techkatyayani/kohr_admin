import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateTechStatus{

  Future<void> updateTechStatus(String jobId, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring/$jobId/applications') // Navigate to the specific application
          .doc(applicationId) // Use the applicationId to find the document
          .update({'techRoundStatus': newStatus}); // Update the resumeStatus field


    } catch (e) {
      print('Error updating Tech status: $e');
      throw e;
    }
  }
  Future<void> updateCandidateTechStatus(
      BuildContext context, String jobId, String applicationId, String newStatus) async {
    try {
      await updateTechStatus(jobId, applicationId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Techmarked as $newStatus')),
      );

      Navigator.of(context).pop(); // Close dialog after status update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


}