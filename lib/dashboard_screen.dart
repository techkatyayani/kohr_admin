import 'dart:developer';
import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/attendance/attendance_screen.dart';
import 'package:Kohr_Admin/screens/auth/login_screen.dart';
import 'package:Kohr_Admin/screens/hire/hire_dashboard.dart';
import 'package:Kohr_Admin/screens/hire/dashboardScreens/recruitmentScreens/main_recruitment_screen.dart';
import 'package:Kohr_Admin/screens/holidays/holiday_screen.dart';
import 'package:Kohr_Admin/screens/kpi/feedback-screen.dart';
import 'package:Kohr_Admin/screens/kpi/kpi_screen.dart';
import 'package:Kohr_Admin/screens/manageLeaves/manage_leaves_screen.dart';
import 'package:Kohr_Admin/screens/master/master_screen.dart';
import 'package:Kohr_Admin/screens/regularization/regularization_screen.dart';
import 'package:Kohr_Admin/screens/usermanagement/user_management_screen.dart';
import 'package:Kohr_Admin/widgets/selection_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarExpanded = true;
  int screenIndex = 0;
  Map<String, dynamic>? _userData;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String dropdownValue = 'Profile';

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  List<Widget> screens = [
    const UserManagementScreen(),
    const AttendanceScreen(),
    const ManageLeavesScreen(),
    const HolidayScreen(),
    const RegularizationScreen(),
    const KpiScreen(),
    const MasterScreen(),

    //  HireDashboard(),
    // const RecruitmentScreen(),
    const FeedbackScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("AdminUsers")
          .doc(_auth.currentUser!.email)
          .get();

      setState(() {
        _userData = snapshot.data();
      });
    } catch (error) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 20),
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
            IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HireDashboard()));
              }
              , icon: Icon(Icons.analytics_outlined),
            ),
            SizedBox(width: 10,),
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
                                  activeIcon: EvaIcons.person,
                                  icon: EvaIcons.personOutline,
                                  label: "Employee Management",
                                ),
                                SelectionButtonData(
                                  activeIcon: EvaIcons.grid,
                                  icon: EvaIcons.gridOutline,
                                  label: "Attendance",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.energy_savings_leaf,
                                  icon: Icons.energy_savings_leaf_outlined,
                                  label: "Manage Leaves",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.holiday_village,
                                  icon: Icons.holiday_village_outlined,
                                  label: "Holidays",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.fork_right,
                                  icon: Icons.fork_right_outlined,
                                  label: "Regularizations",
                                ),
                                SelectionButtonData(
                                  activeIcon: EvaIcons.activity,
                                  icon: EvaIcons.activityOutline,
                                  label: "KPI's",
                                  // totalNotif: 20,
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.discount,
                                  icon: Icons.discount_outlined,
                                  label: "Master",
                                ),
                                // SelectionButtonData(
                                //   activeIcon: Icons.analytics,
                                //   icon: Icons.analytics_outlined,
                                //   label: "Hire",
                                // ),
                                // SelectionButtonData(
                                //   activeIcon: Icons.reduce_capacity_rounded,
                                //   icon: Icons.reduce_capacity_rounded,
                                //   label: "Recruitment",
                                // ),

                                // SelectionButtonData(
                                //   activeIcon: Icons.adjust_sharp,
                                //   icon: Icons.adjust,
                                //   label: "My Calendar",
                                // ),
                                // SelectionButtonData(
                                //   activeIcon: Icons.card_giftcard,
                                //   icon: Icons.card_giftcard_outlined,
                                //   label: "People",
                                // ),
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
