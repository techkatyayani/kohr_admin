// import 'package:Kohr_Admin/screens/hire/controller/fetching_candidates.dart';
// import 'package:Kohr_Admin/screens/hire/hire_dashboard.dart';
// import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/widgets/candidateTable.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../constants.dart';
//
//
// class CandidatesScreen extends StatefulWidget {
//   final String jobId;
//   final String title;
//
//   const CandidatesScreen({super.key, required this.jobId, required this.title});
//
//   @override
//   State<CandidatesScreen> createState() => _CandidatesScreenState();
// }
//
// class _CandidatesScreenState extends State<CandidatesScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Map<String, dynamic>> candidates = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this); // Initialize TabController
//     _fetchCandidates();
//   }
//
//   void _fetchCandidates() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('hiring/${widget.jobId}/applications')
//         .get();
//
//     setState(() {
//       candidates = snapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         data['isChecked'] = false; // Add checkbox state
//         return data;
//       }).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//
//         onWillPop: () async {
//       // Prevent swipe back gesture or hardware back button
//       return false;
//     },
//       child:Scaffold(
//       backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//       appBar: AppBar(
//        // centerTitle: false,
//
//         title: Row(
//           //mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             IconButton(onPressed: (){
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HireDashboard()));
//             }, icon:Icon(Icons.arrow_back,color: Colors.white,)),
//             const SizedBox(width: 5),
//             Text(widget.title,style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
//             const SizedBox(width: 20,)
//
//           ],
//         ),
//         backgroundColor: Colors.green,
//
//
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50), // Adjust the height as needed
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white, // Background color for the TabBar
//               borderRadius: BorderRadius.circular(10), // Rounded corners
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5), // Shadow color
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(0, 3), // Shadow position
//                 ),
//               ],
//             ),
//             child: TabBar(
//               controller: _tabController,
//               tabs: const [
//                 Tab(text: "Candidates"),
//                 Tab(text: "Recruitment"),
//               ],
//
//               indicatorColor: Colors.red, // Active tab underline color
//               indicatorSize: TabBarIndicatorSize.label, // Indicator matches text width
//               indicatorWeight: 2.0, // Indicator thickness
//               labelColor: Colors.green, // Active tab text color
//               unselectedLabelColor: Colors.black, // Inactive tab text color
//               labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,), // Active tab text style
//               unselectedLabelStyle: TextStyle(fontSize: 18),
//               // Inactive tab text style
//             ),
//           ),
//         ),
//
//
//       ),
//          body:
//       // Container(
//         //   child: NotificationListener<OverscrollIndicatorNotification>(
//         //     onNotification: (OverscrollIndicatorNotification notification) {
//         //       // Disable glowing overscroll
//         //       notification.disallowIndicator();
//         //       return true;
//         //     },
//         //     child:
//       TabBarView(
//               controller: _tabController,
//               physics: const NeverScrollableScrollPhysics(), // Disable swipe gesture to change tabs
//               children: [
//                 // Candidates Tab
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(15.0),
//                       child: Row(
//                         children: [
//                           const SizedBox(width: 30),
//                           Icon(Icons.person_add_alt_1),
//                           const SizedBox(width: 10),
//                           Text(
//                             "Candidates",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 25,
//                             ),
//                           ),
//                           const Spacer(flex: 1),
//                           Container(
//                             width: 300,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[400],
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: TextField(
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 prefixIcon: const Icon(Icons.search),
//                                 hintText: "Search Name",
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                             onPressed: () {
//                               // Implement filter functionality here
//                             },
//                             child: const Text("Filters"),
//                           ),
//                           const Spacer(flex: 1),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                             onPressed: () {
//                               // Implement filter functionality here
//                             },
//                             child: const Text("Add Candidate"),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     // Candidate Table
//                     Expanded(
//                       child:
//                       CandidateTable(
//                         jobId: widget.jobId,
//                         data: candidates,
//                         onCheckboxChange: (index, isChecked) {
//                           setState(() {
//                             candidates[index]['isChecked'] = isChecked;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Recruitment Tab
//                 Center(
//                   child: const Text("Recruitment Section"),
//                 ),
//               ],
//             ),
//          ),
//        // )
//
//       // ],
//      // ),
//     );
//   }
// }
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/assesementRoundCandidates.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/callRoundcCandidates.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/candidateTable.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/hrRoundCandidates.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/resumeSelected_candidates.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/CandidatesTables/techRoundCandidates.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../constants.dart';

class CandidatesScreen extends StatefulWidget {
  final String jobId;
  final String title;

  const CandidatesScreen({super.key, required this.jobId, required this.title});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with TickerProviderStateMixin { // Change to TickerProviderStateMixin
  late TabController _tabController;
  late TabController _recruitmentTabController; // TabController for Recruitment section
  List<Map<String, dynamic>> candidates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Main Tabs
    _recruitmentTabController = TabController(length: 5, vsync: this); // Recruitment Tabs
    _fetchCandidates();
  }

  @override
  void dispose() {
    // Dispose of both controllers to free resources
    _tabController.dispose();
    _recruitmentTabController.dispose();
    super.dispose();
  }

  void _fetchCandidates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('hiring/${widget.jobId}/applications')
        .get();

    setState(() {
      candidates = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['isChecked'] = false; // Add checkbox state
        return data;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 5),
              Text(
                widget.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Candidates"),
                  Tab(text: "Recruitment"),
                ],
                indicatorColor: Colors.red,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2.0,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                unselectedLabelStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Candidates Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 30),
                      const Icon(Icons.person_add_alt_1),
                      const SizedBox(width: 10),
                      const Text(
                        "Candidates",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                            hintText: "Search Name",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          // Implement filter functionality here
                        },
                        child: const Text("Filters"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          // Implement filter functionality here
                        },
                        child: const Text("Add Candidate"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Candidate Table
                Expanded(
                  child: CandidateTable(
                    jobId: widget.jobId,
                    data: candidates,
                    onCheckboxChange: (index, isChecked) {
                      setState(() {
                        candidates[index]['isChecked'] = isChecked;
                      });
                    },
                  ),
                ),
              ],
            ),
            // Recruitment Tab with Sub-tabs
            Column(
              children: [
                // Sub-tabs for Recruitment
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _recruitmentTabController,
                    tabs: [
                      Tab(
                        child: Container(

                          color: Color(0xFFF0D8), // Background color for the "Resume" tab
                          child: Text(
                            "Resume",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          //padding: EdgeInsets.symmetric(vertical: 10),
                          color: Color(0xEDDFFE), // Background color for the "Calling" tab
                          child: Text(
                            "Calling",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          //padding: EdgeInsets.symmetric(vertical: 10),
                          color: Color(0xD9E5F8), // Background color for the "Assessment" tab
                          child: Text(
                            "Assessment",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          //padding: EdgeInsets.symmetric(vertical: 10),
                          color: Color(0xB6EDD7 ), // Background color for the "Technical Round" tab
                          child: Text(
                            "Technical Round",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          //padding: EdgeInsets.symmetric(vertical: 10),
                          color: Color(0xF9DDDD), // Background color for the "HR Round" tab
                          child: Text(
                            "HR Round",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                    indicatorColor: Colors.green,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 2.0,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _recruitmentTabController,
                    children: [
                      ResumeSelectedCandidateTable(jobId: widget.jobId,data: candidates),
                      CallCandidateTable(jobId: widget.jobId, data: candidates),
                      AssesmentCandidateTable(jobId: widget.jobId, data: candidates),
                      TechnicalCandidateTable(jobId: widget.jobId, data: candidates),
                      HRCandidateTable(jobId: widget.jobId, data: candidates),
                     // Center(child: Text("HR Round rr")),
                    ],
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
