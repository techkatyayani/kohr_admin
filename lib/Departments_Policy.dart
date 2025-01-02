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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Masterdata')
          .doc('collections')
          .collection('Departments')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text('No departments found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(8.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = snapshot.data!.docs[index];
            final Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;

            String departmentName = data['name'] ?? 'Unnamed Department';

            return Container(
              constraints: BoxConstraints(minHeight: 60),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(8.0),
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
