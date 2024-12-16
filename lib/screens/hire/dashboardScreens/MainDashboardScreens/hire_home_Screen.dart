import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'job_detail_screen.dart';
import 'job_form.dart';

class HireHomeScreen extends StatefulWidget {
  const HireHomeScreen({super.key});

  @override
  State<HireHomeScreen> createState() => _HireHomeScreenState();
}

class _HireHomeScreenState extends State<HireHomeScreen> {
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
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hello",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => JobApplicationFormDialog(),
                      );
                    },
                    child: const Text("Create Job "),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                          Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9), // Slight transparency
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                      color: Colors.black.withOpacity(0.2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [

                                    Theme(
                                      data: ThemeData(
                                        // Remove underline from DropdownButton
                                        canvasColor: Colors.white, // background color
                                        primaryColor: Colors.blue, // color of the selected item
                                        textTheme: TextTheme(
                                          bodyMedium: TextStyle(color: Colors.black), // color of the dropdown items
                                        ),
                                      ),
                                      child: DropdownButton<String>(
                                        value: selectedFilter,
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedFilter = newValue!;
                                          });
                                        },
                                        underline: Container(), // Removes the underline
                                        items: ['All', 'On Hiring', 'Closed Hiring', 'Future Hiring']
                                            .map((filter) => DropdownMenuItem(
                                          child: Text(filter),
                                          value: filter,
                                        ))
                                            .toList(),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
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
                            childAspectRatio: 4.0,
                          ),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return JobDetailsPopup(jobData: job);
                                  },
                                );
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
    final companyName = job['companyName'];
    final requireEmployee=job['requiredEmployees'];
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
            Text(
              jobTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Use primary color for the title
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.account_balance_outlined),
                SizedBox(width: 5),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 80),
                const Icon(Icons.person),
                SizedBox(width: 5),
                Text(
                  requireEmployee,
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
}
