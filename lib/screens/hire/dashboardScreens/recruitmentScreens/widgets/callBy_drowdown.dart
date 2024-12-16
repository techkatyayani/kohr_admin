import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallByRecruiterDropdown extends StatelessWidget {
  final String? initialValue; // Initial value for the dropdown
  final String jobId; // The job ID (to update the correct application in Firestore)
  final String applicationId; // The application ID to update
  final Function(String) onChanged; // Callback when a value is selected
  final List<String> recruiters; // List of recruiters to show in the dropdown

  // Constructor for passing parameters
  const CallByRecruiterDropdown({
    Key? key,
    required this.initialValue,
    required this.jobId,
    required this.applicationId,
    required this.onChanged,
    required this.recruiters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: initialValue ?? "No", // Default value is "No" if null
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true,
      onChanged: (newRecruiter) {
        if (newRecruiter != null) {
          // Firestore update when a new recruiter is selected
          FirebaseFirestore.instance
              .collection('hiring/$jobId/applications')
              .doc(applicationId)
              .update({'callBy': newRecruiter}).then((_) {
            // Optionally, you can show a snackbar or confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Recruiter updated to $newRecruiter')),
            );
          }).catchError((error) {
            // Handle errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating recruiter: $error')),
            );
          });
        }
        // Call the onChanged callback to notify the parent widget
        onChanged(newRecruiter ?? "No");
      },
      items: recruiters
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
