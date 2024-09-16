import 'package:flutter/material.dart';
import 'package:kohr_admin/colors.dart';
import 'package:kohr_admin/widgets/custom_dropdown.dart';
import 'package:kohr_admin/widgets/custom_textfield.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String? _selectedLocation;
  String? _selectedDepartment;
  String? _selectedDesignation;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _workEmailController = TextEditingController();

  final List<String> _locations = ['Admin', 'User', 'Guest'];
  final List<String> _departments = ['Admin', 'User', 'Guest'];
  final List<String> _designations = ['Admin', 'User', 'Guest'];

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
              Expanded(child: Container()),
            ],
          ),
          const Divider(height: 60),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text("Save And Next"),
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
          const CustomTextField(labelText: "First Name"),
          const SizedBox(height: 20),
          const CustomTextField(labelText: "First Name"),
          const SizedBox(height: 20),
          const CustomTextField(labelText: "First Name"),
          const SizedBox(height: 50),
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
              ))
        ],
      ),
    );
  }
}
