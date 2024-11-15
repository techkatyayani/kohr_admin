import 'package:Kohr_Admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageLeavesScreen extends StatefulWidget {
  const ManageLeavesScreen({super.key});

  @override
  State<ManageLeavesScreen> createState() => _ManageLeavesScreenState();
}

class _ManageLeavesScreenState extends State<ManageLeavesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manage Leaves",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            DateTimeRange? picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDateRange: _selectedDateRange,
                              useRootNavigator:
                                  false, // Prevent full-screen mode
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDateRange = picked;
                              });
                            }
                          },
                          child: Text(_selectedDateRange == null
                              ? 'Select Date Range'
                              : '${DateFormat('dd-MMM-yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd-MMM-yyyy').format(_selectedDateRange!.end)}'),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    SizedBox(
                      height: 50,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryBlue,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'Leave Requests'),
                          Tab(text: 'User'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchTerm = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by Employee Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * .7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLeaveRequests(),
                          // _buildUserList(),
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
    );
  }

  // Helper function to format date and time
  String formatDateTimeWithTime(DateTime dateTime) {
    String formattedDate = DateFormat('d MMM yyyy').format(dateTime);
    return formattedDate;
  }

  // Helper function to format leave type
  String getFormattedLeaveType(String leaveType) {
    if (leaveType == 'thisMonthSickLeaves') {
      return 'Sick Leave';
    } else if (leaveType == 'thisMonthCasualLeaves') {
      return 'Casual Leave';
    } else if (leaveType == 'leaveWithoutPay') {
      return 'Leave Without Pay';
    } else {
      return 'Unknown Leave Type'; // Default case if no match
    }
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching users."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        var users = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          var name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(_searchTerm);
        }).toList();

        if (users.isEmpty) {
          return const Center(child: Text("No records available."));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(user['name']),
              subtitle: Text(user['workEmail']),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaveRequests() {
    return Container(
      color: AppColors.greyBackground,
      child: StreamBuilder<QuerySnapshot>(
        stream: (_selectedDateRange != null)
            ? _firestore
                .collection('leaveRequests')
                .where('requestTime',
                    isGreaterThanOrEqualTo:
                        Timestamp.fromDate(_selectedDateRange!.start))
                .where('requestTime',
                    isLessThanOrEqualTo:
                        Timestamp.fromDate(_selectedDateRange!.end))
                .orderBy('requestTime',
                    descending: true) // Order by requestTime
                .snapshots()
            : _firestore
                .collection('leaveRequests')
                .orderBy('requestTime',
                    descending:
                        true) // Always order by requestTime when no date range is selected
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching leave requests."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No leave requests found."));
          }

          var leaveRequests = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            var employeeName =
                data['employeeName']?.toString().toLowerCase() ?? '';
            return employeeName.contains(_searchTerm);
          }).toList();

          if (leaveRequests.isEmpty) {
            return const Center(child: Text("No records available."));
          }

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (BuildContext context, int index) {
              var leaveRequest =
                  leaveRequests[index].data() as Map<String, dynamic>;

              String startDate = leaveRequest['startDate'];
              String endDate = leaveRequest['endDate'];

              DateTime startDateTime = DateTime.parse(startDate);
              DateTime endDateTime = DateTime.parse(endDate);

              Timestamp requestTimestamp = leaveRequest['requestTime'];
              DateTime requestDateTime = requestTimestamp.toDate();

              String formattedRequestTime =
                  formatDateTimeWithTime(requestDateTime);
              String formattedStartDate =
                  DateFormat('dd-MMM-yyyy').format(startDateTime);
              String formattedEndDate =
                  DateFormat('dd-MMM-yyyy').format(endDateTime);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${leaveRequest['employeeName']}',
                                style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Requested On',
                                style: TextStyle(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(formattedRequestTime),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.description,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                getFormattedLeaveType(
                                    leaveRequest['leaveType']),
                                style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Row(
                            children: [
                              Text(
                                '$formattedStartDate - $formattedEndDate ',
                              ),
                              Text(
                                " ${leaveRequest['dayOption']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " (${leaveRequest['daysRequested']} Day)",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.comment,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Message -  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${leaveRequest['comment']}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: leaveRequest['status'] == "Rejected"
                                      ? Colors.red
                                      : leaveRequest['status'] == "Approved"
                                          ? Colors.green
                                          : AppColors.primaryBlue,
                                  width: 2),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Status: ${leaveRequest['status']}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          leaveRequest['status'] == 'Pending'
                              ? Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _showConfirmationDialog(
                                            leaveRequests[index].id,
                                            "Approved",
                                            leaveRequest['email'],
                                            leaveRequest['leaveType'],
                                            leaveRequest['daysRequested']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        print(leaveRequest['daysRequested']);
                                        _showConfirmationDialog(
                                            leaveRequests[index].id,
                                            "Rejected",
                                            leaveRequest['email'],
                                            leaveRequest['leaveType'],
                                            leaveRequest['daysRequested']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to show confirmation dialog before updating the status
  void _showConfirmationDialog(String documentId, String status,
      String employeeEmail, String leaveType, num daysRequested) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm $status"),
          content: Text("Are you sure you want to $status this leave request?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                _updateLeaveStatus(documentId, status, employeeEmail, leaveType,
                    daysRequested);
                Navigator.of(context)
                    .pop(); // Close the dialog after confirmation
              },
            ),
          ],
        );
      },
    );
  }

  // Function to update leave status in Firestore
  void _updateLeaveStatus(String documentId, String status,
      String employeeEmail, String leaveType, num daysRequested) async {
    await _firestore
        .collection('leaveRequests')
        .doc(documentId)
        .update({'status': status});

    DocumentReference profileRef = _firestore
        .collection('profiles')
        .doc(employeeEmail)
        .collection('leaveBalances')
        .doc(leaveType);

    // Get the current leave balance
    DocumentSnapshot leaveBalanceSnapshot = await profileRef.get();
    if (leaveBalanceSnapshot.exists) {
      num currentRequested =
          leaveBalanceSnapshot['requested'] ?? 0; // Get the days requested
      num currentUsed = leaveBalanceSnapshot['used'] ?? 0; // Get the days used
      num currentAccrued =
          leaveBalanceSnapshot['accrued'] ?? 0; // Get the days accrued

      if (status == "Rejected") {
        // Subtract the days requested from the current requested balance
        await profileRef
            .update({'requested': currentRequested - daysRequested});
      } else if (status == "Approved") {
        // Subtract from requested, add to used, and deduct from accrued
        await profileRef.update({
          'requested': currentRequested - daysRequested,
          'used': currentUsed + daysRequested,
          // 'accrued': currentAccrued - daysRequested,
        });
      }
    }
  }
}
