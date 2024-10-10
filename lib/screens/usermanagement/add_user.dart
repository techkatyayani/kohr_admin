import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/constants.dart';
import 'package:kohr_admin/models/employee_model.dart';
import 'package:kohr_admin/services/api_service.dart';
import 'package:kohr_admin/widgets/custom_dropdown.dart';
import 'package:kohr_admin/widgets/custom_textfield.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedLocation;
  String? _selectedDepartment;
  String? _selectedDesignation;
  String? _selectedReportingManager;
  String? _selectedWorkMode;
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
  final TextEditingController _personalEmailController =
      TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _homePhoneNumberController =
      TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();
  final TextEditingController _correspondenceAddressController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _beneficiaryNameController =
      TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final TextEditingController _panCardNumberController =
      TextEditingController();
  final TextEditingController _healthInsuarancePolicyController =
      TextEditingController();
  final TextEditingController _healthInsuarancePremiumController =
      TextEditingController();
  final TextEditingController _accidentalInsuaranceController =
      TextEditingController();
  final TextEditingController _adharCardNumberController =
      TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _workExperienceController =
      TextEditingController();
  final TextEditingController _probationPeriodController =
      TextEditingController();
  final TextEditingController _confirmationDateController =
      TextEditingController();
  final TextEditingController _grossSalaryController = TextEditingController();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _noticePeriodController = TextEditingController();
  final TextEditingController _tenurePeriodController = TextEditingController();
  final TextEditingController _retirementAgeController =
      TextEditingController();
  final TextEditingController _tenureLastDateController =
      TextEditingController();
  final TextEditingController _retirementDateController =
      TextEditingController();
  List<String> _locations = [];
  List<String> _departments = [];
  List<String> _designations = [];
  List<String> _reportingManagers = [];
  List<String> _workModes = [];
  bool _isLoading = false;

  int _currentStep = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _employeeCodeController.dispose();
    _workEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendPassword(
      String userName, String email, String employeeCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _passwordController.text = await ApiService().sendPasswordRequest(
        username: userName,
        email: email,
        employeeCode: employeeCode,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password send successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, String label) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: label,
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
    if (_workEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    String fullName =
        "${_firstNameController.text} ${_lastNameController.text}";
    await _sendPassword(
        fullName, _workEmailController.text, _employeeCodeController.text);

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

  void submitUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_workEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email cannot be empty")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Employee employeeData = Employee(
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        name: "${_firstNameController.text} ${_lastNameController.text}",
        birthday: _dobController.text,
        gender: _selectedGender ?? '',
        fatherName: _fatherNameController.text,
        age: _ageController.text,
        anniversary: _anniversaryController.text,
        familyName: _familyNameController.text,
        familyRelationship: _familyRelationshipController.text,
        familyDateOfBirth: _familyDateOfBirthController.text,
        familyContact: _familyContactController.text,
        familyAddress: _familyAddresController.text,
        degree: _degreeController.text,
        specialization: _specializationController.text,
        college: _collageController.text,
        degreeTime: _degreeTimeController.text,
        experienceTitle: _experienceTitleController.text,
        experienceLocation: _experienceLocationController.text,
        experienceTime: _experienceTimeController.text,
        experienceDescription: _experienceDescriptionController.text,
        personalEmail: _personalEmailController.text,
        countryCode: _countryCodeController.text,
        phoneNumber: _phoneNumberController.text,
        homePhoneNumber: _homePhoneNumberController.text,
        permanentAddress: _permanentAddressController.text,
        correspondenceAddress: _correspondenceAddressController.text,
        bloodGroup: _selectedBloodGroup ?? '',
        bankName: _bankNameController.text,
        ifscCode: _ifscCodeController.text,
        beneficiaryName: _beneficiaryNameController.text,
        bankAccountNumber: _bankAccountNumberController.text,
        panCardNumber: _panCardNumberController.text,
        healthInsurancePolicy: _healthInsuarancePolicyController.text,
        healthInsurancePremium: _healthInsuarancePremiumController.text,
        accidentalInsurancePolicy: _accidentalInsuaranceController.text,
        aadharNumber: _adharCardNumberController.text,
        location: _selectedLocation ?? '',
        workEmail: _workEmailController.text,
        department: _selectedDepartment ?? '',
        employeeType: _selectedDesignation ?? '',
        employeeCode: _employeeCodeController.text,
        workMode: _selectedWorkMode ?? '',
        joiningDate: _joiningDateController.text,
        cardNumber: _cardNumberController.text,
        workExperience: _workExperienceController.text,
        reportingManager: _selectedReportingManager ?? '',
        probationPeriod: _probationPeriodController.text,
        confirmationDate: _confirmationDateController.text,
        ctc: _ctcController.text,
        grossSalary: _grossSalaryController.text,
        noticePeriod: _noticePeriodController.text,
        contractPeriod: _tenurePeriodController.text,
        retirementAge: _retirementAgeController.text,
        tenureLastDate: _tenureLastDateController.text,
        retirementDate: _retirementDateController.text,
      );

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_workEmailController.text)
          .update(employeeData.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User profile saved successfully!")),
      );
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

  void fetchWorkModes() async {
    try {
      // Fetch all collections concurrently using Future.wait
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('Masterdata')
            .doc('collections')
            .collection('WorkModes')
            .get(),
        FirebaseFirestore.instance
            .collection('Masterdata')
            .doc('collections')
            .collection('Designations')
            .get(),
        FirebaseFirestore.instance
            .collection('Masterdata')
            .doc('collections')
            .collection('Departments')
            .get(),
        FirebaseFirestore.instance
            .collection('Masterdata')
            .doc('collections')
            .collection('Locations')
            .get(),
        FirebaseFirestore.instance
            .collection('Masterdata')
            .doc('collections')
            .collection('ReportingManagers')
            .get(),
      ]);

      final workModes = results[0];
      final designations = results[1];
      final departments = results[2];
      final locations = results[3];
      final reportManagers = results[4];

      // Update state in one go
      setState(() {
        _workModes =
            workModes.docs.map((doc) => doc['name'] as String).toList();
        _designations =
            designations.docs.map((doc) => doc['name'] as String).toList();
        _departments =
            departments.docs.map((doc) => doc['name'] as String).toList();
        _locations =
            locations.docs.map((doc) => doc['name'] as String).toList();
        _reportingManagers =
            reportManagers.docs.map((doc) => doc['name'] as String).toList();
      });

      print(
          'Data fetched successfully: $_workModes, $_designations, $_departments, $_locations, $_reportingManagers');
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWorkModes();
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
              Expanded(child: Container()),
            ],
          ),
          const Divider(height: 60),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: saveUser,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
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
                      _selectDate(context, _dobController, 'Birthday');
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
                        _selectDate(
                            context, _anniversaryController, 'Anniversary');
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
                        controller: _familyDateOfBirthController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _familyDateOfBirthController,
                            'Date Of Birth');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Contact Details',
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
          const Divider(height: 60),
          const Text(
            "CONTACT DETAILS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Personal Email',
                  controller: _personalEmailController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Country Code',
                  controller: _countryCodeController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Phone Number',
                  controller: _phoneNumberController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Home Phone Number',
                  controller: _homePhoneNumberController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Permanent Address',
                  controller: _permanentAddressController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Correspondence Address',
                  controller: _correspondenceAddressController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(EvaIcons.person),
              SizedBox(width: 4),
              Text(
                "Blood Group",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Radio<String>(
                    value: 'A+',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('A+'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'A-',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('A-'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'B+',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('B+'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'B-',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('B-'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'AB+',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('AB+'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'AB-',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('AB-'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'O+',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('O+'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'O-',
                    groupValue: _selectedBloodGroup,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                  ),
                  const Text('O-'),
                ],
              ),
            ],
          ),
          const Divider(height: 60),
          const Text(
            "FINANCIAL DETAILS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Bank Name",
                  controller: _bankNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'IFSC Code',
                  controller: _ifscCodeController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Beneficiary Name",
                  controller: _beneficiaryNameController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Bank Account Number',
                  controller: _bankAccountNumberController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Pan Card Number",
                  controller: _panCardNumberController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Health Insurance Policy Number',
                  controller: _healthInsuarancePolicyController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Health Insuarance Premium",
                  controller: _healthInsuarancePremiumController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Accidental Insuarance Policy Number',
                  controller: _accidentalInsuaranceController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Adhar Card Number",
                  controller: _adharCardNumberController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          const Divider(height: 60),
          const Text(
            "WORK PROFILE",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
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
                child: CustomDropdown<String>(
                  labelText: 'Work Mode',
                  value: _selectedWorkMode,
                  items: _workModes
                      .map(
                        (designation) => DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkMode = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                'Joining Date* ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '( 1/1/2000 )',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Joining Date',
                        controller: _joiningDateController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(
                            context, _joiningDateController, 'Joining Date');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: 'Card Number',
                  controller: _cardNumberController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Work Experience",
                  controller: _workExperienceController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomDropdown<String>(
                  labelText: 'Reporting Manager',
                  value: _selectedReportingManager,
                  items: _reportingManagers
                      .map(
                        (designation) => DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReportingManager = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Probation Period (in days)",
                  controller: _probationPeriodController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Confirmation Date',
                        controller: _confirmationDateController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _confirmationDateController,
                            'Confirmation Date');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Compensation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Gross",
                  controller: _grossSalaryController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: "CTC",
                  controller: _ctcController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Notice Period",
                  controller: _noticePeriodController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomTextField(
                  labelText: "Tenure or Contract Period",
                  controller: _tenurePeriodController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "Retirement Age",
                  controller: _retirementAgeController,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        labelText: 'Tenure Last Date',
                        controller: _tenureLastDateController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _tenureLastDateController,
                            'Tenure Last Date');
                      },
                    ),
                  ],
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
                        labelText: 'Retirement Date',
                        controller: _retirementDateController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(EvaIcons.calendar),
                      onPressed: () {
                        _selectDate(context, _retirementDateController,
                            'Retirement Date');
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  submitUser();
                },
                child: const Text("Submit"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
