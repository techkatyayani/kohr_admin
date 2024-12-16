import 'dart:developer';

import 'package:Kohr_Admin/dashboard_screen.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/MainDashboardScreens/hire_home_Screen.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/OnBoardingScreens/onBoardingscreen.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/main_recruitment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../widgets/selection_button.dart';
import '../auth/login_screen.dart';

class HireDashboard extends StatefulWidget {
  const HireDashboard({super.key});

  @override
  State<HireDashboard> createState() => _HireDashboardState();
}

class _HireDashboardState extends State<HireDashboard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarExpanded = true;
  int screenIndex = 0;
  Map<String, dynamic>? _userData;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String dropdownValue = 'Profile';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  List<Widget> screens = [
    const HireHomeScreen(),
    const RecruitmentScreen(),
    const OnBoardingScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashBoard()));
                },
                icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 10),
            SizedBox(
              height: 40,
              child: Image.asset('assets/images/logodashboard.png'),
            ),
            const Spacer(flex: 1),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.grey,
                  backgroundImage: AssetImage(
                      'assets/images/profile.jpg'), // Your profile image
                  radius: 20,
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        if (newValue == 'Logout') {
                          _logout();
                        }
                      });
                    },
                    items: <String>['Profile', 'Logout']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: AppColors.primaryBlue),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      key: scaffoldKey,
      drawer: null,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 250,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.grey,
                                    backgroundImage:
                                        AssetImage('assets/images/profile.jpg'),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userData?['name'] ?? "No Name",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        _userData?['department'] ??
                                            "No Department",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SelectionButton(
                              data: [
                                SelectionButtonData(
                                  activeIcon: Icons.analytics,
                                  icon: Icons.analytics_outlined,
                                  label: "HomeScreen",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.reduce_capacity_rounded,
                                  icon: Icons.reduce_capacity_rounded,
                                  label: "Recruitment",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.reduce_capacity_rounded,
                                  icon: Icons.reduce_capacity_rounded,
                                  label: "OnBoarding",
                                ),
                              ],
                              onSelected: (index, value) {
                                setState(() {
                                  screenIndex = index;
                                });
                                log("index : $index | label : ${value.label}");
                              },
                              currentIndex: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 13,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 20 * (kIsWeb ? 1 : 2)),
                  _buildHeader(),
                  screens[screenIndex],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({Function()? onPressedMenu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (onPressedMenu != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: onPressedMenu,
                icon: const Icon(EvaIcons.menu),
                tooltip: "menu",
              ),
            ),
          // const Expanded(child: Header()),
        ],
      ),
    );
  }
}
