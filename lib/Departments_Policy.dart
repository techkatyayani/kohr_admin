import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DepartmentsPolicyScreen extends StatefulWidget {
  @override
  _DepartmentsPolicyScreenState createState() =>
      _DepartmentsPolicyScreenState();
}

class _DepartmentsPolicyScreenState extends State<DepartmentsPolicyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 100,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Departments Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search departments...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primaryBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Masterdata')
                    .doc('collections')
                    .collection('Departments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No departments found'),
                    );
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot document = filteredDocs[index];
                      final Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      final String departmentName =
                          data['name'] ?? 'Unnamed Department';

                      return Container(
                        constraints: const BoxConstraints(minHeight: 60),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: Text(
                              departmentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data['policyLink'] != null
                                  ? 'Policy Link Available'
                                  : 'No Policy Link',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(document),
                            ),
                            onTap: () {
                              if (data['policyLink'] != null) {
                                _handlePolicyTap(data['policyLink']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePolicyTap(String policyLink) {
    // Implement your policy link handling logic here
    print('Opening policy: $policyLink');
    // You might want to use url_launcher package to open the link
  }

  Future<void> _showEditDialog(DocumentSnapshot document) async {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final TextEditingController policyController = TextEditingController(
      text: data['policyLink']?.toString(),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${data['name']} Policy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: policyController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Policy Link',
                  hintText: 'Enter new policy link or upload a file',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Policy File'),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );

                  if (result != null) {
                    try {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );

                      final file = result.files.first;
                      final storageRef = FirebaseStorage.instance
                          .ref()
                          .child('policies/${document.id}/${file.name}');

                      // Upload file
                      await storageRef.putData(file.bytes!);

                      // Get download URL
                      final downloadUrl = await storageRef.getDownloadURL();

                      // Update the text field with the download URL
                      policyController.text = downloadUrl;

                      // Close loading indicator
                      Navigator.pop(context);
                    } catch (e) {
                      // Close loading indicator
                      Navigator.pop(context);
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error uploading file: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _firestore
                      .collection('Masterdata')
                      .doc('collections')
                      .collection('Departments')
                      .doc(document.id)
                      .update({
                    'policyLink': policyController.text.trim(),
                  });
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating policy: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating policy: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
