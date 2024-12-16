import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controller/StatusUpdateController/update_assessment_Status.dart';
import '../../../controller/StatusUpdateController/update_tech_status.dart';

class CandidateTechRemarksDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateTechRemarksDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateTechRemarksDialogState createState() =>
      _CandidateTechRemarksDialogState();
}

class _CandidateTechRemarksDialogState
    extends State<CandidateTechRemarksDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _remarksController = TextEditingController();
  final UpdateTechStatus techStatus =UpdateTechStatus();


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

          'technicalRemark': remarks,
        });
        techStatus.updateCandidateTechStatus(context, widget.jobId, widget.applicationId, 'Selected');

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Technical Remark successfully updated!')),
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
                "Please enter the Technical remarks below:",
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

class CandidateTechRemarksRejectedDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;

  const CandidateTechRemarksRejectedDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
  }) : super(key: key);

  @override
  _CandidateTechRemarksRejectedDialogState createState() =>
      _CandidateTechRemarksRejectedDialogState();
}

class _CandidateTechRemarksRejectedDialogState
    extends State<CandidateTechRemarksRejectedDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _remarksController = TextEditingController();
  final UpdateTechStatus techStatus =UpdateTechStatus();


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

          'technicalRemark': remarks,
        });
        techStatus.updateCandidateTechStatus(context, widget.jobId, widget.applicationId, 'Rejected');

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Technical Remark successfully updated!')),
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
                "Please enter the Technical remarks below:",
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
