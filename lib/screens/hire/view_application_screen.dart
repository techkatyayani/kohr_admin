
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';

import 'controller/applicationProvider.dart';

class ViewApplicationsScreen extends StatefulWidget {
  final String jobId;
  const ViewApplicationsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<ViewApplicationsScreen> createState() => _ViewApplicationsScreenState();
}

class _ViewApplicationsScreenState extends State<ViewApplicationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch applications
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    provider.fetchPendingApplications(widget.jobId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Applications",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: AppColors.primaryBlue.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primaryBlue,
                          labelColor: AppColors.primaryBlue,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: 'Pending'),
                            Tab(text: 'Selected'),
                            Tab(text: 'Rejected'),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .7,
                        child: TabBarView(
                          controller: _tabController,
                          children: [

                            _buildPendingApplications(provider),
                            // const Center(child: Text("Selected Applications")),
                            // const Center(child: Text("Rejected Applications")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingApplications(ApplicationProvider provider) {
    final applications = provider.pendingApplications;

    if (applications.isEmpty) {
      return const Center(
        child: Text("No pending applications available."),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 6/6,

      ),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${app['firstName']} ${app['lastName']}",
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                const SizedBox(height: 8),
                Text("Email: ${app['email']}", style: const TextStyle(fontSize: 18)),
                Text("Experience: ${app['experience']} yrs", style: const TextStyle(fontSize: 18)),
                Text("Graduation: ${app['graduation']}", style: const TextStyle(fontSize: 18)),
                // SizedBox(height: 30,),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Open resume link
                  },
                  child: const Text("View Resume"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../constants.dart';
// import 'controller/applicationProvider.dart';
//
// class ViewApplicationsScreen extends StatefulWidget {
//   final String jobId;
//   final String applicationId;
//   const ViewApplicationsScreen({Key? key, required this.jobId, required this.applicationId}) : super(key: key);
//
//   @override
//   State<ViewApplicationsScreen> createState() => _ViewApplicationsScreenState();
// }
//
// class _ViewApplicationsScreenState extends State<ViewApplicationsScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//
//     // Fetch applications when the screen loads
//     final provider = Provider.of<ApplicationProvider>(context, listen: false);
//     provider.fetchPendingApplications(jobId);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ApplicationProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Applications",
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         backgroundColor: AppColors.primaryBlue,
//       ),
//       body: provider.pendingApplications.isEmpty &&
//           provider.selectedApplications.isEmpty &&
//           provider.rejectedApplications.isEmpty
//           ? const Center(child: CircularProgressIndicator())  // Show loading spinner while fetching data
//           : SingleChildScrollView(
//         child: Container(
//           width: double.infinity,
//           color: AppColors.primaryBlue.withOpacity(0.1),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 50,
//                         child: TabBar(
//                           controller: _tabController,
//                           indicatorColor: AppColors.primaryBlue,
//                           labelColor: AppColors.primaryBlue,
//                           unselectedLabelColor: Colors.grey,
//                           tabs: const [
//                             Tab(text: 'Pending'),
//                             Tab(text: 'Selected'),
//                             Tab(text: 'Rejected'),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: MediaQuery.sizeOf(context).height * .7,
//                         child: TabBarView(
//                           controller: _tabController,
//                           children: [
//                             _buildApplicationList(provider.pendingApplications),
//                             _buildApplicationList(provider.selectedApplications),
//                             _buildApplicationList(provider.rejectedApplications),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildApplicationList(List<Map<String, dynamic>> applications) {
//     if (applications.isEmpty) {
//       return const Center(
//         child: Text("No applications available."),
//       );
//     }
//
//     return GridView.builder(
//       padding: const EdgeInsets.all(10),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 5 / 6,
//       ),
//       itemCount: applications.length,
//       itemBuilder: (context, index) {
//         final app = applications[index];
//         return Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Name: ${app['firstName']} ${app['lastName']}",
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
//                 const SizedBox(height: 8),
//                 Text("Email: ${app['email']}", style: const TextStyle(fontSize: 18)),
//                 Text("Experience: ${app['experience']} yrs", style: const TextStyle(fontSize: 18)),
//                 Text("Graduation: ${app['graduation']}", style: const TextStyle(fontSize: 18)),
//                 Spacer(),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Open resume link
//                   },
//                   child: const Text("View Resume"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
