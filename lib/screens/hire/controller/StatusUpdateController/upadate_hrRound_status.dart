// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateHRRoundStatus {
  Future<void> updateHRRoundStatus(
      String jobId, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              'hiring/$jobId/applications') // Navigate to the specific application
          .doc(applicationId) // Use the applicationId to find the document
          .update({
        ''
            'hrRoundStatus': newStatus,
        'finalStatus': newStatus
      }); // Update the resumeStatus field
    } catch (e) {
      log('Error updating HRRound status: $e');
    }
  }

  Future<void> updateCandidateHRRoundStatus(BuildContext context, String jobId,
      String applicationId, String newStatus) async {
    try {
      await updateHRRoundStatus(jobId, applicationId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('HRRound marked as $newStatus')),
      );

      Navigator.of(context).pop(); // Close dialog after status update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
}
