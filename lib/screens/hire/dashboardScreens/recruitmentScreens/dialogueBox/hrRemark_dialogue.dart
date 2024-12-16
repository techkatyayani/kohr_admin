import 'package:Kohr_Admin/screens/hire/controller/StatusUpdateController/upadate_hrRound_status.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controller/StatusUpdateController/update_assessment_Status.dart';
import '../../../controller/StatusUpdateController/update_tech_status.dart';
//
class CandidateHRRemarksDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateHRRemarksDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateHRRemarksDialogState createState() =>
      _CandidateHRRemarksDialogState();
}

class _CandidateHRRemarksDialogState
    extends State<CandidateHRRemarksDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _remarksController = TextEditingController();
  final UpdateHRRoundStatus hrRoundStatus =UpdateHRRoundStatus();


  @override
  void dispose() {

    _remarksController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {

      final String remarks = _remarksController.text.trim();

      try {
        await FirebaseFirestore.instance
            .collection('hiring/${widget.jobId}/applications')
            .doc(widget.applicationId)
            .update({

          'hrRemark': remarks,
        });
        //techStatus.updateCandidateTechStatus(context, widget.jobId, widget.applicationId, 'Selected');
        hrRoundStatus.updateCandidateHRRoundStatus(context,widget.jobId,
            widget.applicationId, "Selected");
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HR Remarks successfully updated!')),
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
                "Please enter the HR remarks below:",
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

class CandidateHRRemarksRejectedDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateHRRemarksRejectedDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateHRRemarksRejectedDialogState createState() =>
      _CandidateHRRemarksRejectedDialogState();
}

class _CandidateHRRemarksRejectedDialogState
    extends State<CandidateHRRemarksRejectedDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _remarksController = TextEditingController();
  final UpdateHRRoundStatus hrRoundStatus =UpdateHRRoundStatus();


  @override
  void dispose() {

    _remarksController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {

      final String remarks = _remarksController.text.trim();

      try {
        await FirebaseFirestore.instance
            .collection('hiring/${widget.jobId}/applications')
            .doc(widget.applicationId)
            .update({

          'hrRemark': remarks,
        });
        //techStatus.updateCandidateTechStatus(context, widget.jobId, widget.applicationId, 'Selected');
        hrRoundStatus.updateCandidateHRRoundStatus(context,widget.jobId,
            widget.applicationId, "Rejected");

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HR Remarks successfully updated!')),
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
                "Please enter the HR remarks below:",
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
