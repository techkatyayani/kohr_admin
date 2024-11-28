import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_textfield.dart';
import '../../constants.dart';
import 'controller/job_application_provider.dart';

class JobApplicationForm extends StatefulWidget {
  @override
  State<JobApplicationForm> createState() => _JobApplicationFormState();
}

class _JobApplicationFormState extends State<JobApplicationForm> {

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  void _clearForm() {
    _jobTitleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _jobDescriptionController.clear();
    _salaryController.clear();

    final jobProvider = Provider.of<JobApplicationProvider>(context, listen: false);
    jobProvider.clearSkills();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobApplicationProvider>(context);

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
                _buildForm(context, jobProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, JobApplicationProvider jobProvider) {
    return Container(
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
          _buildDropdown(
            label: 'Job Type',
            value: jobProvider.selectedJobType,
            items: ['Full-time', 'Part-time', 'Contract'],
            onChanged: (value) =>
            jobProvider.selectedJobType = value!,
          ),
          SizedBox(height: 16),
          _buildDropdown(
            label: 'Experience Level',
            value: jobProvider.selectedExperienceLevel,
            items: ['Fresher', 'Experienced'],
            onChanged: (value) =>
            jobProvider.selectedExperienceLevel = value!,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _skillController,
            decoration: InputDecoration(
              labelText: 'Add Skill',
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: AppColors.primaryBlue),
                onPressed: () {
                  jobProvider.addSkill(_skillController.text);
                  _skillController.clear();
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: jobProvider.skills
                .map(
                  (skill) => Chip(
                label: Text(skill),
                deleteIcon: Icon(Icons.close),
                onDeleted: () => jobProvider.removeSkill(skill),
              ),
            )
                .toList(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _jobDescriptionController,
            decoration: InputDecoration(
              labelText: 'Job Description',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                jobProvider.submitJob(
                  jobTitle: _jobTitleController.text,
                  companyName: _companyNameController.text,
                  location: _locationController.text,
                  jobDescription: _jobDescriptionController.text,
                  salary: _salaryController.text,
                  context: context,
                  onFormClear: _clearForm,
                );
              },
              child: jobProvider.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit Job'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
