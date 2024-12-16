import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controller/StatusUpdateController/update_assessment_Status.dart';

class CandidateAssessmentMarksDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateAssessmentMarksDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateAssessmentMarksDialogState createState() =>
      _CandidateAssessmentMarksDialogState();
}

class _CandidateAssessmentMarksDialogState
    extends State<CandidateAssessmentMarksDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final UpdateAssessmentStatus assessmentStatus =UpdateAssessmentStatus();

  @override
  void dispose() {
    _marksController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final num marks = num.tryParse(_marksController.text) ?? 0;
      final String remarks = _remarksController.text.trim();

      try {
        await FirebaseFirestore.instance
            .collection('hiring/${widget.jobId}/applications')
            .doc(widget.applicationId)
            .update({
          'assessmentMarks': marks,
          'assessmentRemark': remarks,
        });
        assessmentStatus.updateCandidateAssessmentStatus(context, widget.jobId, widget.applicationId, 'Pass');

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment data successfully updated!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Assessment Marks"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter the assessment marks and remarks below:",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Marks",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter marks";
                  }
                  if (num.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter remarks";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: _saveData,
          child: const Text("Save"),
        ),
      ],
    );
  }
}


class CandidateAssessmentMarksFailDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateAssessmentMarksFailDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateAssessmentMarksFailDialogState createState() =>
      _CandidateAssessmentMarksFailDialogState();
}

class _CandidateAssessmentMarksFailDialogState
    extends State<CandidateAssessmentMarksFailDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final UpdateAssessmentStatus assessmentStatus =UpdateAssessmentStatus();

  @override
  void dispose() {
    _marksController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final num marks = num.tryParse(_marksController.text) ?? 0;
      final String remarks = _remarksController.text.trim();

      try {
        await FirebaseFirestore.instance
            .collection('hiring/${widget.jobId}/applications')
            .doc(widget.applicationId)
            .update({
          'assessmentMarks': marks,
          'assessmentRemark': remarks,
        });
        assessmentStatus.updateCandidateAssessmentStatus(context, widget.jobId, widget.applicationId, 'Fail');

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment data successfully updated!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Assessment Marks"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter the assessment marks and remarks below:",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Marks",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter marks";
                  }
                  if (num.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter remarks";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: _saveData,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
