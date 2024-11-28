import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ViewApplicationsScreen extends StatefulWidget {
  final String jobId;
  const ViewApplicationsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<ViewApplicationsScreen> createState() => _ViewApplicationsScreenState();
}

class _ViewApplicationsScreenState extends State<ViewApplicationsScreen>
    with TickerProviderStateMixin { // Add TickerProviderStateMixin
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 'this' now works
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text("Applications",style: TextStyle(color: Colors.white,fontSize: 20),),
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
                            Tab(text: 'Rejected',)
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * .7,
                        child: TabBarView(
                          controller: _tabController,
                          children: [

                            // Add widgets for each tab here
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
}
