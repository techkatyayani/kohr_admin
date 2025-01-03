import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/leave.dart';
import 'dart:math' show min;
import 'package:intl/intl.dart';

class MonthlyLatesScreen extends StatefulWidget {
  @override
  _MonthlyLatesScreenState createState() => _MonthlyLatesScreenState();
}

class _MonthlyLatesScreenState extends State<MonthlyLatesScreen> {
  String selectedMonth =
      DateTime.now().toString().substring(0, 7); // Format: YYYY-MM
  String selectedDepartment = 'All';
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  Widget _buildDepartmentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .snapshots(),
      builder: (context, departmentSnapshot) {
        if (!departmentSnapshot.hasData) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        List<String> departments = ['All'];
        departments.addAll(
          departmentSnapshot.data!.docs
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList(),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade100,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDepartment,
              icon: const Icon(Icons.business, size: 20),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
              ),
              items: departments.map((String department) {
                return DropdownMenuItem(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDepartment = newValue ?? 'All';
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: _buildDepartmentDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: selectedDepartment == 'All'
          ? FirebaseFirestore.instance.collection('profiles').snapshots()
          : FirebaseFirestore.instance
              .collection('profiles')
              .where('department', isEqualTo: selectedDepartment)
              .snapshots(),
      builder: (context, profilesSnapshot) {
        if (profilesSnapshot.hasError) {
          return Center(child: Text('Error: ${profilesSnapshot.error}'));
        }

        if (!profilesSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = profilesSnapshot.data!.docs;
        if (searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final profileData = doc.data() as Map<String, dynamic>;
            final name = (profileData['name']?.toString() ?? '').toLowerCase();
            final email = doc.id.toLowerCase();
            return name.contains(searchQuery) || email.contains(searchQuery);
          }).toList();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final profile = docs[index];
            final profileData = profile.data() as Map<String, dynamic>;
            final workEmail = profile.id;
            final name = profileData['name']?.toString() ?? 'No Name';

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('profiles')
                  .doc(workEmail)
                  .collection('monthly_lates')
                  .doc(selectedMonth)
                  .snapshots(),
              builder: (context, lateSnapshot) {
                // Show card even if there's no late data
                final lateData =
                    lateSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final records = (lateData['History'] as List<dynamic>? ?? []);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        // Avatar/Icon for the user
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          radius: 20,
                          child: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // User details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Days Count: ${lateData['count'] ?? 0} | Days Deductions: ${lateData['halfDayDeductionCount'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    workEmail,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Manage Leaves button
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showManageLeavesDialog(
                                  context, workEmail, name, lateData);
                            },
                            icon: const Icon(Icons.edit_calendar, size: 18),
                            label: const Text('Manage'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showHistoryDialog(context, workEmail, name);
                            },
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text('History'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Late records list
                    children: records.isEmpty
                        ? [
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.info_outline,
                                  color: Colors.grey),
                              title: Text(
                                'No late records this month',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          ]
                        : records.map<Widget>((record) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.access_time, size: 20),
                              title:
                                  Text('Date: ${formatDate(record['date'])}'),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.lens,
                                    size: 8,
                                    color: record['status'] == 'Approved'
                                        ? Colors.green
                                        : record['status'] == 'Pending'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Status: ${record['status'] ?? 'N/A'}'),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String formatDate(String dateTimeString) {
    try {
      // Parse the timestamp string
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Format to something like "Dec 21, 2024 10:20 AM"
      String month = _getMonthName(dateTime.month);
      String day = dateTime.day.toString();
      String year = dateTime.year.toString();
      String time = _formatTime(dateTime.hour, dateTime.minute);

      return "$month $day, $year $time";
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour;
    final minutes = minute.toString().padLeft(2, '0');
    return '$hour:$minutes $period';
  }

  List<String> _generateMonthOptions() {
    List<String> months = [];
    DateTime now = DateTime.now();
    DateTime date = DateTime(2020); // Starting from 2020

    while (date.isBefore(now) ||
        date.year == now.year && date.month <= now.month) {
      String monthStr = date.toString().substring(0, 7); // YYYY-MM format
      months.add(monthStr);
      date = DateTime(date.year, date.month + 1);
    }
    return months.reversed.toList(); // Most recent months first
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {}, // Handle tap if needed
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              items: _generateMonthOptions().map((month) {
                                final date = DateTime.parse('$month-01');
                                final formattedDate =
                                    '${_getFullMonthName(date.month)} ${date.year}';

                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMonth = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildSearchBar(),
        _buildProfilesList(),
      ],
    );
  }

  // Add this helper method for full month names
  String _getFullMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showManageLeavesDialog(BuildContext context, String email, String name,
      Map<String, dynamic> lateData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage Leaves',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff09254A),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                // Stats Card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Days Count',
                        '${lateData['count'] ?? 0}',
                        Icons.calendar_today,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      _buildStatItem(
                        context,
                        ' Days Deductions',
                        '${lateData['halfDayDeductionCount'] ?? 0}',
                        Icons.remove_circle_outline,
                      ),
                    ],
                  ),
                ),

                // Leave Data
                Flexible(
                  child: FutureBuilder<Map<String, Leave>>(
                    future: FirestoreService().fetchLeaveData(email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No leave data available'),
                        );
                      }

                      final leaveData = snapshot.data!;
                      // Create an ordered list of leave types
                      final orderedLeaveTypes = [
                        'thisMonthCasualLeaves',
                        'thisMonthSickLeaves',
                        'leaveWithoutPay',
                      ];

                      return SingleChildScrollView(
                        child: Column(
                          children: orderedLeaveTypes.map((leaveType) {
                            if (!leaveData.containsKey(leaveType))
                              return const SizedBox.shrink();

                            final leave = leaveData[leaveType]!;
                            final titleMap = {
                              'thisMonthCasualLeaves': 'Casual Leave',
                              'thisMonthSickLeaves': 'Sick Leave',
                              'leaveWithoutPay': 'Leave Without Pay',
                            };
                            String title = titleMap[leaveType] ?? leaveType;
                            String balanceDisplay = leaveType ==
                                    'leaveWithoutPay'
                                ? '∞'
                                : (leave.accrued - leave.used - leave.requested)
                                    .toStringAsFixed(1);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: const Color(0xff09254A),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getLeaveTypeIcon(leaveType),
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '$title (days)',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildLeaveDetail(
                                          'Accrued',
                                          leave.accruedDisplay,
                                        ),
                                        _buildLeaveDetail(
                                          'Used',
                                          leave.used.toStringAsFixed(1),
                                        ),
                                        _buildLeaveDetail(
                                          'Requested',
                                          leave.requested.toStringAsFixed(1),
                                        ),
                                        _buildLeaveDetail(
                                          'Balance',
                                          balanceDisplay,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),

                // Add hint text
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff09254A).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xff09254A).withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16,
                          color: const Color(0xff09254A).withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xff09254A).withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                            children: [
                              TextSpan(
                                text: 'Hint: Leave Priority',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff09254A),
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' - Casual Leave → Sick Leave → Leave Without Pay',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add buttons
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff09254A),
                        side: const BorderSide(color: Color(0xff09254A)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final leaveData =
                            await FirestoreService().fetchLeaveData(email);
                        _handleConversion(
                          context,
                          email,
                          lateData,
                          leaveData,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff09254A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  IconData _getLeaveTypeIcon(String leaveType) {
    switch (leaveType) {
      case 'thisMonthSickLeaves':
        return Icons.medical_services_outlined;
      case 'leaveWithoutPay':
        return Icons.money_off_outlined;
      case 'thisMonthCasualLeaves':
        return Icons.beach_access_outlined;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  Widget _buildLeaveDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConversion(BuildContext context, String email,
      Map<String, dynamic> lateData, Map<String, Leave> leaveData) async {
    double deductionsRemaining =
        (lateData['halfDayDeductionCount'] ?? 0).toDouble();
    if (deductionsRemaining <= 0) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Conversion'),
          content: Text(
            'Are you sure you want to convert $deductionsRemaining day(s) into leaves? This action cannot be undone.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff09254A),
              ),
              child: const Text('Convert'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    Map<String, double> updates = {};

    // Check Casual Leave
    if (deductionsRemaining > 0 &&
        leaveData.containsKey('thisMonthCasualLeaves')) {
      final casualLeave = leaveData['thisMonthCasualLeaves']!;
      final availableCasual =
          casualLeave.accrued - casualLeave.used - casualLeave.requested;
      if (availableCasual > 0) {
        final deductionsToConvert = min(deductionsRemaining, availableCasual);
        updates['thisMonthCasualLeaves'] =
            casualLeave.used + deductionsToConvert;
        deductionsRemaining -= deductionsToConvert;
      }
    }

    // Check Sick Leave
    if (deductionsRemaining > 0 &&
        leaveData.containsKey('thisMonthSickLeaves')) {
      final sickLeave = leaveData['thisMonthSickLeaves']!;
      final availableSick =
          sickLeave.accrued - sickLeave.used - sickLeave.requested;
      if (availableSick > 0) {
        final deductionsToConvert = min(deductionsRemaining, availableSick);
        updates['thisMonthSickLeaves'] = sickLeave.used + deductionsToConvert;
        deductionsRemaining -= deductionsToConvert;
      }
    }

    // Remaining goes to Leave Without Pay
    if (deductionsRemaining > 0) {
      final lwp = leaveData['leaveWithoutPay'] ??
          Leave(
              accrued: double.infinity,
              used: 0,
              requested: 0,
              accruedDisplay: '∞');
      updates['leaveWithoutPay'] = lwp.used + deductionsRemaining;
      deductionsRemaining = 0;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final timestamp = FieldValue.serverTimestamp();

      // Create conversion history document
      batch.set(
        FirebaseFirestore.instance
            .collection('profiles')
            .doc(email)
            .collection('daysDeduction')
            .doc(), // Auto-generate ID
        {
          'date': timestamp,
          'originalCount': lateData['count'],
          'deductionCount': lateData['halfDayDeductionCount'],
          'month': selectedMonth,
          'convertedLeaves': updates.map((key, value) => MapEntry(key, {
                'leaveType': key,
                'daysDeducted': value - (leaveData[key]?.used ?? 0),
              })),
          'status': 'converted',
        },
      );

      // Update leave counts
      for (var entry in updates.entries) {
        batch.update(
          FirebaseFirestore.instance
              .collection('profiles')
              .doc(email)
              .collection('leaveBalances')
              .doc(entry.key),
          {'used': entry.value},
        );
      }

      // Reset deduction count and update status
      batch.update(
        FirebaseFirestore.instance
            .collection('profiles')
            .doc(email)
            .collection('monthly_lates')
            .doc(selectedMonth),
        {
          'halfDayDeductionCount': 0,
          'status': 'converted',
          'convertedAt': timestamp,
        },
      );

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully converted deductions to leaves'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close the manage leaves dialog
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add this method to show history dialog
  void _showHistoryDialog(BuildContext context, String email, String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave Deduction History - $name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff09254A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('profiles')
                        .doc(email)
                        .collection('daysDeduction')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No deduction history found',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final date = data['date'] as Timestamp?;
                          final convertedLeaves =
                              data['convertedLeaves'] as Map?;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        color: Color(0xff09254A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        date != null
                                            ? DateFormat('MMMM dd, yyyy')
                                                .format(date.toDate())
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Month: ${_formatMonth(data['month'] ?? 'N/A')}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildInfoItem(
                                              'Late Days',
                                              '${data['originalCount'] ?? 0}',
                                              Icons.timer,
                                            ),
                                            const SizedBox(width: 24),
                                            _buildInfoItem(
                                              'Deductions',
                                              '${data['deductionCount'] ?? 0}',
                                              Icons.remove_circle_outline,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (convertedLeaves != null) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Converted to:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff09254A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...convertedLeaves.entries.map((e) {
                                      final details = e.value as Map;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.arrow_right,
                                              size: 20,
                                              color: Color(0xff09254A),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_formatLeaveType(e.key)}: ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${details['daysDeducted']} day(s)',
                                              style: const TextStyle(
                                                color: Color(0xff09254A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatMonth(String monthStr) {
    try {
      final date = DateTime.parse('$monthStr-01');
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return monthStr;
    }
  }

  // Add this helper method
  String _formatLeaveType(String key) {
    switch (key) {
      case 'thisMonthSickLeaves':
        return 'Sick Leave';
      case 'leaveWithoutPay':
        return 'Leave Without Pay';
      case 'thisMonthCasualLeaves':
        return 'Casual Leave';
      default:
        return key;
    }
  }
}

class MonthDetailScreen extends StatelessWidget {
  final String email;
  final String month;

  const MonthDetailScreen({
    required this.email,
    required this.month,
    Key? key,
  }) : super(key: key);

  // Helper function to format time
  String formatTimeToAMPM(String? timeString) {
    if (timeString == null || timeString.isEmpty) return 'N/A';
    try {
      // Assuming timeString is in 24-hour format (HH:mm)
      final timeParts = timeString.split(':');
      int hours = int.parse(timeParts[0]);
      final minutes = timeParts[1];
      final period = hours >= 12 ? 'PM' : 'AM';

      // Convert to 12-hour format
      hours = hours > 12 ? hours - 12 : hours;
      hours = hours == 0 ? 12 : hours;

      return '$hours:$minutes $period';
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('profiles')
          .doc(email)
          .collection('monthly_lates')
          .doc(month)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Center(child: Text('No records found'));
        }

        // Convert the records map to a list of entries for sorting
        final records = (data['records'] as List<dynamic>? ?? [])
            .map((record) => record as Map<String, dynamic>)
            .toList();

        // Sort records by date
        records.sort(
            (a, b) => (a['date'] as String).compareTo(b['date'] as String));

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Date: ${record['date']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time In: ${formatTimeToAMPM(record['timeIn'])}'),
                    Text('Late Duration: ${record['lateDuration'] ?? 'N/A'}'),
                    if (record['reason'] != null)
                      Text('Reason: ${record['reason']}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
