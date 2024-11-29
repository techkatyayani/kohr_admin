//
// import 'package:Kohr_Admin/screens/hire/view_application_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:provider/provider.dart';
//
// import '../../constants.dart';
// import 'controller/applicationProvider.dart';
// import 'job_detail_screen.dart';
// import 'job_form.dart';
//
// class HireDashboard extends StatefulWidget {
//   const HireDashboard({super.key});
//
//   @override
//   State<HireDashboard> createState() => _HireDashboardState();
// }
//
// class _HireDashboardState extends State<HireDashboard> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<bool> _hasPendingApplications(String jobId) async {
//     // Check if there are any applications with status "pending"
//     QuerySnapshot snapshot = await _firestore
//         .collection('hiring')
//         .doc(jobId)
//         .collection('applications')
//         .where('status', isEqualTo: 'Pending')
//         //.where('applicationID', isEqualTo: 'applicationID')
//         .get();
// print("status ");
//     return snapshot.docs.isNotEmpty;
//   }
//
//   Future<void> _updateHiringStatus(String jobId, bool isPublished) async {
//     try {
//       // Update the `isPublished` field and set `closedHiring` if needed
//       await _firestore.collection('hiring').doc(jobId).update({
//         'isPublished': isPublished,
//         if (isPublished)
//           'publishTime': FieldValue.serverTimestamp(), // Set publish time
//         if (!isPublished) ...{
//           'closeTime': FieldValue.serverTimestamp(), // Set close time
//           'closeHiring': true, // Set closedHiring to true
//         }
//       });
//
//       // Show appropriate feedback message
//       String message = isPublished
//           ? 'Job published successfully!'
//           : 'Job closed successfully!';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       setState(() {});
//     } catch (e) {
//       // Handle errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update job status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         width: double.infinity,
//         color: AppColors.primaryBlue.withOpacity(0.1),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Hire",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         PageTransition(
//                           child: JobApplicationForm(),
//                           type: PageTransitionType.fade,
//                         ),
//                       );
//                     },
//                     child: const Text("Create Job Application"),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('hiring')
//                   .orderBy('createdAt', descending: true) // Sort by createdAt
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       "No Job Applications Found",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: AppColors.greyText,
//                       ),
//                     ),
//                   );
//                 }
//
//                 final jobs = snapshot.data!.docs;
//
//                 // Separate the jobs into active and closed
//                 List<QueryDocumentSnapshot> activeJobs = [];
//                 List<QueryDocumentSnapshot> closedJobs = [];
//
//                 for (var job in jobs) {
//                   if (job['closeTime'] != null) {
//                     closedJobs.add(job); // Job is closed
//                   } else {
//                     activeJobs.add(job); // Job is active
//                   }
//                 }
//
//                 // Combine the lists (active jobs first, then closed jobs)
//                 List<QueryDocumentSnapshot> allJobs = activeJobs + closedJobs;
//
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   itemCount: allJobs.length + 1, // Include static count at top
//                   itemBuilder: (context, index) {
//                     if (index == 0) {
//                       return Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Text(
//                           'Total Strength: ${allJobs.length}',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       );
//                     }
//
//                     final job = allJobs[index - 1]; // Adjust for static content
//                     return GestureDetector(
//                       onTap: () {
//                         // Navigate to job details screen
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => JobDetailsScreen(jobData: job),
//                           ),
//                         );
//                       },
//                       child: _buildJobCard(job),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildJobCard(QueryDocumentSnapshot job) {
//     final provider = Provider.of<ApplicationProvider>(context);
//     final jobId = job.id; // Document ID
//     final jobTitle = job['jobTitle'];
//     final companyName = job['companyName'];
//     final skills = List<String>.from(job['skills']);
//     final isPublished = job['isPublished'] ?? false; // Check publish state
//     final bool isClosed = job['closeHiring'] ?? false; // Check closedHiring state
//     final Timestamp? publishTime = job['publishTime']; // Firebase timestamp
//     final Timestamp? closeTime = job['closeTime']; // Firebase timestamp
//
//     // Format publish and close times if they exist
//     String? formattedPublishTime;
//     String? formattedCloseTime;
//     if (publishTime != null) {
//       final date = publishTime.toDate(); // Convert to DateTime
//       formattedPublishTime =
//       "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
//     }
//     if (closeTime != null) {
//       final date = closeTime.toDate(); // Convert to DateTime
//       formattedCloseTime =
//       "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
//     }
//
//     return Card(
//       color: isClosed ? Colors.grey.shade300 : Colors.white, // Gray if closed
//       margin: const EdgeInsets.only(bottom: 10.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       elevation: 4,
//       shadowColor: Colors.black.withOpacity(0.2),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (isClosed)
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 10.0),
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade200,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text(
//                     'CLOSED',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             Text(
//               jobTitle,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: isClosed ? Colors.grey.shade700 : AppColors.primaryBlue,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   companyName,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: isClosed ? Colors.grey.shade700 : AppColors.greyText,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 FutureBuilder<bool>(
//                   future: _hasPendingApplications(jobId),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     }
//                     if (snapshot.data == true) {
//                       return ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   ViewApplicationsScreen(jobId: jobId,),
//                             ),
//                           );
//                         },
//                         child: const Text('View Applications'),
//                       );
//                     }
//                     return const SizedBox.shrink(); // No button if no pending apps
//                   },
//                 ),
//                 ElevatedButton(
//                   onPressed: isClosed
//                       ? null
//                       : () => _updateHiringStatus(jobId, !isPublished),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isClosed
//                         ? Colors.grey
//                         : (isPublished ? Colors.red : AppColors.primaryBlue),
//                   ),
//                   child: Text(
//                     isClosed
//                         ? "Closed"
//                         : (isPublished ? "Close Hiring" : "Publish"),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8.0,
//               runSpacing: 4.0,
//               children: skills
//                   .map((skill) => Chip(
//                 label: Text(
//                   skill,
//                   style: TextStyle(
//                     color: isClosed
//                         ? Colors.grey.shade700
//                         : Colors.black,
//                   ),
//                 ),
//                 backgroundColor: Colors.grey.shade100,
//               ))
//                   .toList(),
//             ),
//             if (formattedPublishTime != null) ...[
//               const SizedBox(height: 10),
//               Text(
//                 'Published on: $formattedPublishTime',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                   color: isClosed ? Colors.grey.shade700 : AppColors.greyText,
//                 ),
//               ),
//             ],
//             if (formattedCloseTime != null) ...[
//               const SizedBox(height: 10),
//               Text(
//                 'Closed on: $formattedCloseTime',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                   color: isClosed ? Colors.grey.shade700 : AppColors.greyText,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'controller/applicationProvider.dart';
import 'job_detail_screen.dart';
import 'job_form.dart';
import 'view_application_screen.dart';

class HireDashboard extends StatefulWidget {
  const HireDashboard({super.key});

  @override
  State<HireDashboard> createState() => _HireDashboardState();
}

class _HireDashboardState extends State<HireDashboard> {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: JobApplicationForm(),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    child: const Text("Create Job Application"),
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
                          } else if (selectedFilter == 'Future Hiring' && job['isPublished'] == false) {
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

  Color primaryColor = Color(0xFF4A90E2); // Sample color

  // Job Card Layout
  Widget _buildJobCard(QueryDocumentSnapshot job) {
    final jobTitle = job['jobTitle'];
    final companyName = job['companyName'];
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
                color: primaryColor, // Use primary color for the title
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
                    fontSize: 15,
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
