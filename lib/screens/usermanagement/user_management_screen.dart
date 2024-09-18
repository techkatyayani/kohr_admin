import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/screens/usermanagement/add_user.dart';
import 'package:kohr_admin/screens/usermanagement/user_details_screen.dart';
import 'package:page_transition/page_transition.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

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

  Future<void> importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) {
        log("No file selected.");
        return;
      }

      var bytes = result.files.first.bytes;
      if (bytes == null) {
        log("File selection failed, no file content available.");
        return;
      }

      var excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        log("Excel file is empty or not readable.");
        return;
      }

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) {
          log("Error reading sheet: $table");
          continue;
        }

        for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          var row = sheet.row(rowIndex);
          log(rowIndex.toString());

          if (row.isEmpty) {
            log("Row $rowIndex is empty or null.");
            continue;
          }

          String workEmail = row[55]?.value.toString() ?? "";

          User? firebaseUser;

          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: workEmail,
              password: row[75]?.value.toString() ?? 'KOHR123',
            );
            firebaseUser = userCredential.user;
            log("User signed up with email: $workEmail");
          } catch (signUpError) {
            log("Sign up failed, trying to log in: $signUpError");
            log("Error signing in: $signUpError");
            await FirebaseFirestore.instance.collection('Exceptions').add({
              'workMail': workEmail,
              'error': signUpError.toString(),
            });
            continue;
          }

          if (firebaseUser == null) {
            log("Error creating or logging in user for email: $workEmail");
            continue;
          }

          String currentUserUid = firebaseUser.uid;

          Map<String, dynamic> userData = {
            "firstName": row[0]?.value.toString() ?? "",
            "middleName": row[1]?.value.toString() ?? "",
            "lastName": row[2]?.value.toString() ?? "",
            "employeeCode": row[3]?.value.toString() ?? "",
            "name": row[0]?.value.toString() ?? "",
            "gender": row[6]?.value.toString() ?? "",
            "birthday": row[7]?.value.toString() ?? "",
            "fatherName": row[8]?.value.toString() ?? "",
            "age": row[10]?.value.toString() ?? "",
            "email": row[24]?.value.toString() ?? "",
            "countryCode": row[25]?.value.toString() ?? "",
            "mobile": row[26]?.value.toString() ?? "",
            "bankName": row[34]?.value.toString() ?? "",
            "ifscCode": row[35]?.value.toString() ?? "",
            "bankAccountNumber": row[37]?.value.toString() ?? "",
            "aadharNumber": row[45]?.value.toString() ?? "",
            "location": row[49]?.value.toString() ?? "",
            "department": row[54]?.value.toString() ?? "",
            "workEmail": workEmail,
            "employeeType": row[56]?.value.toString() ?? "",
            "joiningData": row[57]?.value.toString() ?? "",
            "workExperience": row[59]?.value.toString() ?? "",
            "reportingManager": row[60]?.value.toString() ?? "",
            "probationPeriod": row[61]?.value.toString() ?? "",
            "confirmationData": row[62]?.value.toString() ?? "",
            "noticeDuringProbation": row[63]?.value.toString() ?? "",
            "noticePostProbation": row[64]?.value.toString() ?? "",
            "noticePeriod": row[65]?.value.toString() ?? "",
            "retirementAge": row[67]?.value.toString() ?? "",
            "reportingManagerCode": row[71]?.value.toString() ?? "",
            "employeeStatus": row[74]?.value.toString() ?? "",
            "id": currentUserUid,
            "companyName": row[76]?.value.toString() ?? ""
          };

          log("Mapped userData: $userData");

          try {
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(workEmail)
                .set(userData);
            log("Successfully added userData to Firestore.");
          } catch (firestoreError) {
            log("Error adding data to Firestore: $firestoreError");
          }
        }
      }
    } catch (e, stackTrace) {
      log("An error occurred: $e");
      log("Stacktrace: $stackTrace");
    }
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
                "User Management",
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
                        Tab(text: 'Summary'),
                        Tab(text: 'Dashboard'),
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
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await importExcel();
                          },
                          child: const Text("Import Sheet"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const AddUserScreen(),
                                    type: PageTransitionType.fade));
                          },
                          child: const Text("Add User"),
                        ),
                        const SizedBox(width: 30)
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('profiles')
                          .orderBy('name', descending: false)
                          .snapshots(),
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
                          var userData = doc.data() as Map<String, dynamic>;
                          var name =
                              userData['name']?.toString().toLowerCase() ?? '';
                          return name.contains(_searchTerm);
                        }).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Total Strength: ${filteredDocs.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                var userData = filteredDocs[index].data()
                                    as Map<String, dynamic>;
                                bool isHovered = false;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                child:
                                                    const UserDetailsScreen(),
                                                type: PageTransitionType.fade));
                                      },
                                      onHover: (hovering) {
                                        setState(() {
                                          isHovered = hovering;
                                        });
                                      },
                                      child: Container(
                                        color: isHovered
                                            ? Colors.grey[300]
                                            : Colors.transparent,
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: AppColors.grey,
                                            backgroundImage: AssetImage(
                                                'assets/images/profile.jpg'),
                                          ),
                                          title: Text(
                                              userData['name'] ?? "No Name"),
                                          subtitle: Text(
                                              userData['employeeType'] ??
                                                  "No Department"),
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
