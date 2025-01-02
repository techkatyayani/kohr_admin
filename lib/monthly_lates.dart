import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonthlyLatesScreen extends StatefulWidget {
  @override
  _MonthlyLatesScreenState createState() => _MonthlyLatesScreenState();
}

class _MonthlyLatesScreenState extends State<MonthlyLatesScreen> {
  String selectedMonth =
      DateTime.now().toString().substring(0, 7); // Format: YYYY-MM
  String selectedDepartment = 'All';

  Widget _buildDepartmentDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .snapshots(),
      builder: (context, departmentSnapshot) {
        if (!departmentSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<String> departments = ['All'];
        departments.addAll(
          departmentSnapshot.data!.docs
              .map((doc) =>
                  (doc.data() as Map<String, dynamic>)['name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList(),
        );

        return DropdownButton<String>(
          value: selectedDepartment,
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
        );
      },
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

        return ListView.builder(
          shrinkWrap: true,
          itemCount: profilesSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final profile = profilesSnapshot.data!.docs[index];
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
                final halfDayDeductionCount =
                    lateData['halfDayDeductionCount'] ?? 0;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ExpansionTile(
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Half-day deductions: ${halfDayDeductionCount} days'),
                        Text(
                            'Full-day deductions: ${lateData['fullDayDeductionCount'] ?? 0} days'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Status: ${lateData['status'] ?? 'Pending'}',
                              style: TextStyle(
                                color: lateData['status'] == 'approved'
                                    ? Colors.green
                                    : lateData['status'] == 'rejected'
                                        ? Colors.red
                                        : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: lateData['status'] == 'approved'
                                    ? null
                                    : () async {
                                        await FirebaseFirestore.instance
                                            .collection('profiles')
                                            .doc(workEmail)
                                            .collection('monthly_lates')
                                            .doc(selectedMonth)
                                            .update({'status': 'approved'});
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: lateData['status'] == 'rejected'
                                    ? null
                                    : () async {
                                        await FirebaseFirestore.instance
                                            .collection('profiles')
                                            .doc(workEmail)
                                            .collection('monthly_lates')
                                            .doc(selectedMonth)
                                            .update({'status': 'rejected'});
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: records.isEmpty
                        ? [
                            ListTile(
                              dense: true,
                              title: Text('No late records this month'),
                            )
                          ]
                        : records.map<Widget>((record) {
                            return ListTile(
                              dense: true,
                              title:
                                  Text('Date: ${formatDate(record['date'])}'),
                              subtitle:
                                  Text('Status: ${record['status'] ?? 'N/A'}'),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildDepartmentDropdown(),
        ),
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
