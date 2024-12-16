
import 'package:Kohr_Admin/screens/hire/controller/job_publish_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';

class JobDetailsPopup extends StatelessWidget {
  final QueryDocumentSnapshot jobData;

  JobDetailsPopup({super.key, required this.jobData});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final jobId = jobData.id; // Document ID

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('hiring').doc(jobId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final updatedJobData = snapshot.data!;
        final jobTitle = updatedJobData['jobTitle'];
        final companyName = updatedJobData['companyName'];
        final location = updatedJobData['location'];
        final experiece= updatedJobData['experienceLevel'];
        final salary = updatedJobData['salary'];
        final recruiter =updatedJobData['recruiter'];
        final employeementType =updatedJobData['employmentType'];
        final jobType = updatedJobData['jobType'];
        final jobDescription = updatedJobData['jobDescription'];
        final skills = List<String>.from(updatedJobData['skills']);
        final bool isPublished = updatedJobData['isPublished'] ?? false; // Updated publish state
        final bool isClosed = updatedJobData['closeHiring'] ?? false; // Updated closedHiring state

        PublishProvider provider = PublishProvider();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: 700,
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(onPressed: (){
                          Navigator.pop(context);
                        },
                            icon: const Icon(Icons.close)
                        ),
                      ],
                    ),
                    Text(
                      jobTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 5,),
                        Text(
                          "$location",
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const Text(
                      "Recruiter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(
                        recruiter,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                   ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      "Profile Insights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8,),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: const Text(
                        "Skills",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: skills
                            .map((skill) => Chip(
                          label: Text(skill,style: const TextStyle(color: Colors.black),),
                          backgroundColor: Colors.grey[300],
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      "Job Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child:
                      const Text(
                        "pay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child:  Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Chip(
                              label: Text( "Rs $salary",style: const TextStyle(color: Colors.black),),
                              backgroundColor: Colors.grey[300],
                            )
                          ]

                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: const Text(
                        "Job Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child:  Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Chip(
                              label: Text( jobType,style: const TextStyle(color: Colors.black),),
                              backgroundColor: Colors.grey[300],
                            )
                          ]

                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: const Text(
                        "Experience",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child:  Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Chip(
                              label: Text( experiece,style: const TextStyle(color: Colors.black),),
                              backgroundColor: Colors.grey[300],
                            )
                          ]

                      ),
                    ),


                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      "Job Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        jobDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 20),
                    Center(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            Center(
                              child: ElevatedButton(
                                onPressed: isClosed
                                    ? null
                                    : () {
                                  // When pressed, update the status and reflect it instantly
                                  provider.updateHiringStatus(
                                      jobId, !isPublished);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClosed
                                      ? Colors.grey
                                      : (isPublished
                                      ? Colors.red
                                      : AppColors.primaryBlue),
                                ),
                                child: Text(
                                  isClosed
                                      ? "Closed"
                                      : (isPublished ? "Close Hiring" : "Publish"),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
