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

  String? _selectedLocation;
  String? _selectedDepartment;
  String? _selectedDesignation;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _anniversaryController = TextEditingController();
  final TextEditingController _familyRelationshipController =
      TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _familyDateOfBirthController =
      TextEditingController();
  final TextEditingController _familyContactController =
      TextEditingController();
  final TextEditingController _familyAddresController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _collageController = TextEditingController();
  final TextEditingController _degreeTimeController = TextEditingController();
  final TextEditingController _experienceTitleController =
      TextEditingController();
  final TextEditingController _experienceLocationController =
      TextEditingController();
  final TextEditingController _experienceTimeController =
      TextEditingController();
  final TextEditingController _experienceDescriptionController =
      TextEditingController();
  // final TextEditingController _familyAddresController = TextEditingController();
  // final TextEditingController _familyAddresController = TextEditingController();
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Birthday',
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
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
            "PERSONAL PROFILE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "First Name",
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: "Middle Name",
                  controller: _middleNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Last Name",
                  controller: _lastNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Birthday',
                      controller: _dobController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(EvaIcons.calendar),
                    onPressed: () {
                      _selectDate(context, _dobController);
                    },
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(EvaIcons.person),
              SizedBox(width: 4),
              Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
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
                  const SizedBox(width: 30),

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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Father's Name",
                  controller: _fatherNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Age',
                  controller: _ageController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Marital Status",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Anniversary',
                        controller: _anniversaryController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _anniversaryController);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Family Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Name",
                  controller: _familyNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Relationship',
                  controller: _familyRelationshipController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Date Of Birth',
                        controller: _anniversaryController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _familyDateOfBirthController);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomTextField(
                  labelText: 'Contact Detais',
                  controller: _familyContactController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Address',
                  controller: _familyAddresController,
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          const Divider(height: 60),
          const Text(
            "PROFESSIONAL PROFILE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 30),
          const Text(
            "Highest Education Qualification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Degree",
                  controller: _degreeController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Specialization',
                  controller: _specializationController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Collage",
                  controller: _collageController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Time',
                        controller: _degreeTimeController,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Past Work Experience",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Title",
                  controller: _experienceTitleController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Location',
                  controller: _experienceLocationController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Time (Months)',
                  controller: _experienceTimeController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Description',
                  controller: _experienceDescriptionController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Employee Code',
                  controller: _employeeCodeController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
