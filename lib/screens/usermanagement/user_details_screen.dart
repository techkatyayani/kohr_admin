import 'dart:developer';
import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/models/employee_model.dart';
import 'package:Kohr_Admin/screens/usermanagement/add_user.dart';
import 'package:Kohr_Admin/screens/usermanagement/contact_details_screenn.dart';
import 'package:Kohr_Admin/screens/usermanagement/financial_details.dart';
import 'package:Kohr_Admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:Kohr_Admin/screens/usermanagement/professional_profile_screen.dart';
import 'package:Kohr_Admin/screens/usermanagement/work_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class UserDetailsScreen extends StatefulWidget {
  final String employeeEmail;
  const UserDetailsScreen({super.key, required this.employeeEmail});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
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
          .where('workEmail', isEqualTo: widget.employeeEmail)
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

  Future<void> deleteProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.employeeEmail)
          .delete();
      Navigator.of(context).pop();
    } catch (e) {
      print("Error deleting profile: $e");
    }
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Profile"),
          content: Text("Are you sure you want to delete this profile?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await deleteProfile();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
        title: const Text("Employee Profile"),
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
                            "Employee Profile",
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
                                          "${employee!.firstName} ${employee!.lastName}" ??
                                              '',
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
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .red, // Set the background color to red
                                ),
                                onPressed: showDeleteConfirmationDialog,
                                child: const Text("Delete Profile"),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: AddUserScreen(
                                          employee: employee,
                                          startingStep: 1,
                                          isEdit: false),
                                    ),
                                  );
                                },
                                child: const Text("Edit Profile"),
                              ),
                            ],
                          ),
                          Divider(
                              color: Colors.grey, height: size.height * .04),
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Personal Profile'),
                              Tab(text: 'Professional Profile'),
                              Tab(text: 'Contact Details'),
                              Tab(text: 'Financial Details'),
                              Tab(text: 'Work Profile'),
                            ],
                            indicatorColor: AppColors.primaryBlue,
                            labelColor: AppColors.primaryBlue,
                            unselectedLabelColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * .8,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PersonalProfileScreen(employee: employee),
                          ProfessionalProfileScreen(employee: employee),
                          ContactDetailsScreenn(employee: employee),
                          FinancialDetailsScreen(employee: employee),
                          WorkProfileScreen(employee: employee),
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
