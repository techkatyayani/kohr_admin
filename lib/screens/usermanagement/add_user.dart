import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/widgets/custom_dropdown.dart';
import 'package:kohr_admin/widgets/custom_textfield.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female'];

  String? _selectedLocation;
  String? _selectedDepartment;
  String? _selectedDesignation;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> _locations = [];
  List<String> _departments = [];
  List<String> _designations = [];
  bool _isLoading = false;

  int _currentStep = 1;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _employeeCodeController.dispose();
    _workEmailController.dispose();
    super.dispose();
  }

  void saveUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_workEmailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _workEmailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        Employee employeeData = Employee(
          firstName: _firstNameController.text,
          middleName: _middleNameController.text,
          lastName: _lastNameController.text,
          employeeCode: _employeeCodeController.text,
          location: _selectedLocation ?? '',
          department: _selectedDepartment ?? '',
          employeeType: _selectedDesignation ?? '',
          workEmail: _workEmailController.text,
        );

        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(_workEmailController.text)
            .set(employeeData.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User profile saved successfully!")),
        );
      }
      _nextStep();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error saving user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save user: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void fetchUniqueLocations() async {
    var locationsSet = <String>{};
    var departmentSet = <String>{};
    var designationSet = <String>{};

    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('profiles').get();
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var location = data['location'] as String? ?? '';
        var department = data['department'] as String? ?? '';
        var designation = data['employeeType'] as String? ?? '';

        if (location.isNotEmpty) {
          locationsSet.add(location);
        }
        if (department.isNotEmpty) {
          departmentSet.add(department);
        }
        if (designation.isNotEmpty) {
          designationSet.add(designation);
        }
      }

      setState(() {
        _locations = locationsSet.toList();
        _departments = departmentSet.toList();
        _designations = designationSet.toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUniqueLocations();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
      ),
      body: Container(
        height: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: size.height * .08,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _currentStep == 1
                          ? IconButton(
                              onPressed: () {
                                _previousStep();
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            )
                          : const SizedBox(),
                      InkWell(
                        onTap: _previousStep,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _currentStep == 0
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("Basic Details"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Divider(),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _nextStep,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _currentStep == 1
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text("Complete Profile"),
                          ],
                        ),
                      ),
                      const Spacer(flex: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      _buildBasicDetailsForm(),
                      _buildCompleteProfileForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicDetailsForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Addition",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'First Name',
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Middle Name',
                  controller: _middleNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Last Name',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      labelText: 'Employee Code',
                      controller: _employeeCodeController,
                    ),
                    const SizedBox(height: 6),
                    const Text("Last Employee Code : KO217GR")
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomDropdown<String>(
                  labelText: "Location",
                  value: _selectedLocation,
                  items: _locations
                      .map((role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  labelText: 'Department',
                  value: _selectedDepartment,
                  items: _departments
                      .map(
                        (department) => DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Work Email',
                  controller: _workEmailController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  labelText: 'Designations',
                  value: _selectedDesignation,
                  items: _designations
                      .map(
                        (designation) => DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDesignation = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Password',
                  controller: _passwordController,
                ),
              ),
            ],
          ),
          const Divider(height: 60),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: saveUser,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Text("Save And Next"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complete Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: const CustomTextField(labelText: "First Name"),
              ),
              SizedBox(width: 20),
              Expanded(
                child: const CustomTextField(labelText: "Middle Name"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: const CustomTextField(labelText: "Last Name"),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    const CustomTextField(labelText: 'Birthday'),
                    IconButton(
                      icon: const Icon(EvaIcons.clock),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(EvaIcons.person),
              SizedBox(width: 4),
              Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Male Radio Button
                    Radio<String>(
                      value: 'Male',
                      groupValue: _selectedGender,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                    const Text('Male'),
                    const SizedBox(
                        width: 30), // Spacing between the radio buttons

                    // Female Radio Button
                    Radio<String>(
                      value: 'Female',
                      groupValue: _selectedGender,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {},
                child: const Text("Submit"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
