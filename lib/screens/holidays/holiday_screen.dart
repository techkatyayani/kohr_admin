import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/holidays/add_holiday_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  List<String> departments = [];
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Masterdata')
        .doc('collections')
        .collection('Departments')
        .get();

    setState(() {
      departments = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
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
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Text(
                "Holidays Management",
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
                        Tab(text: "Holidays"),
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
                                hintText: 'Search by holiday name',
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
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddHolidayForm(),
                              ),
                            );
                          },
                          child: Text("Add holiday"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Select Department'),
                                  content: DropdownButton<String>(
                                    value: selectedDepartment,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('All Departments'),
                                      ),
                                      ...departments.map((String department) {
                                        return DropdownMenuItem<String>(
                                          value: department,
                                          child: Text(department),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedDepartment = newValue;
                                      });
                                      Navigator.of(context).pop(newValue);
                                    },
                                  ),
                                );
                              },
                            );

                            if (selected != null) {
                              setState(() {
                                selectedDepartment = selected;
                              });
                            }
                          },
                          child: Text("Select Department"),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('holidays')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final holidays = snapshot.data!.docs.where((holiday) {
                          final holidayData =
                              holiday.data() as Map<String, dynamic>;
                          final title = holidayData['title'].toLowerCase();
                          final date =
                              (holidayData['date'] as Timestamp).toDate();
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);

                          final matchesSearch = title.contains(_searchTerm) ||
                              formattedDate.contains(_searchTerm);
                          final matchesDepartment =
                              selectedDepartment == null ||
                                  (holidayData['departments'] as List<dynamic>)
                                      .contains(selectedDepartment);

                          return matchesSearch && matchesDepartment;
                        }).toList();

                        // Sort holidays by date in ascending order
                        holidays.sort((a, b) {
                          final dateA = (a.data()
                              as Map<String, dynamic>)['date'] as Timestamp;
                          final dateB = (b.data()
                              as Map<String, dynamic>)['date'] as Timestamp;
                          return dateA.compareTo(dateB);
                        });

                        if (holidays.isEmpty) {
                          return Center(child: Text('No holidays present'));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: holidays.length,
                          itemBuilder: (context, index) {
                            final holiday =
                                holidays[index].data() as Map<String, dynamic>;
                            final departments =
                                (holiday['departments'] as List<dynamic>)
                                    .join(', ');

                            // Check if holiday['date'] is not null and is a Timestamp
                            DateTime dateTime;
                            if (holiday['date'] != null &&
                                holiday['date'] is Timestamp) {
                              dateTime =
                                  (holiday['date'] as Timestamp).toDate();
                            } else {
                              // Handle the case where date is null or not a Timestamp
                              dateTime =
                                  DateTime.now(); // or set a default date
                            }

                            // Extracting day, month, and year
                            final day = dateTime.day.toString(); // "15"
                            final month =
                                DateFormat('MMMM').format(dateTime); // "August"
                            final year = dateTime.year.toString(); // "2024"

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            day,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Text(
                                            month,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            year,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              holiday['title'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Departments: $departments',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddHolidayForm(
                                                        holiday: holiday),
                                              ),
                                            );
                                          }),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          // Show confirmation dialog
                                          final shouldDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Confirm Deletion'),
                                                content: Text(
                                                    'Are you sure you want to delete this holiday?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator
                                                            .of(context)
                                                        .pop(false), // Cancel
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator
                                                            .of(context)
                                                        .pop(true), // Confirm
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          // If the user confirmed, delete the holiday
                                          if (shouldDelete == true) {
                                            await FirebaseFirestore.instance
                                                .collection('holidays')
                                                .doc(holiday['id'])
                                                .delete();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
