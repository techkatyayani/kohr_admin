import 'dart:convert';

import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/models/attendance_model.dart';
import 'package:Kohr_Admin/models/employee_model.dart';
import 'package:Kohr_Admin/screens/attendance/attendance_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

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
  bool _isGeneratingCSV = false;
  String? _selectedDepartment = 'All Departments';

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

  // Add this new function to show the department selection dialog
  Future<void> _showDepartmentSelectionDialog() async {
    final departments = await _fetchDepartments();
    String? selectedDepartment = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Department'),
              content: DropdownButton<String>(
                value: _selectedDepartment,
                items: departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Generate CSV'),
                  onPressed: () {
                    Navigator.of(context).pop(_selectedDepartment);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedDepartment != null) {
      _generateAndDownloadCSV(selectedDepartment);
    }
  }

  // Add this function to fetch departments from Firestore
  Future<List<String>> _fetchDepartments() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('Masterdata')
        .doc('collections')
        .collection('Departments')
        .get();
    final List<String> departments = ['All Departments'];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['name'] != null) {
        departments.add(data['name']);
      }
    }
    return departments
      ..sort((a, b) => a == 'All Departments' ? -1 : a.compareTo(b));
  }

  // Update the existing _generateAndDownloadCSV function
  void _generateAndDownloadCSV(String department) async {
    setState(() {
      _isGeneratingCSV = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Generating CSV...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("This may take a while..."),
            ],
          ),
        );
      },
    );

    List<List<dynamic>> rows = [
      [
        'Employee Name',
        'Employee Code',
        'Clock In',
        'Clock Out',
        'Start Break',
        'Stop Break',
        'Break Duration',
        'Work Duration',
        'Attendance Date',
        'Department',
      ]
    ];

    // Fetch employees based on department selection
    Query employeesQuery = _firestore.collection('profiles');
    if (department != 'All Departments') {
      employeesQuery =
          employeesQuery.where('department', isEqualTo: department);
    }
    QuerySnapshot employeesSnapshot = await employeesQuery.get();

    for (var doc in employeesSnapshot.docs) {
      Employee userData = Employee.fromMap(doc.data() as Map<String, dynamic>);
      var attendanceSnapshot =
          await doc.reference.collection('attendance').doc(formattedDate).get();

      if (attendanceSnapshot.exists) {
        Attendance attendanceData = Attendance.fromMap(
            attendanceSnapshot.data() as Map<String, dynamic>);
        Duration breakDuration = calculateDuration(
            attendanceData.startBreak, attendanceData.stopBreak);
        Duration totalWorkDuration = calculateDuration(
            attendanceData.clockInTime, attendanceData.clockOutTime);

        rows.add([
          userData.name,
          userData.employeeCode,
          formatTime(attendanceData.clockInTime),
          formatTime(attendanceData.clockOutTime),
          formatTime(attendanceData.startBreak),
          formatTime(attendanceData.stopBreak),
          formatDuration(breakDuration),
          formatDuration(totalWorkDuration),
          formattedDate,
          userData.department,
        ]);
      } else {
        rows.add([
          userData.name,
          userData.employeeCode,
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
          formattedDate,
          userData.department,
        ]);
      }
    }

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "attendance_${formattedDate}.csv")
      ..click();

    html.Url.revokeObjectUrl(url);

    // Close the loading dialog
    Navigator.of(context).pop();

    setState(() {
      _isGeneratingCSV = false;
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'CSV for ${department == 'All Departments' ? 'all departments' : department} generated and downloaded successfully!'),
        duration: const Duration(seconds: 3),
      ),
    );
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
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _isGeneratingCSV
                                  ? null
                                  : _showDepartmentSelectionDialog,
                              child: _isGeneratingCSV
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text("Download CSV"),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
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
                                    flex: 12,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Clock In",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Clock Out",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Start Break",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Stop Break",
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
                            SizedBox(
                              height: 400, // Set a fixed height or use Expanded
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredDocs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Employee userData = Employee.fromMap(
                                      filteredDocs[index].data());
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            child: AttendanceDetails(
                                              employeeName: userData.name,
                                              employeeWorkMail:
                                                  userData.workEmail,
                                              selectedDate: formattedDate,
                                            ),
                                            type: PageTransitionType.fade),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
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
                                            flex: 12,
                                            child:
                                                FutureBuilder<DocumentSnapshot>(
                                              future: filteredDocs[index]
                                                  .reference
                                                  .collection('attendance')
                                                  .doc(formattedDate)
                                                  .get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  if (snapshot.data != null &&
                                                      snapshot.data!.exists) {
                                                    Attendance attendanceData =
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
                                                    String parsedBreakDuration =
                                                        formatDuration(
                                                            breakDuration);
                                                    Duration totalWorkDuration =
                                                        calculateDuration(
                                                            attendanceData
                                                                .clockInTime,
                                                            attendanceData
                                                                .clockOutTime);
                                                    String parsedWorkDuration =
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
                                                          child: Text(formatTime(
                                                              attendanceData
                                                                  .startBreak)),
                                                        ),
                                                        Expanded(
                                                          child: Text(formatTime(
                                                              attendanceData
                                                                  .stopBreak)),
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
                              ),
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
