import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class EditRoomScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> roomData;

  const EditRoomScreen({
    super.key, 
    required this.documentId,
    required this.roomData,
  });

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roomNameController;
  late final TextEditingController _officeNameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String? _currentImageUrl;
  
  late final List<TextEditingController> _specificationControllers;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(text: widget.roomData['roomName']);
    _officeNameController = TextEditingController(text: widget.roomData['officeName']);
    _currentImageUrl = widget.roomData['roomImage'];
    
    // Convert Timestamp to TimeOfDay
    final availableTimings = widget.roomData['availableTimings'] as Map<String, dynamic>;
    final startTimestamp = availableTimings['startTiming'] as Timestamp;
    final endTimestamp = availableTimings['endTiming'] as Timestamp;
    
    final startDateTime = startTimestamp.toDate();
    final endDateTime = endTimestamp.toDate();
    
    _startTime = TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute);
    _endTime = TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute);
    
    // Initialize specification controllers
    final specifications = List<String>.from(widget.roomData['specifications'] ?? []);
    _specificationControllers = specifications.isEmpty 
        ? [TextEditingController()]
        : specifications.map((spec) => TextEditingController(text: spec)).toList();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<String?> _uploadFile(String roomId) async {
    if (_selectedFile == null) return _currentImageUrl;

    try {
      setState(() {
        _isUploading = true;
      });

      // Create a unique filename
      String fileName = 'meetingImages/${DateTime.now().millisecondsSinceEpoch}_${roomId}${_selectedFile!.extension}';
      
      // Create the reference to the file location in Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(fileName);
      
      // Upload the file bytes
      final uploadTask = ref.putData(
        _selectedFile!.bytes!,
        SettableMetadata(contentType: 'image/${_selectedFile!.extension}'),
      );
      
      // Get download URL
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      setState(() {
        _isUploading = false;
      });
      
      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      rethrow;
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff09254A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _addNewSpecification() {
    setState(() {
      _specificationControllers.add(TextEditingController());
    });
  }

  void _removeSpecification(int index) {
    setState(() {
      _specificationControllers[index].dispose();
      _specificationControllers.removeAt(index);
    });
  }

  void _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isUploading = true;
        });

        // Upload new image if selected
        String? imageUrl = await _uploadFile(widget.roomData['roomId']);

        final specifications = _specificationControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        final room = {
          'roomName': _roomNameController.text,
          'officeName': _officeNameController.text,
          'roomImage': imageUrl,
          'specifications': specifications,
          'availableTimings': {
            'startTiming': DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              _startTime.hour,
              _startTime.minute,
            ),
            'endTiming': DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              _endTime.hour,
              _endTime.minute,
            ),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('MeetingRooms')
            .doc(widget.documentId)
            .update(room);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating room: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final formWidth = size.width > 600 ? 600.0 : size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Meeting Room',
          style: TextStyle(color: Colors.white, fontFamily: 'Sora'),
        ),
        backgroundColor: const Color(0xff09254A),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: formWidth,
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room #${widget.roomData['roomId']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff09254A),
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _roomNameController,
                          decoration: const InputDecoration(
                            labelText: 'Room Name',
                            hintText: 'Enter room name',
                            prefixIcon: Icon(Icons.meeting_room),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter room name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _officeNameController,
                          decoration: const InputDecoration(
                            labelText: 'Office Name',
                            hintText: 'Enter office name',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter office name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Room Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff09254A),
                                fontFamily: 'Sora',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _selectedFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        _selectedFile!.bytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            _currentImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey.shade400,
                                                  size: 48,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate_outlined,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Click to add room image',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton.icon(
                                onPressed: _isUploading ? null : _pickFile,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: Text(_selectedFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty)
                                    ? 'Select Image'
                                    : 'Change Image'),
                              ),
                            ),
                            if (_selectedFile != null)
                              Center(
                                child: Text(
                                  _selectedFile!.name,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Available Timings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff09254A),
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(context, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _formatTimeOfDay(_startTime),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(context, false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'End Time',
                                    prefixIcon: Icon(Icons.access_time),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(
                                    _formatTimeOfDay(_endTime),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff09254A),
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _specificationControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextFormField(
                                controller: _specificationControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Specification ${index + 1}',
                                  hintText: 'Enter specification',
                                  prefixIcon: const Icon(Icons.featured_play_list),
                                  suffixIcon: _specificationControllers.length > 1
                                      ? IconButton(
                                          icon: const Icon(Icons.remove_circle),
                                          color: Colors.red,
                                          onPressed: () => _removeSpecification(index),
                                          tooltip: 'Remove Specification',
                                        )
                                      : null,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter specification';
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _addNewSpecification,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Specification',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Sora',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff09254A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _updateRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff09254A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Update Room',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Sora',
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _officeNameController.dispose();
    for (var controller in _specificationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
