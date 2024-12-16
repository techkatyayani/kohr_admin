//
import 'package:Kohr_Admin/screens/hire/dashboardScreens/MainDashboardScreens/widgets/jobDiscription_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/custom_textfield.dart';
import '../../../../constants.dart';
import '../../controller/job_application_provider.dart';



class JobApplicationFormDialog extends StatelessWidget {
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();


  void _clearForm(JobApplicationProvider jobProvider) {
    _jobTitleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _jobDescriptionController.clear();
    _salaryController.clear();

    jobProvider.clearSkills();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobApplicationProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 600,
          //padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(child: Text("Creat Job", style: TextStyle(color: Colors.green,fontSize: 20, fontWeight: FontWeight.bold),)),
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  _buildRow(
                    firstWidget: CustomTextField(
                      controller: _jobTitleController,
                      labelText: 'Job Title',
                      icon: Icons.title_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow(
                    firstWidget: CustomTextField(
                      controller: _companyNameController,
                      labelText: 'Company Name',
                      icon: Icons.home_work_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow(
                    firstWidget: CustomTextField(
                      controller: _locationController,
                      labelText: 'Location',
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRow(
                    firstWidget: CustomTextField(
                      controller: _salaryController,
                      labelText: 'Salary Range',
                      icon: Icons.monetization_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Job Type',
                    value: jobProvider.selectedJobType,
                    items: ['Full-time', 'Part-time', 'Contract'],
                    onChanged: (value) => jobProvider.selectedJobType = value!,
                  ),
                  const SizedBox(height: 16),
                  _buildExperienceDropdown(jobProvider),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Department',
                    value: jobProvider.selectedDepartment,
                    items: [
                      'IT Department',
                      'Development Department',
                      'Sales Department',
                      'HR Department'
                    ],
                    onChanged: (value) => jobProvider.selectedDepartment = value!,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Recruiter',
                    value: jobProvider.selectedRecruiter,
                    items: ['Aditi Rajput', 'Vaisali'],
                    onChanged: (value) => jobProvider.selectedRecruiter = value!,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Number of Hiring Employees',
                    value: jobProvider.selectedHiringEmployees,
                    items: ['1-5', '6-10', '11-20', '20+'],
                    onChanged: (value) =>
                        jobProvider.selectedHiringEmployees = value!,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // No border color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _skillController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Add Skill',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primaryBlue),
                            onPressed: () {
                              jobProvider.addSkill(_skillController.text);
                              _skillController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: jobProvider.skills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => jobProvider.removeSkill(skill),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  JobDescriptionTextField(controller: _jobDescriptionController),

                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        jobProvider.submitJob(
                          jobTitle: _jobTitleController.text,
                          companyName: _companyNameController.text,
                          location: _locationController.text,
                          jobDescription: _jobDescriptionController.text,
                          salary: _salaryController.text,
                          context: context,
                          onFormClear: () => _clearForm(jobProvider),
                        );
                      },
                      child: jobProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Job'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({required Widget firstWidget}) {
    return

        Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // No border color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Flexible(child: firstWidget));

  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300], // No border color
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          fillColor: Colors.white,
          border: InputBorder.none,
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceDropdown(JobApplicationProvider jobProvider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // No border color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: jobProvider.experienceController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Experience',
                  //hintText: 'e.g., 2',
                ),
                onChanged: (value) {
                  jobProvider.selectedExperience = value;
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // No border color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: jobProvider.selectedExperienceUnit,
                onChanged: (value) {
                  jobProvider.selectedExperienceUnit = value!;
                },
                decoration: const InputDecoration(
                    border: InputBorder.none,
                   labelText: 'Select Unit'
                ),
                items: ['Years', 'Months'].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//
// class JobApplicationFormDialog extends StatelessWidget {
//   final TextEditingController _jobTitleController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _jobDescriptionController =
//   TextEditingController();
//   final TextEditingController _skillController = TextEditingController();
//   final TextEditingController _salaryController = TextEditingController();
//   final TextEditingController _dateTimeController = TextEditingController();
//
//   void _clearForm(JobApplicationProvider jobProvider) {
//     _jobTitleController.clear();
//     _companyNameController.clear();
//     _locationController.clear();
//     _jobDescriptionController.clear();
//     _salaryController.clear();
//     _dateTimeController.clear();
//
//     jobProvider.clearSkills();
//   }
//   Future<void> _pickDateTime(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//
//     if (pickedDate != null) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (BuildContext context, Widget? child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//             child: child!,
//           );
//         },
//       );
//
//       if (pickedTime != null) {
//         final DateTime finalDateTime = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );
//         final formattedDate = _formatDateTime(finalDateTime);
//         _dateTimeController.text = formattedDate; // Update the controller with formatted string
//       }
//     }
//   }
//
//   String _formatDateTime(DateTime dateTime) {
//     // Using intl package to format date and time
//     final DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm a');
//     return formatter.format(dateTime);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final jobProvider = Provider.of<JobApplicationProvider>(context);
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Container(
//           width: 600,
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Center(
//                         child: Text(
//                           "Create Job",
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   _buildRow(
//                     firstWidget: CustomTextField(
//                       controller: _jobTitleController,
//                       labelText: 'Job Title',
//                       icon: Icons.title_outlined,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildRow(
//                     firstWidget: CustomTextField(
//                       controller: _companyNameController,
//                       labelText: 'Company Name',
//                       icon: Icons.home_work_outlined,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildRow(
//                     firstWidget: CustomTextField(
//                       controller: _locationController,
//                       labelText: 'Location',
//                       icon: Icons.location_on_outlined,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildRow(
//                     firstWidget: CustomTextField(
//                       controller: _salaryController,
//                       labelText: 'Salary Range',
//                       icon: Icons.monetization_on_outlined,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'Job Type',
//                     value: jobProvider.selectedJobType,
//                     items: ['Full-time', 'Part-time', 'Contract'],
//                     onChanged: (value) => jobProvider.selectedJobType = value!,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildExperienceDropdown(jobProvider),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'Department',
//                     value: jobProvider.selectedDepartment,
//                     items: [
//                       'IT Department',
//                       'Development Department',
//                       'Sales Department',
//                       'HR Department'
//                     ],
//                     onChanged: (value) => jobProvider.selectedDepartment = value!,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'Recruiter',
//                     value: jobProvider.selectedRecruiter,
//                     items: ['Aditi Rajput', 'Vaisali'],
//                     onChanged: (value) => jobProvider.selectedRecruiter = value!,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'Number of Hiring Employees',
//                     value: jobProvider.selectedHiringEmployees,
//                     items: ['1-5', '6-10', '11-20', '20+'],
//                     onChanged: (value) =>
//                     jobProvider.selectedHiringEmployees = value!,
//                   ),
//                   const SizedBox(height: 16),
//                  // _buildDateTimePicker(context),
//                   const SizedBox(height: 16),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: TextField(
//                         controller: _skillController,
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           labelText: 'Add Skill',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.add,
//                                 color: AppColors.primaryBlue),
//                             onPressed: () {
//                               jobProvider.addSkill(_skillController.text);
//                               _skillController.clear();
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Wrap(
//                     spacing: 8.0,
//                     children: jobProvider.skills
//                         .map(
//                           (skill) => Chip(
//                         label: Text(skill),
//                         deleteIcon: const Icon(Icons.close),
//                         onDeleted: () => jobProvider.removeSkill(skill),
//                       ),
//                     )
//                         .toList(),
//                   ),
//                   const SizedBox(height: 16),
//                   JobDescriptionTextField(controller: _jobDescriptionController),
//                   const SizedBox(height: 16),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                       ),
//                       onPressed: () {
//                         final expirationDate =
//                         DateTime.parse(_dateTimeController.text);
//                         if (DateTime.now().isAfter(expirationDate)) {
//                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                             content: Text('Form is expired!'),
//                           ));
//                           Navigator.pop(context); // Close the dialog
//                           return;
//                         }
//                         jobProvider.submitJob(
//                           jobTitle: _jobTitleController.text,
//                           companyName: _companyNameController.text,
//                           location: _locationController.text,
//                           jobDescription: _jobDescriptionController.text,
//                           salary: _salaryController.text,
//                          // formValidateDate: _dateTimeController.text,
//                           context: context,
//                           onFormClear: () => _clearForm(jobProvider),
//                         );
//                       },
//                       child: jobProvider.isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text('Submit Job'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//     Widget _buildExperienceDropdown(JobApplicationProvider jobProvider) {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300], // No border color
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 keyboardType: TextInputType.number,
//                 controller: jobProvider.experienceController,
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   labelText: 'Experience',
//                   //hintText: 'e.g., 2',
//                 ),
//                 onChanged: (value) {
//                   jobProvider.selectedExperience = value;
//                 },
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[300], // No border color
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: DropdownButtonFormField<String>(
//                 value: jobProvider.selectedExperienceUnit,
//                 onChanged: (value) {
//                   jobProvider.selectedExperienceUnit = value!;
//                 },
//                 decoration: const InputDecoration(
//                     border: InputBorder.none,
//                    labelText: 'Select Unit'
//                 ),
//                 items: ['Years', 'Months'].map((item) {
//                   return DropdownMenuItem(
//                     value: item,
//                     child: Text(item),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDateTimePicker(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[300], // No border color
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: GestureDetector(
//         onTap: () => _pickDateTime(context),
//         child: AbsorbPointer(
//           child: CustomTextField(
//             controller: _dateTimeController,
//             labelText: 'Form Validate Date',
//             icon: Icons.calendar_today_outlined,
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildPositionedWidget() {
//     return Stack(
//       children: [
//         Positioned(
//           left: 0,
//           top: 10,
//           right: 0,
//           child: Container(
//             color: Colors.grey[300],
//             child: Text('Positioned inside a Stack'),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//   // Widget _buildRow({required Widget firstWidget}) {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       color: Colors.grey[300],
//   //       borderRadius: BorderRadius.circular(12),
//   //     ),
//   //     child: firstWidget,
//   //   );
//   // }
//   Widget _buildRow({required Widget firstWidget}) {
//     return Row(
//       children: [
//         Flexible(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: firstWidget,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           fillColor: Colors.white,
//           border: InputBorder.none,
//         ),
//         items: items.map((item) {
//           return DropdownMenuItem(
//             value: item,
//             child: Text(item),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
