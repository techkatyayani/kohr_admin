import 'dart:convert';
import 'dart:developer';

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
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _tabController = TabController(length: 2, vsync: this);

    // Set default date range to current day (from 00:00:00)
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectFormattedDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
  }

  Future<void> _selectStartDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: _endDate, // Can't select start date after end date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate, // Can't select end date before start date
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Export Attendance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Department Selection
                    const Text(
                      'Select Department',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDepartment,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: departments.map((String department) {
                            return DropdownMenuItem<String>(
                              value: department,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(department),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDepartment = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date Range Selection
                    const Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date Pickers in Row
                    Row(
                      children: [
                        // Start Date Picker
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context, setState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start Date',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(_startDate),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Spacer between date pickers
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),

                        // End Date Picker
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectEndDate(context, setState),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'End Date',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(_endDate),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Date Selection Buttons
                    Wrap(
                      spacing: 8,
                      children: [
                        _QuickDateButton(
                          label: 'Today',
                          onPressed: () => setState(() {
                            final now = DateTime.now();
                            _startDate = DateTime(now.year, now.month, now.day);
                            _endDate = DateTime(now.year, now.month, now.day);
                          }),
                        ),
                        _QuickDateButton(
                          label: 'Last 7 Days',
                          onPressed: () => setState(() {
                            final now = DateTime.now();
                            _endDate = DateTime(now.year, now.month, now.day);
                            _startDate = DateTime(_endDate.year, _endDate.month,
                                _endDate.day - 6);
                          }),
                        ),
                        _QuickDateButton(
                          label: 'Last 30 Days',
                          onPressed: () => setState(() {
                            final now = DateTime.now();
                            _endDate = DateTime(now.year, now.month, now.day);
                            _startDate = DateTime(_endDate.year, _endDate.month,
                                _endDate.day - 29);
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(_selectedDepartment);
                            _generateAndDownloadCSV(
                                _selectedDepartment!, _startDate, _endDate);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.download),
                          label: const Text('Export CSV'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
  void _generateAndDownloadCSV(
      String department, DateTime startDate, DateTime endDate) async {
    log('Generating CSV for department: $department, startDate: $startDate, endDate: $endDate');
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
        'Attendance Date',
        'Employee Name',
        'Employee Code',
        'Clock In',
        'Clock Out',
        'Start Break',
        'Stop Break',
        'Break Duration',
        'Work Duration',
        'Department',
      ]
    ];

    try {
      // 1. Create sorted date range (newest to oldest)
      List<String> dateRange = [];
      for (DateTime date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        dateRange.add(DateFormat('yyyy-MM-dd').format(date));
      }
      dateRange.sort((a, b) => b.compareTo(a));
      log('Sorted date range: $dateRange');

      // 2. Fetch all employees
      Query employeesQuery =
          _firestore.collection('profiles').orderBy('name', descending: false);
      if (department != 'All Departments') {
        employeesQuery =
            employeesQuery.where('department', isEqualTo: department);
      }
      QuerySnapshot employeesSnapshot = await employeesQuery.get();

      // 3. Create a map of employees for quick lookup
      Map<String, Employee> employeesMap = {};
      for (var doc in employeesSnapshot.docs) {
        employeesMap[doc.id] =
            Employee.fromMap(doc.data() as Map<String, dynamic>);
      }

      // 4. Process each date
      for (String date in dateRange) {
        // Fetch attendance for all employees on this date
        List<Future<DocumentSnapshot>> attendanceFutures = [];
        for (var employeeDoc in employeesSnapshot.docs) {
          attendanceFutures.add(
              employeeDoc.reference.collection('attendance').doc(date).get());
        }

        List<DocumentSnapshot> attendanceResults =
            await Future.wait(attendanceFutures);

        // Process attendance for this date
        for (int i = 0; i < attendanceResults.length; i++) {
          var employeeDoc = employeesSnapshot.docs[i];
          Employee userData = employeesMap[employeeDoc.id]!;
          var attendanceDoc = attendanceResults[i];

          if (attendanceDoc.exists) {
            Attendance attendanceData = Attendance.fromMap(
                attendanceDoc.data() as Map<String, dynamic>);
            Duration breakDuration = calculateDuration(
                attendanceData.startBreak, attendanceData.stopBreak);
            Duration totalWorkDuration = calculateDuration(
                attendanceData.clockInTime, attendanceData.clockOutTime);

            rows.add([
              date,
              userData.name,
              userData.employeeCode,
              formatTime(attendanceData.clockInTime),
              formatTime(attendanceData.clockOutTime),
              formatTime(attendanceData.startBreak),
              formatTime(attendanceData.stopBreak),
              formatDuration(breakDuration),
              formatDuration(totalWorkDuration),
              userData.department,
            ]);
          } else {
            rows.add([
              date,
              userData.name,
              userData.employeeCode,
              '-',
              '-',
              '-',
              '-',
              '-',
              '-',
              userData.department,
            ]);
          }
        }
      }

      // Generate and download CSV
      String csv = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "attendance_${formattedDate}.csv")
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'CSV for ${department == 'All Departments' ? 'all departments' : department} generated successfully!'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating CSV: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      log('Error generating CSV: ${e.toString()}');
    } finally {
      Navigator.of(context).pop(); // Close loading dialog
      setState(() {
        _isGeneratingCSV = false;
      });
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
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.primaryBlue),
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade400),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _selectFormattedDate(context, setState);
                                // _selectStartDate(context, setState);
                              },
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: const Text("Select Date"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
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
                            ElevatedButton.icon(
                              onPressed: _isGeneratingCSV
                                  ? null
                                  : _showDepartmentSelectionDialog,
                              icon: _isGeneratingCSV
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
                                  : const Icon(Icons.download, size: 18),
                              label: const Text("Download CSV"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
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
                                    child: Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 18,
                                            color: AppColors.primaryBlue),
                                        SizedBox(width: 8),
                                        Text(
                                          "Employee Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 12,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.login,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Clock In",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.logout,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Clock Out",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.coffee,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Start Break",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.coffee_outlined,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Stop Break",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.timer,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Break Duration",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.work_history,
                                                  size: 18,
                                                  color: AppColors.primaryBlue),
                                              SizedBox(width: 8),
                                              Text(
                                                "Work Duration",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
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

// Add this widget for quick date selection buttons
class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickDateButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primaryBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(color: AppColors.primaryBlue),
      ),
    );
  }
}
