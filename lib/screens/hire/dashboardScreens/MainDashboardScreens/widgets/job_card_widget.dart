import 'package:Kohr_Admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class JobCard extends StatelessWidget {
  final QueryDocumentSnapshot job;
  final Function(bool isPublished) onUpdateStatus;

  const JobCard({
    required this.job,
    required this.onUpdateStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final jobTitle = job['jobTitle'];
    final companyName = job['companyName'];
    final skills = List<String>.from(job['skills']);
    final isPublished = job['isPublished'] ?? false;
    final isClosed = job['closeHiring'] ?? false;

    final publishTime = job['publishTime'] as Timestamp?;
    final closeTime = job['closeTime'] as Timestamp?;

    String? formattedPublishTime = publishTime != null
        ? _formatTimestamp(publishTime)
        : null;
    String? formattedCloseTime = closeTime != null
        ? _formatTimestamp(closeTime)
        : null;

    return Card(
      color: isClosed ? Colors.grey.shade300 : Colors.white,
      margin: const EdgeInsets.only(bottom: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isClosed) ...[
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CLOSED',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            Text(
              jobTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isClosed ? Colors.grey.shade700 : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isClosed ? Colors.grey.shade700 : AppColors.greyText,
                  ),
                ),
                ElevatedButton(
                  onPressed: isClosed ? null : () => onUpdateStatus(!isPublished),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClosed
                        ? Colors.grey
                        : (isPublished ? Colors.red : AppColors.primaryBlue),
                  ),
                  child: Text(
                    isClosed
                        ? "Closed"
                        : (isPublished ? "Close Hiring" : "Publish"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: skills
                  .map((skill) => Chip(
                label: Text(
                  skill,
                  style: TextStyle(
                    color: isClosed ? Colors.grey.shade700 : Colors.black,
                  ),
                ),
                backgroundColor: Colors.grey.shade100,
              ))
                  .toList(),
            ),
            if (formattedPublishTime != null) ...[
              const SizedBox(height: 10),
              Text(
                'Published on: $formattedPublishTime',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyText,
                ),
              ),
            ],
            if (formattedCloseTime != null) ...[
              const SizedBox(height: 10),
              Text(
                'Closed on: $formattedCloseTime',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
  }
}
