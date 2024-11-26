// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../constants.dart';
// import '../../widgets/custom_textfield.dart';
// import 'hire_dashboard.dart';
//
// class JobApplicationForm extends StatefulWidget {
//
//   @override
//   _JobApplicationFormState createState() => _JobApplicationFormState();
// }
//
// class _JobApplicationFormState extends State<JobApplicationForm> {
//   final TextEditingController _jobTitleController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _jobDescriptionController =
//   TextEditingController();
//   final TextEditingController _skillController = TextEditingController();
//   final TextEditingController _salaryController = TextEditingController();
//   List<String> _skills = [];
//   bool _isLoading=false;
//
//   String _selectedJobType = "Full-time";
//   String _selectedExperienceLevel = "Fresher";
//   String _selectedEmploymentType = "Permanent";
//   String _selectedShiftSchedule = "Day shift";
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   void _addSkill() {
//     if (_skillController.text.isNotEmpty) {
//       setState(() {
//         _skills.add(_skillController.text);
//         _skillController.clear();
//       });
//     }
//   }
//
//   void _submitJob() async {
//
//     setState(() {
//       _isLoading = true; // Show loading
//     });
//
//     // Simulating job submission with a delay
//     await Future.delayed(Duration(seconds: 2));
//
//     setState(() {
//       _isLoading = false; // Hide loading
//     });
//
//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Submit Successful!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//
//     if (_jobTitleController.text.isNotEmpty &&
//         _companyNameController.text.isNotEmpty &&
//         _locationController.text.isNotEmpty &&
//         _skills.isNotEmpty &&
//         _jobDescriptionController.text.isNotEmpty) {
//       try {
//         await _firestore.collection('hiring').add({
//           'jobTitle': _jobTitleController.text,
//           'companyName': _companyNameController.text,
//           'location': _locationController.text,
//           'skills': _skills,
//           'salary': _salaryController.text,
//           'jobType': _selectedJobType,
//           'experienceLevel': _selectedExperienceLevel,
//           'employmentType': _selectedEmploymentType,
//           'shiftSchedule': _selectedShiftSchedule,
//           'jobDescription': _jobDescriptionController.text,
//           'isPublished': false,
//           'publishTime':null,
//           'closeHiring':false,
//           'closeTime':null,
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//
//
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Job Application Submitted!')),
//         );
//
//         _clearForm();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill in all fields and add skills.')),
//       );
//     }
//   }
//
//   void _clearForm() {
//     _jobTitleController.clear();
//     _companyNameController.clear();
//     _locationController.clear();
//     _jobDescriptionController.clear();
//     _salaryController.clear();
//     setState(() {
//       _skills.clear();
//       _selectedJobType = "Full-time";
//       _selectedExperienceLevel = "Fresher";
//       _selectedEmploymentType = "Permanent";
//       _selectedShiftSchedule = "Day shift";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Job Application'),
//         backgroundColor: AppColors.primaryBlue,
//       ),
//       body: Container(
//         height: double.infinity,
//         color: AppColors.primaryBlue.withOpacity(0.1),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildCompleteProfileForm(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCompleteProfileForm() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Flexible(
//                 child: CustomTextField(
//                   controller: _jobTitleController,
//                   labelText: 'Job Title',
//                   icon: Icons.title_outlined,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Flexible(
//                 child: CustomTextField(
//                   controller: _companyNameController,
//                   labelText: 'Company Name',
//                   icon: Icons.maps_home_work_outlined,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Flexible(
//                 child: CustomTextField(
//                   controller: _locationController,
//                   labelText: 'Location',
//                   icon: Icons.location_on_outlined,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Flexible(
//                 child: CustomTextField(
//                   controller: _salaryController,
//                   labelText: 'Salary (Optional)',
//                   icon: Icons.attach_money,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           _buildDropdownField(
//             label: 'Job Type',
//             value: _selectedJobType,
//             items: ['Full-time', 'Part-time', 'Contract'],
//             onChanged: (value) {
//               setState(() {
//                 _selectedJobType = value!;
//               });
//             },
//           ),
//           SizedBox(height: 16),
//           _buildDropdownField(
//             label: 'Experience Level',
//             value: _selectedExperienceLevel,
//             items: ['Fresher', 'Experienced'],
//             onChanged: (value) {
//               setState(() {
//                 _selectedExperienceLevel = value!;
//               });
//             },
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _skillController,
//             decoration: InputDecoration(
//               labelText: 'Add Skill',
//               labelStyle: TextStyle(color: AppColors.greyText),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.primaryBlue),
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.add, color: AppColors.primaryBlue),
//                 onPressed: _addSkill,
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: _skills
//                 .map((skill) => Chip(
//               label: Text(skill),
//               deleteIcon: Icon(Icons.close, color: AppColors.greyText),
//               backgroundColor: AppColors.lightGrey,
//               onDeleted: () {
//                 setState(() {
//                   _skills.remove(skill);
//                 });
//               },
//             ))
//                 .toList(),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: _jobDescriptionController,
//             decoration: InputDecoration(
//               labelText: 'Job Description',
//               labelStyle: TextStyle(color: AppColors.greyText),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColors.primaryBlue),
//               ),
//             ),
//             maxLines: null,
//             keyboardType: TextInputType.multiline,
//           ),
//           SizedBox(height: 16),
//           Center(
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryGreen,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 15,
//                 ),
//               ),
//               onPressed: _submitJob,
//               child: Text(
//                 'Submit Job Application',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: AppColors.primaryBlue,
//           ),
//         ),
//         SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: value,
//           items: items
//               .map((item) => DropdownMenuItem(
//             value: item,
//             child: Text(item),
//           ))
//               .toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart'; // Replace with your constants file path
import '../../widgets/custom_textfield.dart'; // Replace with your custom widget path

