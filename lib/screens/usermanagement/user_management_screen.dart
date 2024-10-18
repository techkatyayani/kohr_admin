import 'dart:convert';
import 'dart:developer';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:Kohr_Admin/constants.dart';
import 'package:Kohr_Admin/screens/usermanagement/add_user.dart';
import 'package:Kohr_Admin/screens/usermanagement/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:page_transition/page_transition.dart';
import 'package:Kohr_Admin/models/employee_model.dart';

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
  bool _isGeneratingCSV = false;
  String? _selectedDepartment = 'All Departments';
  final Map<String, bool> _selectedFields = {
    'Name': true,
    'Employee Code': true,
    'Work Email': true,
    'Personal Email': true,
    'Department': true,
    'Employee Type': true,
    'Joining Date': true,
    'Mobile': true,
    'Location': true,
    'Gender': true,
    'Birthday': true,
    'Father Name': true,
    'Blood Group': true,
    'Aadhar Number': true,
    'PAN Card Number': true,
    'Bank Name': true,
    'Bank Account Number': true,
    'IFSC Code': true,
    'Reporting Manager': true,
    'Probation Period': true,
    'Confirmation Date': true,
    'Notice Period': true,
    'Retirement Age': true,
    'Work Experience': true,
    'Work Mode': true,
    'Gross Salary': true,
    'CTC': true,
    'Age': true,
    'Country Code': true,
    'Phone Number': true,
    'Employee Status': true,
    'First Name': true,
    'Middle Name': true,
    'Last Name': true,
    'Home Phone Number': true,
    'Permanent Address': true,
    'Correspondence Address': true,
    'Notice During Probation': true,
    'Notice Post Probation': true,
    'Reporting Manager Code': true,
    'Health Insurance Policy': true,
    'Health Insurance Premium': true,
    'Accidental Insurance Policy': true,
    'Anniversary': true,
    'Family Name': true,
    'Family Relationship': true,
    'Family Date of Birth': true,
    'Family Contact': true,
    'Family Address': true,
    'Degree': true,
    'Specialization': true,
    'College': true,
    'Degree Time': true,
    'Experience Title': true,
    'Experience Location': true,
    'Experience Time': true,
    'Experience Description': true,
    'Card Number': true,
    'Beneficiary Name': true,
    'Contract Period': true,
    'Tenure Last Date': true,
    'Retirement Date': true,
  };

  final Map<String, bool> _importSelectedFields = {
    'Name': true,
    'Employee Code': true,
    'Work Email': true,
    'Personal Email': true,
    'Department': true,
    'Employee Type': true,
    'Joining Date': true,
    'Mobile': true,
    'Location': true,
    'Gender': true,
    'Birthday': true,
    'Father Name': true,
    'Blood Group': true,
    'Aadhar Number': true,
    'PAN Card Number': true,
    'Bank Name': true,
    'Bank Account Number': true,
    'IFSC Code': true,
    'Reporting Manager': true,
    'Probation Period': true,
    'Confirmation Date': true,
    'Notice Period': true,
    'Retirement Age': true,
    'Work Experience': true,
    'Work Mode': true,
    'Gross Salary': true,
    'CTC': true,
    'Age': true,
    'Country Code': true,
    'Phone Number': true,
    'Employee Status': true,
    'First Name': true,
    'Middle Name': true,
    'Last Name': true,
    'Home Phone Number': true,
    'Permanent Address': true,
    'Correspondence Address': true,
    'Notice During Probation': true,
    'Notice Post Probation': true,
    'Reporting Manager Code': true,
    'Health Insurance Policy': true,
    'Health Insurance Premium': true,
    'Accidental Insurance Policy': true,
    'Anniversary': true,
    'Family Name': true,
    'Family Relationship': true,
    'Family Date of Birth': true,
    'Family Contact': true,
    'Family Address': true,
    'Degree': true,
    'Specialization': true,
    'College': true,
    'Degree Time': true,
    'Experience Title': true,
    'Experience Location': true,
    'Experience Time': true,
    'Experience Description': true,
    'Card Number': true,
    'Beneficiary Name': true,
    'Contract Period': true,
    'Tenure Last Date': true,
    'Retirement Date': true,
  };

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
            "name": "${row[0]!.value} ${row[2]!.value}",
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

  void sendMail(String recipientMail, String mailMessage) async {
    String username = 'guptasaksham3071@gmail.com';
    String password = 'dypufytwvbacaeif';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientMail)
      ..subject = 'Mail'
      ..text = 'Message $mailMessage';
    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email send successfully")));
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email not send because $e")));
    }
  }

  Future<void> _showDepartmentAndFieldSelectionDialog() async {
    final departments = await _fetchDepartments();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Export'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Department:'),
                    DropdownButton<String>(
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
                    const SizedBox(height: 20),
                    const Text('Select Fields:'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFields.updateAll((key, value) => true);
                            });
                          },
                          child: const Text('Select All'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFields.updateAll((key, value) => false);
                            });
                          },
                          child: const Text('Deselect All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._selectedFields.entries.map((entry) {
                      return CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedFields[entry.key] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Generate CSV'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _generateAndDownloadCSV(_selectedDepartment!, _selectedFields);
    }
  }

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

  void _generateAndDownloadCSV(
      String department, Map<String, bool> selectedFields) async {
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
      selectedFields.entries.where((e) => e.value).map((e) => e.key).toList(),
    ];

    Query employeesQuery = _firestore.collection('profiles');
    if (department != 'All Departments') {
      employeesQuery =
          employeesQuery.where('department', isEqualTo: department);
    }
    QuerySnapshot employeesSnapshot = await employeesQuery.get();

    for (var doc in employeesSnapshot.docs) {
      Employee employee = Employee.fromMap(doc.data() as Map<String, dynamic>);
      List<dynamic> row = [];
      if (selectedFields['Name']!) row.add(employee.name);
      if (selectedFields['Employee Code']!) row.add(employee.employeeCode);
      if (selectedFields['Work Email']!) row.add(employee.workEmail);
      if (selectedFields['Personal Email']!) row.add(employee.personalEmail);
      if (selectedFields['Department']!) row.add(employee.department);
      if (selectedFields['Employee Type']!) row.add(employee.employeeType);
      if (selectedFields['Joining Date']!) row.add(employee.joiningDate);
      if (selectedFields['Mobile']!) row.add(employee.mobile);
      if (selectedFields['Location']!) row.add(employee.location);
      if (selectedFields['Gender']!) row.add(employee.gender);
      if (selectedFields['Birthday']!) row.add(employee.birthday);
      if (selectedFields['Father Name']!) row.add(employee.fatherName);
      if (selectedFields['Blood Group']!) row.add(employee.bloodGroup);
      if (selectedFields['Aadhar Number']!) row.add(employee.aadharNumber);
      if (selectedFields['PAN Card Number']!) row.add(employee.panCardNumber);
      if (selectedFields['Bank Name']!) row.add(employee.bankName);
      if (selectedFields['Bank Account Number']!)
        row.add(employee.bankAccountNumber);
      if (selectedFields['IFSC Code']!) row.add(employee.ifscCode);
      if (selectedFields['Reporting Manager']!)
        row.add(employee.reportingManager);
      if (selectedFields['Probation Period']!)
        row.add(employee.probationPeriod);
      if (selectedFields['Confirmation Date']!)
        row.add(employee.confirmationDate);
      if (selectedFields['Notice Period']!) row.add(employee.noticePeriod);
      if (selectedFields['Retirement Age']!) row.add(employee.retirementAge);
      if (selectedFields['Work Experience']!) row.add(employee.workExperience);
      if (selectedFields['Work Mode']!) row.add(employee.workMode);
      if (selectedFields['Gross Salary']!) row.add(employee.grossSalary);
      if (selectedFields['CTC']!) row.add(employee.ctc);
      if (selectedFields['Age']!) row.add(employee.age);
      if (selectedFields['Country Code']!) row.add(employee.countryCode);
      if (selectedFields['Phone Number']!) row.add(employee.phoneNumber);
      if (selectedFields['Employee Status']!) row.add(employee.employeeStatus);
      if (selectedFields['First Name']!) row.add(employee.firstName);
      if (selectedFields['Middle Name']!) row.add(employee.middleName);
      if (selectedFields['Last Name']!) row.add(employee.lastName);
      if (selectedFields['Home Phone Number']!)
        row.add(employee.homePhoneNumber);
      if (selectedFields['Permanent Address']!)
        row.add(employee.permanentAddress);
      if (selectedFields['Correspondence Address']!)
        row.add(employee.correspondenceAddress);
      if (selectedFields['Notice During Probation']!)
        row.add(employee.noticeDuringProbation);
      if (selectedFields['Notice Post Probation']!)
        row.add(employee.noticePostProbation);
      if (selectedFields['Reporting Manager Code']!)
        row.add(employee.reportingManagerCode);
      if (selectedFields['Health Insurance Policy']!)
        row.add(employee.healthInsurancePolicy);
      if (selectedFields['Health Insurance Premium']!)
        row.add(employee.healthInsurancePremium);
      if (selectedFields['Accidental Insurance Policy']!)
        row.add(employee.accidentalInsurancePolicy);
      if (selectedFields['Anniversary']!) row.add(employee.anniversary);
      if (selectedFields['Family Name']!) row.add(employee.familyName);
      if (selectedFields['Family Relationship']!)
        row.add(employee.familyRelationship);
      if (selectedFields['Family Date of Birth']!)
        row.add(employee.familyDateOfBirth);
      if (selectedFields['Family Contact']!) row.add(employee.familyContact);
      if (selectedFields['Family Address']!) row.add(employee.familyAddress);
      if (selectedFields['Degree']!) row.add(employee.degree);
      if (selectedFields['Specialization']!) row.add(employee.specialization);
      if (selectedFields['College']!) row.add(employee.college);
      if (selectedFields['Degree Time']!) row.add(employee.degreeTime);
      if (selectedFields['Experience Title']!)
        row.add(employee.experienceTitle);
      if (selectedFields['Experience Location']!)
        row.add(employee.experienceLocation);
      if (selectedFields['Experience Time']!) row.add(employee.experienceTime);
      if (selectedFields['Experience Description']!)
        row.add(employee.experienceDescription);
      if (selectedFields['Card Number']!) row.add(employee.cardNumber);
      if (selectedFields['Beneficiary Name']!)
        row.add(employee.beneficiaryName);
      if (selectedFields['Contract Period']!) row.add(employee.contractPeriod);
      if (selectedFields['Tenure Last Date']!) row.add(employee.tenureLastDate);
      if (selectedFields['Retirement Date']!) row.add(employee.retirementDate);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "employee_profiles.csv")
      ..click();

    html.Url.revokeObjectUrl(url);

    Navigator.of(context).pop();

    setState(() {
      _isGeneratingCSV = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'CSV for ${department == 'All Departments' ? 'all departments' : department} generated and downloaded successfully!'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showImportFieldSelectionDialog() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Import'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Fields to Import:'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _importSelectedFields
                                  .updateAll((key, value) => true);
                            });
                          },
                          child: const Text('Select All'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _importSelectedFields
                                  .updateAll((key, value) => false);
                            });
                          },
                          child: const Text('Deselect All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._importSelectedFields.entries.map((entry) {
                      return CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? value) {
                          setState(() {
                            _importSelectedFields[entry.key] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Import CSV'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _importCSV(_importSelectedFields);
    }
  }

  Future<void> _importCSV(Map<String, bool> selectedFields) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Importing CSV...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        Navigator.of(context).pop(); // Close loading dialog
        log("No file selected.");
        return;
      }

      var bytes = result.files.first.bytes;
      if (bytes == null) {
        Navigator.of(context).pop(); // Close loading dialog
        log("File selection failed, no file content available.");
        return;
      }

      String csvString = String.fromCharCodes(bytes);
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty || csvTable[0].isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        log("CSV file is empty or not readable.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CSV file is empty or not readable.")),
        );
        return;
      }

      List<String> headers =
          csvTable[0].map((e) => e.toString().trim()).toList();
      int workEmailIndex = headers.indexOf('Work Email');

      if (workEmailIndex == -1) {
        Navigator.of(context).pop(); // Close loading dialog
        log("Work Email column not found in the CSV file.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Work Email column not found in the CSV file.")),
        );
        return;
      }

      // Define a mapping between CSV headers and database field names
      Map<String, String> headerToFieldMap = {
        'Name': 'name',
        'Employee Code': 'employeeCode',
        'Work Email': 'workEmail',
        'Personal Email': 'personalEmail',
        'Department': 'department',
        'Employee Type': 'employeeType',
        'Joining Date': 'joiningDate',
        'Mobile': 'mobile',
        'Location': 'location',
        'Gender': 'gender',
        'Birthday': 'birthday',
        'Father Name': 'fatherName',
        'Blood Group': 'bloodGroup',
        'Aadhar Number': 'aadharNumber',
        'PAN Card Number': 'panCardNumber',
        'Bank Name': 'bankName',
        'Bank Account Number': 'bankAccountNumber',
        'IFSC Code': 'ifscCode',
        'Reporting Manager': 'reportingManager',
        'Probation Period': 'probationPeriod',
        'Confirmation Date': 'confirmationDate',
        'Notice Period': 'noticePeriod',
        'Retirement Age': 'retirementAge',
        'Work Experience': 'workExperience',
        'Work Mode': 'workMode',
        'Gross Salary': 'grossSalary',
        'CTC': 'ctc',
        'Age': 'age',
        'Country Code': 'countryCode',
        'Phone Number': 'phoneNumber',
        'Employee Status': 'employeeStatus',
        'First Name': 'firstName',
        'Middle Name': 'middleName',
        'Last Name': 'lastName',
        'Home Phone Number': 'homePhoneNumber',
        'Permanent Address': 'permanentAddress',
        'Correspondence Address': 'correspondenceAddress',
        'Notice During Probation': 'noticeDuringProbation',
        'Notice Post Probation': 'noticePostProbation',
        'Reporting Manager Code': 'reportingManagerCode',
        'Health Insurance Policy': 'healthInsurancePolicy',
        'Health Insurance Premium': 'healthInsurancePremium',
        'Accidental Insurance Policy': 'accidentalInsurancePolicy',
        'Anniversary': 'anniversary',
        'Family Name': 'familyName',
        'Family Relationship': 'familyRelationship',
        'Family Date of Birth': 'familyDateOfBirth',
        'Family Contact': 'familyContact',
        'Family Address': 'familyAddress',
        'Degree': 'degree',
        'Specialization': 'specialization',
        'College': 'college',
        'Degree Time': 'degreeTime',
        'Experience Title': 'experienceTitle',
        'Experience Location': 'experienceLocation',
        'Experience Time': 'experienceTime',
        'Experience Description': 'experienceDescription',
        'Card Number': 'cardNumber',
        'Beneficiary Name': 'beneficiaryName',
        'Contract Period': 'contractPeriod',
        'Tenure Last Date': 'tenureLastDate',
        'Retirement Date': 'retirementDate',
      };

      int updatedCount = 0;
      int errorCount = 0;

      for (int i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];
        String workEmail = row[workEmailIndex].toString().trim();

        if (workEmail.isEmpty) {
          log("Skipping row $i: Work Email is empty");
          continue;
        }

        Map<String, dynamic> userData = {};
        for (int j = 0; j < headers.length; j++) {
          String header = headers[j];
          String? fieldName = headerToFieldMap[header];
          if (fieldName != null &&
              j < row.length &&
              row[j] != null &&
              row[j].toString().isNotEmpty &&
              selectedFields[header] == true &&
              header != 'Work Email') {
            // Exclude Work Email from updates
            userData[fieldName] = row[j].toString();
          }
        }

        if (userData.isNotEmpty) {
          try {
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(workEmail)
                .update(userData);
            log("Successfully updated user data for: $workEmail");
            updatedCount++;
          } catch (firestoreError) {
            log("Error updating data to Firestore for $workEmail: $firestoreError");
            errorCount++;
          }
        } else {
          log("No valid data to update for $workEmail");
        }
      }

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "CSV import completed. Updated: $updatedCount, Errors: $errorCount")),
      );
    } catch (e, stackTrace) {
      Navigator.of(context).pop(); // Close loading dialog
      log("An error occurred during CSV import: $e");
      log("Stacktrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during CSV import: $e")),
      );
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
                "Employee Management",
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
                        // const SizedBox(width: 16),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     await importExcel();
                        //   },
                        //   child: const Text("Import Sheet"),
                        // ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                  child: const AddUserScreen(),
                                  type: PageTransitionType.fade),
                            );
                          },
                          child: const Text("Add User"),
                        ),
                        const SizedBox(width: 30),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     sendMail(
                        //         'guptasaksham9303@gmail.com', 'Saksham123');
                        //   },
                        //   child: const Text("Send Mail"),
                        // ),
                        // const SizedBox(width: 16),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _isGeneratingCSV
                                  ? null
                                  : _showDepartmentAndFieldSelectionDialog,
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
                                  : Row(
                                      children: [
                                        const Text("Export CSV"),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.download),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showImportFieldSelectionDialog,
                              child: Row(
                                children: [
                                  const Text("Import CSV"),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.upload),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
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
                                                child: UserDetailsScreen(
                                                    employeeEmail:
                                                        userData['workEmail']),
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
