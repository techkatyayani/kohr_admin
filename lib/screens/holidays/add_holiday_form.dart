import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:Kohr_Admin/widgets/custom_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // Add this import

class AddHolidayForm extends StatefulWidget {
  final Map<String, dynamic>? holiday;

  const AddHolidayForm({super.key, this.holiday});

  @override
  State<AddHolidayForm> createState() => _AddHolidayFormState();
}

class _AddHolidayFormState extends State<AddHolidayForm> {
  List<String> departments = [];
  List<String> selectedDepartments = [];
  DateTime? selectedDate;
  bool isLoading = false;
  String? holidayId;
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String? imageUrl;
  Uint8List? imageBytes; // Change this to Uint8List to store image bytes
  String? fileName; // Add this to store the file name

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    if (widget.holiday != null) {
      // Fetch holiday data if it exists
      holidayId = widget.holiday!['id'];
      titleController.text = widget.holiday!['title'] ?? '';
      selectedDate = (widget.holiday!['date'] as Timestamp?)?.toDate();
      selectedDepartments = List<String>.from(widget.holiday!['departments']);
      imageUrl = widget.holiday!['imageUrl'];
    }
  }

  Future<void> fetchDepartments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Masterdata')
        .doc('collections')
        .collection('Departments')
        .get();

    setState(() {
      departments = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> saveHoliday() async {
    if (selectedDate == null) {
      // Show error if no date is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    if (selectedDepartments.isEmpty) {
      // Show error if no departments are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one department")),
      );
      return;
    }

    // Check if imageUrl is null or empty
    if (imageUrl == null || imageUrl!.isEmpty) {
      if (imageBytes == null) {
        // Show error if no image is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image")),
        );
        return;
      }
    }

    // Debugging statements
    print("Selected Date: $selectedDate");
    print("Selected Departments: $selectedDepartments");
    print("Image URL: $imageUrl");
    print("Image Bytes: $imageBytes");

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      if (holidayId == null) {
        holidayId = FirebaseFirestore.instance.collection('holidays').doc().id;
      }

      // Upload image to Firebase Storage
      if (imageBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('holidays/$holidayId/$fileName');
        await storageRef.putData(imageBytes!);
        imageUrl = await storageRef.getDownloadURL(); // Get the download URL
      }

      await FirebaseFirestore.instance
          .collection('holidays')
          .doc(holidayId) // Use holidayId to update the existing holiday
          .set({
        'title': titleController.text,
        'date': selectedDate,
        'id': holidayId,
        'departments': selectedDepartments,
        'imageUrl': imageUrl,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Holiday saved successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving holiday: $e")),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> pickImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        imageBytes = result.files.single.bytes; // Store the image bytes
        fileName = result.files.single.name; // Store the file name
        imageUrl = null; // Clear the previous imageUrl
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Holiday',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Holiday Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: "Holiday Name",
                controller: titleController,
              ),
              const SizedBox(height: 20),
              const Text("Select Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: selectedDate != null
                      ? "${selectedDate!.toLocal()}".split(' ')[0]
                      : "No date selected",
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              if (departments.isNotEmpty)
                MultiSelectDialogField(
                  items: departments
                      .map((department) =>
                          MultiSelectItem(department, department))
                      .toList(),
                  initialValue: selectedDepartments,
                  onConfirm: (values) {
                    setState(() {
                      selectedDepartments =
                          values.cast<String>(); // Store selected departments
                    });
                  },
                  title: const Text("Select Departments"),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImageWeb,
                child: const Text("Add Image"),
              ),
              (imageUrl != null && imageUrl!.isNotEmpty)
                  ? Image.network(
                      imageUrl!,
                      width: 100,
                      height: 100,
                    )
                  : (imageBytes != null)
                      ? Image.memory(
                          imageBytes!,
                          width: 100,
                          height: 100,
                        )
                      : Container(),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : ElevatedButton(
                      onPressed: saveHoliday,
                      child: const Text("Save Holiday"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
