import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/attendance_model.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/screens/myteam/attendance_details.dart';
import 'package:page_transition/page_transition.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialSelectedDate =
        DateFormat('yyyy-MM-dd').parse(formattedDate);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialSelectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Date',
    );

    if (picked != null && picked != initialSelectedDate) {
      setState(() {
        formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Duration calculateDuration(String startTime, String endTime) {
    try {
      DateTime start = DateFormat('HH:mm:ss').parse(startTime);
      DateTime end = DateFormat('HH:mm:ss').parse(endTime);
      return end.difference(start);
    } catch (e) {
      return Duration.zero;
    }
  }

  String formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  String formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('h:mm:ss a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                "Employee Attendance",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.primaryBlue,
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Live Tracking'),
                        Tab(text: 'Employees'),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchTerm = value.toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              child: const Text("Select Date"),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    FutureBuilder(
                      future: _firestore
                          .collection('profiles')
                          .orderBy('name', descending: false)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Something went wrong!',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No users found.'),
                          );
                        }
                        final filteredDocs = snapshot.data!.docs.where((doc) {
                          var userData = doc.data();
                          var name =
                              userData['name']?.toString().toLowerCase() ?? '';
                          return name.contains(_searchTerm);
                        }).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Employee Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Clock In Time",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Clock Out Time",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Break Duration",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Work Duration",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                Employee userData = Employee.fromMap(
                                    filteredDocs[index].data());
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                              child: AttendanceDetails(
                                                employeeName: userData.name,
                                                employeeWorkMail:
                                                    userData.workEmail,
                                              ),
                                              type: PageTransitionType.fade),
                                        );
                                      },
                                      // onHover: (hovering) {
                                      //   setState(() {
                                      //     isHovered = hovering;
                                      //   });
                                      // },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        // color: isHovered
                                        //     ? Colors.grey[300]
                                        //     : Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: SizedBox(
                                                // width: size.width * .1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userData.name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(userData.employeeCode)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 9,
                                              child: FutureBuilder<
                                                  DocumentSnapshot>(
                                                future: filteredDocs[index]
                                                    .reference
                                                    .collection('attendance')
                                                    .doc(formattedDate)
                                                    .get(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.done) {
                                                    if (snapshot.data != null &&
                                                        snapshot.data!.exists) {
                                                      Attendance
                                                          attendanceData =
                                                          Attendance.fromMap(
                                                              snapshot.data!
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>);
                                                      Duration breakDuration =
                                                          calculateDuration(
                                                              attendanceData
                                                                  .startBreak,
                                                              attendanceData
                                                                  .stopBreak);
                                                      String
                                                          parsedBreakDuration =
                                                          formatDuration(
                                                              breakDuration);
                                                      Duration
                                                          totalWorkDuration =
                                                          calculateDuration(
                                                              attendanceData
                                                                  .clockInTime,
                                                              attendanceData
                                                                  .clockOutTime);
                                                      String
                                                          parsedWorkDuration =
                                                          formatDuration(
                                                              totalWorkDuration);
                                                      return Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(formatTime(
                                                                attendanceData
                                                                    .clockInTime)),
                                                          ),
                                                          Expanded(
                                                            child: Text(formatTime(
                                                                attendanceData
                                                                    .clockOutTime)),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                parsedBreakDuration),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                parsedWorkDuration),
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return const Text("-");
                                                    }
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
}
