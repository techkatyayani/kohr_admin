import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class JobDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot jobData;

  const JobDetailsScreen({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final jobTitle = jobData['jobTitle'];
    final companyName = jobData['companyName'];
    final location = jobData['location'];
    final jobDescription = jobData['jobDescription'];
    final skills = List<String>.from(jobData['skills']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              companyName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Location: $location",
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Skills:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: skills
                  .map((skill) => Chip(
                label: Text(skill),
                backgroundColor: AppColors.lightGrey,
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Job Description:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jobDescription,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
