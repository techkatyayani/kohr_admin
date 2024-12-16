
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dialogueBox/candidate_details_dialogue_box.dart';

class CandidateTable extends StatefulWidget {
  final String jobId;
  final void Function(String resumeUrl)? onResumeTap;
  final void Function(int index, String? newStatus)? onStatusChange;
  final void Function(int index, bool? isChecked)? onCheckboxChange;

  const CandidateTable({
    Key? key,
    required this.jobId,
    this.onResumeTap,
    this.onStatusChange,
    this.onCheckboxChange, required List<Map<String, dynamic>> data,
  }) : super(key: key);

  @override
  State<CandidateTable> createState() => _CandidateTableState();
}

class _CandidateTableState extends State<CandidateTable> {
  bool isSelectAllChecked = false;

  Stream<List<Map<String, dynamic>>> fetchApplications(String jobId) {
    return FirebaseFirestore.instance
        .collection('hiring/$jobId/applications')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['applicationId'] = doc.id; // Add the document ID
        return data;
      }).toList();
    });
  }

  void toggleSelectAll(bool? value, List<Map<String, dynamic>> data) {
    setState(() {
      isSelectAllChecked = value ?? false;
      for (int i = 0; i < data.length; i++) {
        data[i]['isChecked'] = isSelectAllChecked;
        if (widget.onCheckboxChange != null) {
          widget.onCheckboxChange!(i, isSelectAllChecked);
        }
      }
    });
  }

  void showCandidateDetails(Map<String, dynamic> candidate, String jobId) {
    showDialog(
      context: context,
      builder: (context) {
        return CandidateDetailsDialog(candidate: candidate, jobId: jobId);
      },
    );
  }

  Color _getResumeStatusColor(String status) {
    if (status == 'Selected') {
      return Colors.green[800] ?? Colors.green;
    } else if (status == 'Rejected') {
      return Colors.red[800] ?? Colors.red;
    } else {
      return Colors.black; // Default color
    }
  }

  Color _getCallStatusColor(String status) {
    if (status == 'Received') {
      return Colors.green[800]?? Colors.green;
    } else if (status == 'Not-Received') {
      return Colors.red;
    } else {
      return Colors.grey; // Default color
    }
  }
  Color _getAssesssmentStatusColor(String status) {
    if (status == 'Pass') {
      return Colors.green[800]?? Colors.green;
    } else if (status == 'Fail') {
      return Colors.red;
    } else {
      return Colors.grey; // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchApplications(widget.jobId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No applications found.'));
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
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
                // Fixed Table Header
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Checkbox(
                            value: isSelectAllChecked,
                            onChanged: (value) => toggleSelectAll(value, data),
                          ),
                        ),
                        _buildHeaderText("Date", 100),
                        _buildHeaderText("Name", 120),
                        _buildHeaderText("Owner", 130),
                        _buildHeaderText("Source", 115),
                        _buildHeaderText("Resume Status", 135),
                        _buildHeaderText("Call Status", 130),
                        _buildHeaderText("Assessment Status", 130),
                        _buildHeaderText("Tech.Round Status", 130),
                        _buildHeaderText("HrRound Status", 130),
                        _buildHeaderText("Final Status", 135)
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.grey, thickness: 2, height: 2),
                // Table Rows
                Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 1,
                      color: Colors.grey,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final rowData = data[index];
                      String formattedDate = "N/A";
                      if (rowData['submittedAt'] != null) {
                        final timestamp = rowData['submittedAt'];
                        if (timestamp is DateTime) {
                          formattedDate = DateFormat('dd/MM/yyyy').format(timestamp);
                        } else if (timestamp is Timestamp) {
                          formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          showCandidateDetails(rowData, widget.jobId);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Checkbox(
                                  value: rowData['isChecked'] ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      rowData['isChecked'] = value ?? false;
                                    });
                                    if (widget.onCheckboxChange != null) {
                                      widget.onCheckboxChange!(index, value);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 100, child: Text(formattedDate, textAlign: TextAlign.center)),
                              SizedBox(
                                width: 110,
                                child: Text("${rowData['firstName']} ${rowData['lastName']}",
                                    textAlign: TextAlign.center),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 110,
                                child: Text(rowData['recruiter'] ?? "N/A", textAlign: TextAlign.center),
                              ),
                              SizedBox(width: 130, child: Text(rowData['source'] ?? "N/A", textAlign: TextAlign.center)),
                              // Resume Status with color change
                              SizedBox(
                                width: 140,
                                child: Text(
                                  rowData['resumeStatus'] ?? "Pending",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['resumeStatus'] == 'Selected' ? FontWeight.bold : FontWeight.normal,

                                    color: _getResumeStatusColor(rowData['resumeStatus'] ?? ""),
                                  ),
                                ),
                              ),
                              // Call Status with color change
                              SizedBox(
                                width: 150,
                                child: Text(
                                  rowData['callStatus'] ?? "N/A",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['callStatus'] == 'Received' ? FontWeight.bold : FontWeight.normal,
                                    color: _getCallStatusColor(rowData['callStatus'] ?? ""),
                                  ),
                                ),
                              ),
                              SizedBox(width: 120, child: Text(rowData['assessmentStatus'] ?? "No", textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['assessmentStatus'] == 'Pass' ? FontWeight.bold : FontWeight.normal,

                                    color: _getAssesssmentStatusColor(rowData['assessmentStatus'] ?? ""),
                                  )
                              )),
                              SizedBox(width: 130, child: Text(rowData['techRoundStatus'] ?? "No", textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['techRoundStatus'] == 'Selected' ? FontWeight.bold : FontWeight.normal,

                                    color: _getResumeStatusColor(rowData['techRoundStatus'] ?? ""),
                                  )
                              )),
                              SizedBox(width: 130, child: Text(rowData['hrRoundStatus'] ?? "No", textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['hrRoundStatus'] == 'Selected' ? FontWeight.bold : FontWeight.normal,

                                    color: _getResumeStatusColor(rowData['hrRoundStatus'] ?? ""),
                                  )
                              )),
                              SizedBox(width: 120, child: Text(rowData['finalStatus'] ?? "Pending", textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: rowData['finalStatus'] == 'Selected' ? FontWeight.bold : FontWeight.normal,

                                    color: _getResumeStatusColor(rowData['finalStatus'] ?? ""),
                                  )
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
