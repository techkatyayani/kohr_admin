import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/candiates_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';

class RecruitmentScreen extends StatefulWidget {
  // final String jobId;
  // final String applicationId;
  const RecruitmentScreen({super.key});

  @override
  State<RecruitmentScreen> createState() => _RecruitmentScreenState();
}

class _RecruitmentScreenState extends State<RecruitmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedCategory = 'Category 1'; // Default value for category filter
  String selectedFilter = 'All'; // Default filter selection
  bool showActiveOnly = true;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Recruitment", style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 24),),
            ),
            const SizedBox(height: 30,),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 2,
                        color: Colors.grey,
                        offset: Offset(0, 1),
                      )
                    ]),
                child: Column(
                  children: [
                    // The filter container that will be positioned on top of the main container
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_chart),
                          const SizedBox(width: 3),
                          const Text(
                            "Vacancies",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),

                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('hiring')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No Job Applications Found",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.greyText,
                              ),
                            ),
                          );
                        }

                        final jobs = snapshot.data!.docs;
                        List<QueryDocumentSnapshot> filteredJobs = [];

                        // Apply filter based on the selected filter value
                        for (var job in jobs) {
                          if (selectedFilter == 'All') {
                            filteredJobs.add(job);
                          } else if (selectedFilter == 'On Hiring' && job['isPublished'] == true) {
                            filteredJobs.add(job);
                          } else if (selectedFilter == 'Closed Hiring' && job['closeTime'] != null) {
                            filteredJobs.add(job);
                          } else if (selectedFilter == 'Future Hiring' && job['futureHiring'] == true) {
                            filteredJobs.add(job);
                          }
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 2.0,
                          ),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            // print("jjjj ${job['applicationId']}");
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>CandidatesScreen(jobId: job['jobId'], title: job['jobTitle'],)));
                              },
                              child: _buildJobCard(job),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildJobCard(QueryDocumentSnapshot job) {
    final jobTitle = job['jobTitle'];
    final jobDiscription = job['jobDescription'];
    final department = job['department'];
    final jobType = job['jobType'];
    final publishTime = job['publishTime']; // Publish time
    final closeTime = job['closeTime']; // Close time
    final isPublished = job['isPublished'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (publishTime != null || closeTime != null) const SizedBox(height: 10),
            if (publishTime != null)
              Row(
                children: [
                  const Icon(Icons.publish, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Published: ${_formatDateTime(publishTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            if (closeTime != null)
              Row(
                children: [
                  const Icon(Icons.close, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Close Time: ${_formatDateTime(closeTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Job Title
            Text(
              jobTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            // Job Description
            Text(
              jobDiscription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // Department and Job Type
            Row(
              children: [
                const Icon(Icons.circle),
                const SizedBox(width: 5),
                Text(
                  department,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 5),
                Text(
                  jobType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

// Helper method to format datetime
  String _formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} }';
  }

}
