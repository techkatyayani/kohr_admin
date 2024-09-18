import 'package:flutter/material.dart';
import 'package:kohr_admin/colors.dart';
import 'package:kohr_admin/screens/usermanagement/contact_details_screenn.dart';
import 'package:kohr_admin/screens/usermanagement/financial_details.dart';
import 'package:kohr_admin/screens/usermanagement/personal_profile_screen.dart';
import 'package:kohr_admin/screens/usermanagement/professional_profile_screen.dart';
import 'package:kohr_admin/screens/usermanagement/work_profile_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      backgroundColor: AppColors.greyBackground,
      body: SingleChildScrollView(
        // Wrap your body in a SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.only(
            left: size.width * .03,
            right: size.width * .03,
            top: size.height * .02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Employee Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Saksham Gupta",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "(KO-1234)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text("Developer", style: TextStyle(fontSize: 14)),
                              Text("Development Department",
                                  style: TextStyle(fontSize: 14)),
                              Text("Bhopal", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey, height: size.height * .04),
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
                  children: const [
                    PersonalProfileScreen(),
                    ProfessionalProfileScreen(),
                    ContactDetailsScreenn(),
                    FinancialDetailsScreen(),
                    WorkProfileScreen(),
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