class JobApplicationForm extends StatefulWidget {
  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  List<String> _skills = [];
  bool _isLoading = false;

  String _selectedJobType = "Full-time";
  String _selectedExperienceLevel = "Fresher";
  String _selectedEmploymentType = "Permanent";
  String _selectedShiftSchedule = "Day shift";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  Future<void> _submitJob() async {
    setState(() {
      _isLoading = true; // Show loading
    });

    // Simulate some delay before submitting
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false; // Hide loading
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submit Successful!'),
        backgroundColor: Colors.green,
      ),
    );

    if (_jobTitleController.text.isNotEmpty &&
        _companyNameController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _skills.isNotEmpty &&
        _jobDescriptionController.text.isNotEmpty) {
      try {
        // 1. Fetch the current job count to generate a new job ID
        DocumentReference jobIdCounterRef = _firestore.collection('jobIdCounter').doc('counter');
        DocumentSnapshot snapshot = await jobIdCounterRef.get();

        int jobCount = 1;
        if (snapshot.exists) {
          // Increment the counter if it exists
          jobCount = snapshot['count'] + 1;
        }

        // 2. Create the custom job ID (Hr-1, Hr-2, etc.)
        String customJobId = 'Hr-$jobCount';

        // 3. Create the new job entry using the custom job ID
        await _firestore.collection('hiring').doc(customJobId).set({
          'jobTitle': _jobTitleController.text,
          'companyName': _companyNameController.text,
          'location': _locationController.text,
          'skills': _skills,
          'salary': _salaryController.text,
          'jobType': _selectedJobType,
          'experienceLevel': _selectedExperienceLevel,
          'employmentType': _selectedEmploymentType,
          'shiftSchedule': _selectedShiftSchedule,
          'jobDescription': _jobDescriptionController.text,
          'isPublished': false,
          'publishTime': null,
          'closeHiring': false,
          'closeTime': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 4. Update the job count in the counter document
        await jobIdCounterRef.set({
          'count': jobCount,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job Application Submitted!')),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and add skills.')),
      );
    }
  }

  void _clearForm() {
    _jobTitleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _jobDescriptionController.clear();
    _salaryController.clear();
    setState(() {
      _skills.clear();
      _selectedJobType = "Full-time";
      _selectedExperienceLevel = "Fresher";
      _selectedEmploymentType = "Permanent";
      _selectedShiftSchedule = "Day shift";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Job Application'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Container(
        height: double.infinity,
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompleteProfileForm(),
              ],
            ),
          ),
        ),
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
          Row(
            children: [
              Flexible(
                child: CustomTextField(
                  controller: _jobTitleController,
                  labelText: 'Job Title',
                  icon: Icons.title_outlined,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: CustomTextField(
                  controller: _companyNameController,
                  labelText: 'Company Name',
                  icon: Icons.maps_home_work_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: CustomTextField(
                  controller: _locationController,
                  labelText: 'Location',
                  icon: Icons.location_on_outlined,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                child: CustomTextField(
                  controller: _salaryController,
                  labelText: 'Salary (Optional)',
                  icon: Icons.attach_money,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDropdownField(
            label: 'Job Type',
            value: _selectedJobType,
            items: ['Full-time', 'Part-time', 'Contract'],
            onChanged: (value) {
              setState(() {
                _selectedJobType = value!;
              });
            },
          ),
          SizedBox(height: 16),
          _buildDropdownField(
            label: 'Experience Level',
            value: _selectedExperienceLevel,
            items: ['Fresher', 'Experienced'],
            onChanged: (value) {
              setState(() {
                _selectedExperienceLevel = value!;
              });
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _skillController,
            decoration: InputDecoration(
              labelText: 'Add Skill',
              labelStyle: TextStyle(color: AppColors.greyText),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: AppColors.primaryBlue),
                onPressed: _addSkill,
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _skills
                .map((skill) => Chip(
              label: Text(skill),
              deleteIcon: Icon(Icons.close, color: AppColors.greyText),
              backgroundColor: AppColors.lightGrey,
              onDeleted: () {
                setState(() {
                  _skills.remove(skill);
                });
              },
            ))
                .toList(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _jobDescriptionController,
            decoration: InputDecoration(
              labelText: 'Job Description',
              labelStyle: TextStyle(color: AppColors.greyText),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitJob,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Submit Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 16),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
