import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/screens/kpi/allrounder_form.dart';
import 'package:kohr_admin/screens/kpi/feedback_form.dart';
import 'package:kohr_admin/screens/kpi/kpi_form.dart';

class KpiFormScreen extends StatefulWidget {
  final String name;
  final String email;
  const KpiFormScreen({super.key, required this.name, required this.email});

  @override
  State<KpiFormScreen> createState() => _KpiFormScreenState();
}

class _KpiFormScreenState extends State<KpiFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Employee? employee;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    fetchEmployeeData();
  }

  void fetchEmployeeData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('workEmail', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          employee = Employee.fromMap(snapshot.docs.first.data());
          log(employee.toString());
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching employee data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      backgroundColor: AppColors.greyBackground,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: size.width * .03,
                  right: size.width * .03,
                  top: size.height * .02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "KPI's Form",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.primaryBlue),
                            height: size.height * .01,
                            width: size.width * .14,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * .02,
                        vertical: size.height * .02,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  "assets/images/profile.jpg",
                                  width: size.width * .07,
                                ),
                              ),
                              SizedBox(width: size.width * .02),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          employee?.name ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "(${employee?.employeeCode ?? ''})",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(employee?.employeeType ?? '',
                                        style: const TextStyle(fontSize: 14)),
                                    Text(employee?.department ?? '',
                                        style: const TextStyle(fontSize: 14)),
                                    Text(employee?.location ?? '',
                                        style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(
                              color: Colors.grey, height: size.height * .04),
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: '360'),
                              Tab(text: 'Feedback'),
                              Tab(text: 'KPI'),
                            ],
                            indicatorColor: AppColors.primaryBlue,
                            labelColor: AppColors.primaryBlue,
                            unselectedLabelColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * .6,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          KpiForm(),
                          FeedbackForm(),
                          AllRounderForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
