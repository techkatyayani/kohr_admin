import 'dart:developer';
import 'package:Kohr_Admin/MeetingManagement/meeting_rooms.dart';
import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/attendance/attendance_screen.dart';
import 'package:Kohr_Admin/screens/auth/login_screen.dart';
import 'package:Kohr_Admin/screens/holidays/holiday_screen.dart';
import 'package:Kohr_Admin/screens/kpi/feedback-screen.dart';
import 'package:Kohr_Admin/screens/kpi/kpi_screen.dart';
import 'package:Kohr_Admin/screens/manageLeaves/manage_leaves_screen.dart';
import 'package:Kohr_Admin/screens/master/master_screen.dart';
import 'package:Kohr_Admin/screens/regularization/regularization_screen.dart';
import 'package:Kohr_Admin/screens/attendance/time_management.dart';
import 'package:Kohr_Admin/screens/usermanagement/user_management_screen.dart';
import 'package:Kohr_Admin/widgets/selection_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '360 form/surveyDataScreen.dart';
import 'FeedBack/DepartmentsScreen.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSidebarExpanded = true;
  int? screenIndex ;
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
    const TimeManagementScreen(),
    const MeetingRooms(),
    FeedDepartmentScreen(),
    SurveyDataScreen(),
  ];

  // const FeedbackScreen(),
  @override
  void initState() {
    super.initState();
    _loadSavedIndex();
    _fetchUserData();
  }

  Future<void> _loadSavedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      screenIndex = prefs.getInt('screenIndex') ?? 0;
    });
  }

  Future<void> _saveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('screenIndex', index);
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

  void handleScreenChanged(int index) {
    setState(() {
      screenIndex = index;
    });
    _saveIndex(index);  // Save the index when it changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            SizedBox(
              height: 100,
              width: 140,
              child: Image.asset('assets/images/katyayani.png'),
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              "|",
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 5),
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
                                SelectionButtonData(
                                  activeIcon: Icons.watch_later,
                                  icon: Icons.watch_later_outlined,
                                  label: "Time Management",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.meeting_room,
                                  icon: Icons.meeting_room_outlined,
                                  label: "Meeting Management",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.feedback,
                                  icon: Icons.feedback_outlined,
                                  label: "Feedback",
                                ),
                                SelectionButtonData(
                                  activeIcon: Icons.rotate_right,
                                  icon: Icons.rotate_right,
                                  label: "360 Form",
                                ),

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
                                handleScreenChanged(index);
                                log("index : $index | label : ${value.label}");
                              },
                              currentIndex: screenIndex!,
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
                  screens[screenIndex!],
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
