import 'package:Kohr_Admin/screens/hire/controller/StatusUpdateController/upadate_hrRound_status.dart';
import 'package:Kohr_Admin/screens/hire/controller/StatusUpdateController/update_assessment_Status.dart';
import 'package:Kohr_Admin/screens/hire/controller/StatusUpdateController/update_calling_status.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/dialogueBox/assessment_dialogue.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/dialogueBox/candidate_call_dialogurBox.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/dialogueBox/technicalRemarks_dialogue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/StatusUpdateController/update_resume_Status.dart';
import '../../../controller/StatusUpdateController/update_tech_status.dart';
import 'hrRemark_dialogue.dart';

class CandidateDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final String jobId;

  CandidateDetailsDialog(
      {Key? key, required this.candidate, required this.jobId})
      : super(key: key);

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is DateTime) {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    } else if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    }
    return 'N/A';
  }

  void _showResume(BuildContext context, String resumeUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            // Display the PDF
            SizedBox(
              height: 800,
              child: PDF().cachedFromUrl(
                resumeUrl,
                placeholder: (progress) => Center(child: Text('$progress %')),
                errorWidget: (error) => const Center(
                  child: Text('Failed to load resume'),
                ),
              ),
            ),
            // Close button at the top right
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResume(BuildContext context) async {
    final String resumeUrl = candidate['resumeUrl'];
    if (resumeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No resume available')),
      );
      return;
    }

    try {
      if (resumeUrl.endsWith('.pdf')) {
        _showResume(context, resumeUrl);
      } else {
        if (await canLaunch(resumeUrl)) {
          await launch(resumeUrl);
        } else {
          throw 'Could not launch $resumeUrl';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  final UpdateResumeStatus updatestatus = UpdateResumeStatus();
  final UpdateCallingStatus callingStatus= UpdateCallingStatus();
  final UpdateAssessmentStatus assessmentStatus =UpdateAssessmentStatus();
  final UpdateTechStatus techStatus =UpdateTechStatus();
  final UpdateHRRoundStatus hrRoundStatus = UpdateHRRoundStatus();

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [

          Positioned(
            top: 20,
            right: 20,
            child:  FloatingActionButton.extended(
                onPressed:()=>Navigator.pop(context),
                label: Icon(Icons.close,color: Colors.black),
              backgroundColor: Colors.white,

            ),
          ),


          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: 500,
                //height: 700,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Candidate Summary",
                          style: TextStyle(color: Colors.green, fontSize: 18),
                        ),


                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    SelectableText(
                      "${candidate['firstName']} ${candidate['lastName']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      "${candidate['email']} ",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      "${candidate['contactNumber']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_bag),
                              SizedBox(
                                width: 3,
                              ),
                              Chip(
                                label: SelectableText(
                                  candidate['profile'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          )
                        ]),
                        SizedBox(
                          width: 15,
                        ),
                        Wrap(spacing: 8.0, runSpacing: 4.0, children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined),
                              SizedBox(
                                width: 3,
                              ),
                              Chip(
                                label: SelectableText(
                                  candidate['address'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          )
                        ]),
                      ],
                    ),
                    //
                    const SizedBox(height: 5),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    // // Graduation Details
                    SelectableText(
                      "Graduation",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Wrap(spacing: 8.0, runSpacing: 4.0, children: [
                        Chip(
                          label: SelectableText(
                            candidate['graduation'],
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 5),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    SelectableText(
                      "Skills",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (candidate['skills'] as List<dynamic>)
                            .map<Widget>(
                              (skill) => Chip(
                                label: SelectableText(skill.toString()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    SelectableText(
                      "Experience ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SelectableText(
                        "${candidate['experience']} years",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: Colors.grey,
                    ),
                    Container(
                      height: 35,
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => _openResume(context),
                        child: const Center(
                          child: Text(
                            'View Resume',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),

                    if (candidate['callRatings']['totalRating']!=0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText("Calling Info",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SelectableText(
                                "Calling Status:", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['callStatus']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(color: Colors.grey),
                          SelectableText(
                            "Total Rating on calling Quetion Answers ", style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SelectableText(
                                "Total Rating : ", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['callRatings']['totalRating']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),

                    if(candidate['assessmentRemark']!=null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          SelectableText("Assessment Info",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SelectableText(
                                "Assessment Status:", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['assessmentStatus']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SelectableText(
                                "Total Marks : ", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['assessmentMarks']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              SelectableText(
                                "Remark: ", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['assessmentRemark']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),


                    if(candidate['technicalRemark']!=null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          SelectableText("Technical Info",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SelectableText(
                                "Technical Status:", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['techRoundStatus']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              SelectableText(
                                "Remark: ", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['technicalRemark']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    if(candidate['hrRemark']!=null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          SelectableText("HR Info",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,),
                          ),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SelectableText(
                                "Hr Status:", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['hrRoundStatus']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              SelectableText(
                                "Remark: ", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SelectableText(
                                  "${candidate['hrRemark']} ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
          // Floating Action Buttons

          Positioned(
            bottom: 20,
            right: 20,
            child: candidate['resumeStatus'] == null
                ? Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: FloatingActionButton.extended(
                          heroTag: "SelectResume",
                          onPressed: () {
                            updatestatus.updateCandidateStatus(
                              context,
                              jobId,
                              candidate['applicationId'],
                              "Selected",
                            );
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.green,
                          label: const Text(
                            "Select",
                            style: TextStyle(fontSize: 12), // Smaller text
                          ),
                          icon:
                              const Icon(Icons.check, size: 18), // Smaller icon
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: FloatingActionButton.extended(
                          heroTag: "RejectResume",
                          onPressed: () {
                            updatestatus.updateCandidateStatus(
                              context,
                              jobId,
                              candidate['applicationId'],
                              "Rejected",
                            );
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.red,
                          label: const Text(
                            "Reject",
                            style: TextStyle(fontSize: 12), // Smaller text
                          ),
                          icon:
                              const Icon(Icons.close, size: 18), // Smaller icon
                        ),
                      ),
                    ],
                  )
                : const SizedBox(), // Display nothing if resumeStatus is not null
          ),
          if (candidate['resumeStatus']=='Selected' && candidate['callAttempts']<3 && candidate['callRatings']['totalRating']==0)
            // Positioned(
            //     bottom: 20,
            //     right: 20,
            //     child: Column(
            //       children: [
            //         SizedBox(
            //           width: 140,
            //           height: 40,
            //           child: FloatingActionButton.extended(
            //             heroTag: "Call Received",
            //             onPressed: () {
            //               Navigator.pushReplacement(
            //                   context, MaterialPageRoute(builder: (context)=>
            //                   CandidateCallDialog(jobId: jobId,
            //                       applicationId: candidate['applicationId'], callStatus: candidate['callStatus']==null ?'NA':candidate['callStatus'],
            //                       callAttempts: candidate['callAttempts'])));
            //               // callingStatus.updateCandidateCallStatus(context,jobId,
            //               //   candidate['applicationId'],
            //               //   "Received");
            //               // Navigator.pop(context);
            //             },
            //             backgroundColor: Colors.green,
            //             label: const Text(
            //               "Call Received",
            //               style: TextStyle(fontSize: 12), // Smaller text
            //             ),
            //             icon: const Icon(Icons.check, size: 18), // Smaller icon
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         SizedBox(
            //           width: 140,
            //           height: 40,
            //           child: FloatingActionButton.extended(
            //             heroTag: "Not Received",
            //             onPressed: () {
            //               callingStatus.updateCandidateCallStatus(context,jobId,
            //                   candidate['applicationId'],
            //                   "Not-Received");
            //               Navigator.pop(context);
            //             },
            //             backgroundColor: Colors.red,
            //             label: const Text(
            //               "Not Received",
            //               style: TextStyle(fontSize: 12), // Smaller text
            //             ),
            //             icon: const Icon(Icons.close, size: 18), // Smaller icon
            //           ),
            //         ),
            //       ],
            //     )),
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  if (candidate['callAttempts'] < 3)
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Call Received",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateCallDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                              callStatus: "Received",
                              callAttempts: candidate['callAttempts'] + 1,
                            ),
                          );
                         // Navigator.pop(context);
                        },
                        backgroundColor: Colors.green,
                        label: const Text(
                          "Call Received",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.check, size: 18), // Smaller icon
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (candidate['callAttempts'] < 3)
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Not Received",
                        onPressed: () {
                          // Check if the call attempts are less than 3
                          if (candidate['callAttempts'] + 1 < 3) {
                            // Directly update Firestore when attempts are less than 3
                            FirebaseFirestore.instance
                                .collection('hiring/$jobId/applications')
                                .doc(candidate['applicationId'] ?? '')
                                .update({
                              'callStatus': "Not-Received",
                              'callAttempts': candidate['callAttempts'] + 1,
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Call marked as Not-Received.')),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating call data: $error')),
                              );
                            });
                          } else {
                            // Handle the case when call attempts are 3 or more
                            FirebaseFirestore.instance
                                .collection('hiring/$jobId/applications')
                                .doc(candidate['applicationId'] ?? '')
                                .update({
                              'callStatus': "Not-Received",
                              'callAttempts': candidate['callAttempts'] + 1,
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Candidate marked as Not-Received permanently')),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating call data: $error')),
                              );
                            });
                            Navigator.pop(context);
                          }
                        },
                        backgroundColor: Colors.red,
                        label: const Text(
                          "Not Received",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.close, size: 18), // Smaller icon
                      ),
                    ),

                  if (candidate['callAttempts'] >= 3)
                    const Text(
                      "No more call attempts allowed",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

          if (candidate['callStatus'] == 'Received'
              && candidate['resumeStatus']=='Selected'
              && candidate['assessmentStatus'] == null )
            Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Pass",
                        onPressed: () {

                          showDialog(
                            context: context,
                            builder: (context) => CandidateAssessmentMarksDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );
                         // assessmentStatus.updateCandidateAssessmentStatus(context,jobId,
                         //      candidate['applicationId'],
                         //      "Pass");
                          //Navigator.pop(context);
                        },
                        backgroundColor: Colors.green,
                        label: const Text(
                          "Pass",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.check, size: 18), // Smaller icon
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Fail",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateAssessmentMarksFailDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );
                         // assessmentStatus.updateCandidateAssessmentStatus(context,jobId,
                         //      candidate['applicationId'],
                         //      "Fail");
                          //Navigator.pop(context);
                        },
                        backgroundColor: Colors.red,
                        label: const Text(
                          "Fail",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.close, size: 18), // Smaller icon
                      ),
                    ),
                  ],
                )
            ),

          if (candidate['callStatus'] == 'Received'
              && candidate['resumeStatus']=='Selected'
              && candidate['assessmentStatus'] == 'Pass'
              && candidate['techRoundStatus'] == null )
            Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Select",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateTechRemarksDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );
                         // techStatus.updateCandidateTechStatus(context,jobId,
                         //      candidate['applicationId'],
                         //      "Selected");
                         // Navigator.pop(context);
                        },
                        backgroundColor: Colors.green,
                        label: const Text(
                          "Select",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.check, size: 18), // Smaller icon
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Reject",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateTechRemarksRejectedDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );

                         // Navigator.pop(context);
                        },
                        backgroundColor: Colors.red,
                        label: const Text(
                          "Reject",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.close, size: 18), // Smaller icon
                      ),
                    ),
                  ],
                )
            ),

          if (candidate['callStatus'] == 'Received'
              && candidate['resumeStatus']=='Selected'
              && candidate['assessmentStatus'] == 'Pass'
              && candidate['techRoundStatus'] =='Selected'
              &&  candidate['hrRoundStatus'] ==null)
            Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Select",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateHRRemarksDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );
                          // hrRoundStatus.updateCandidateHRRoundStatus(context,jobId,
                          //     candidate['applicationId'],
                          //     "Selected");
                        //  Navigator.pop(context);
                        },
                        backgroundColor: Colors.green,
                        label: const Text(
                          "Select",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.check, size: 18), // Smaller icon
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: FloatingActionButton.extended(
                        heroTag: "Reject",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CandidateHRRemarksRejectedDialog(
                              jobId: jobId,
                              applicationId: candidate['applicationId'] ?? '',
                            ),
                          );
                          // hrRoundStatus.updateCandidateHRRoundStatus(context,jobId,
                          //     candidate['applicationId'],
                          //     "Rejected");
                         // Navigator.pop(context);
                        },
                        backgroundColor: Colors.red,
                        label: const Text(
                          "Reject",
                          style: TextStyle(fontSize: 12), // Smaller text
                        ),
                        icon: const Icon(Icons.close, size: 18), // Smaller icon
                      ),
                    ),
                  ],
                )
            ),

        ],
      ),
    );
  }
}
