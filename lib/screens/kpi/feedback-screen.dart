import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Kohr_Admin/widgets/custom_dropdown.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? selectedDepartment;
  String? selectedDesignation;
  List<Map<String, String>> departments = [];
  List<Map<String, String>> designations = [];
  List<Map<String, dynamic>> formFields = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    fetchDesignations();
  }

  Future<void> fetchDepartments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Masterdata')
        .doc('collections')
        .collection('Departments')
        .get();

    setState(() {
      departments = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] as String,
        };
      }).toList();
    });
  }

  Future<void> fetchDesignations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Masterdata')
        .doc('collections')
        .collection('Designations')
        .get();

    setState(() {
      designations = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] as String,
        };
      }).toList();
    });
  }

  void addField(String type) {
    setState(() {
      formFields.add({
        'type': type,
        'question': '',
        'options': type == 'dropdown' || type == 'mcq' ? [''] : null,
      });
    });
  }

  Widget buildFieldWidget(int index) {
    final field = formFields[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Question'),
          onChanged: (value) {
            setState(() {
              field['question'] = value;
            });
          },
        ),
        if (field['type'] == 'dropdown' || field['type'] == 'mcq')
          Column(
            children: [
              ...List.generate(field['options'].length, (optionIndex) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Option ${optionIndex + 1}'),
                        onChanged: (value) {
                          setState(() {
                            field['options'][optionIndex] = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          field['options'].removeAt(optionIndex);
                        });
                      },
                    ),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    field['options'].add('');
                  });
                },
                child: Text('Add Option'),
              ),
            ],
          ),
        SizedBox(height: 16),
      ],
    );
  }

  void showPreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Form Preview'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...formFields.map((field) => buildPreviewField(field)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget buildPreviewField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'dropdown':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['question'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              items: field['options'].map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      case 'short_answer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['question'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
          ],
        );
      case 'mcq':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['question'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...field['options'].map((option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: null,
                  onChanged: (value) {},
                )),
            SizedBox(height: 16),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form Creator'),
        actions: [
          IconButton(
            icon: Icon(Icons.preview),
            onPressed: showPreview,
            tooltip: 'Preview Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown<String>(
              labelText: 'Select Department',
              value: selectedDepartment,
              items: departments.map((department) {
                return DropdownMenuItem(
                  value: department['id'],
                  child: Text(department['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              labelText: 'Select Designation',
              value: selectedDesignation,
              items: designations.map((designation) {
                return DropdownMenuItem(
                  value: designation['id'],
                  child: Text(designation['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDesignation = value;
                });
              },
            ),
            SizedBox(height: 32),
            Text('Add Form Fields',
                style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => addField('dropdown'),
                  child: Text('Add Dropdown'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => addField('short_answer'),
                  child: Text('Add Short Answer'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => addField('mcq'),
                  child: Text('Add MCQ'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...List.generate(
                formFields.length, (index) => buildFieldWidget(index)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement form submission logic
                print(formFields);
              },
              child: Text('Save Form'),
            ),
          ],
        ),
      ),
    );
  }
}
