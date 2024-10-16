import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceDetails extends StatefulWidget {
  final String employeeWorkMail;
  final String employeeName;
  final String selectedDate;

  const AttendanceDetails(
      {super.key,
      required this.employeeWorkMail,
      required this.employeeName,
      required this.selectedDate});

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    formattedDate = widget.selectedDate;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        title: Text(widget.employeeName),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 12, right: 16, top: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Daily Attendance ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "($formattedDate)",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.primaryBlue),
                        height: size.height * .01,
                        width: size.width * .14,
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: const Text("Select Date"),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: firestore
                    .collection('profiles')
                    .doc(widget.employeeWorkMail)
                    .collection('attendance')
                    .doc(formattedDate)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }
                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                    return Center(
                      child:
                          Text("No attendance record found for $formattedDate"),
                    );
                  }

                  Attendance attendanceData = Attendance.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildAttendanceWidgets(attendanceData),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildAttendanceWidgets(Attendance attendanceData) {
    Duration breakDuration =
        calculateDuration(attendanceData.startBreak, attendanceData.stopBreak);
    Duration totalWorkDuration = calculateDuration(
        attendanceData.clockInTime, attendanceData.clockOutTime);
    return [
      buildAttendanceRow("Clock-In ", attendanceData.clockInTime,
          attendanceData.clockInAddress),
      const SizedBox(height: 30),
      buildAttendanceRow("Clock-Out ", attendanceData.clockOutTime,
          attendanceData.clockOutAddress),
      const SizedBox(height: 30),
      buildImageRow("Clock-In Image ", attendanceData.clockInImage),
      const SizedBox(height: 30),
      buildImageRow("Clock-Out Image ", attendanceData.clockOutImage),
      const SizedBox(height: 30),
      buildAttendanceRow("Start-Break-Time ", attendanceData.startBreak,
          attendanceData.startBreakAddress),
      const SizedBox(height: 30),
      buildAttendanceRow("Stop-Break-Time ", attendanceData.stopBreak,
          attendanceData.stopBreakAddress),
      const SizedBox(height: 30),
      buildDurationWidget("Break Duration", formatDuration(breakDuration)),
      const SizedBox(height: 30),
      buildDurationWidget(
          "Total Work Duration", formatDuration(totalWorkDuration)),
    ];
  }

  Widget buildDurationWidget(String label, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                duration,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('h:mm:ss a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  Widget buildAttendanceRow(String label, String time, String address) {
    String parsedTime = formatTime(time);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                parsedTime,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(address),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildImageRow(String label, String imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "$label: ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Image.network(imageUrl, fit: BoxFit.cover),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              "View $label",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
