
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dialogueBox/candidate_details_dialogue_box.dart';

class ResumeSelectedCandidateTable extends StatelessWidget {
  final String jobId;
  final List<Map<String, dynamic>> data;
  final void Function(String resumeUrl)? onResumeTap;
  final void Function(int index, String? newStatus)? onStatusChange;
  final void Function(int index, bool? isChecked)? onCheckboxChange;
  final bool? isSelectAllChecked;
  final void Function(bool? value, List<Map<String, dynamic>> data)? toggleSelectAll;

  const ResumeSelectedCandidateTable({
    Key? key,
    required this.jobId,
    required this.data,
    this.onResumeTap,
    this.onStatusChange,
    this.onCheckboxChange,
    this.isSelectAllChecked,
    this.toggleSelectAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFFFFF0D8), // Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // TableHeader(
            //   isSelectAllChecked: isSelectAllChecked!,
            //   toggleSelectAll: toggleSelectAll!,
            // ),
            const Divider(color: Colors.grey, thickness: 2, height: 2),
            TableRows(
              data: data,
              onCheckboxChange: onCheckboxChange,
              onStatusChange: onStatusChange,
              onResumeTap: onResumeTap,
              jobId: jobId,
            ),
          ],
        ),
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  final bool isSelectAllChecked;
  final void Function(bool? value, List<Map<String, dynamic>> data) toggleSelectAll;

  const TableHeader({
    Key? key,
    required this.isSelectAllChecked,
    required this.toggleSelectAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color(0xFFFFF0D8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Checkbox(
                value: isSelectAllChecked,
                onChanged: (value) => toggleSelectAll(value, []),
              ),
            ),
            _buildHeaderText("Date", 130),
            _buildHeaderText("Name", 130),
            _buildHeaderText("Mobile No.", 150),
            _buildHeaderText("Email", 150),
            _buildHeaderText("City", 150),
            _buildHeaderText("Resume Status", 150),
            _buildHeaderText("Call Status", 160),
            _buildHeaderText("Recruiter", 150),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TableRows extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final void Function(int index, bool? isChecked)? onCheckboxChange;
  final void Function(int index, String? newStatus)? onStatusChange;
  final void Function(String resumeUrl)? onResumeTap;
  final String jobId;

  const TableRows({
    Key? key,
    required this.data,
    this.onCheckboxChange,
    this.onStatusChange,
    this.onResumeTap,
    required this.jobId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: data.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          color: Colors.grey,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final rowData = data[index];
          String formattedDate = _formatDate(rowData['submittedAt']);
          return GestureDetector(
            onTap: () => _showCandidateDetails(rowData, context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              decoration: const BoxDecoration(color: Color(0xFFFFF0D8)),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Checkbox(
                      value: rowData['isChecked'] ?? false,
                      onChanged: (value) {
                        if (onCheckboxChange != null) {
                          onCheckboxChange!(index, value);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 150, child: Text(formattedDate, textAlign: TextAlign.center)),
                  SizedBox(
                    width: 110,
                    child: Text("${rowData['firstName']} ${rowData['lastName']}", textAlign: TextAlign.center),
                  ),
                  SizedBox(width: 10),
                  SizedBox(width: 130, child: Text(rowData['contactNumber'] ?? "N/A", textAlign: TextAlign.center)),
                  SizedBox(width: 160, child: Text(rowData['email'] ?? "N/A", textAlign: TextAlign.center)),
                  SizedBox(width: 150, child: Text(rowData['address'] ?? "N/A", textAlign: TextAlign.center)),
                  SizedBox(width: 150, child: Text(rowData['resumeStatus'] ?? "Pending", textAlign: TextAlign.center)),
                  SizedBox(width: 160, child: Text(rowData['callStatus'] ?? "N/A", textAlign: TextAlign.center)),
                  SizedBox(width: 150, child: Text(rowData['recruiter'] ?? "No", textAlign: TextAlign.center)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    if (timestamp is DateTime) {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    } else if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }
    return "N/A";
  }

  void _showCandidateDetails(Map<String, dynamic> candidate, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CandidateDetailsDialog(candidate: candidate, jobId: jobId),
    );
  }
}
