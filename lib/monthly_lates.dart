import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonthlyLatesScreen extends StatefulWidget {
  @override
  _MonthlyLatesScreenState createState() => _MonthlyLatesScreenState();
}

class _MonthlyLatesScreenState extends State<MonthlyLatesScreen> {
  String selectedMonth =
      DateTime.now().toString().substring(0, 7); // Format: YYYY-MM

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialEntryMode: DatePickerEntryMode.calendarOnly,
              );
              if (picked != null) {
                setState(() {
                  selectedMonth = picked.toString().substring(0, 7);
                });
              }
            },
            child: Text('Select Month: $selectedMonth'),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('profiles').snapshots(),
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
                        lateSnapshot.data?.data() as Map<String, dynamic>? ??
                            {};
                    final records =
                        (lateData['History'] as List<dynamic>? ?? []);
                    final halfDayDeductionCount =
                        lateData['halfDayDeductionCount'] ?? 0;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        title: Text(name),
                        subtitle: Text(
                            'Lates this month: ${halfDayDeductionCount} days'),
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
                                  title: Text(
                                      'Date: ${formatDate(record['date'])}'),
                                  subtitle: Text(
                                      'Status: ${record['status'] ?? 'N/A'}'),
                                );
                              }).toList(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
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
