import 'package:Kohr_Admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'custom_input_dialog.dart'; // Import your custom dialog

class MasterDetailsScreen extends StatefulWidget {
  final String masterType;
  const MasterDetailsScreen({super.key, required this.masterType});

  @override
  State<MasterDetailsScreen> createState() => _MasterDetailsScreenState();
}

class _MasterDetailsScreenState extends State<MasterDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to update the name in Firestore
  Future<void> _updateName(String docId, String newName) async {
    await _firestore
        .collection('Masterdata')
        .doc('collections')
        .collection(widget.masterType)
        .doc(docId)
        .update({'name': newName});
  }

  // Function to add a new name to Firestore
  Future<void> _addNewName(String name) async {
    await _firestore
        .collection('Masterdata')
        .doc('collections')
        .collection(widget.masterType)
        .add({'name': name});
  }

  // Function to delete the name from Firestore
  Future<void> _deleteName(String docId) async {
    await _firestore
        .collection('Masterdata')
        .doc('collections')
        .collection(widget.masterType)
        .doc(docId)
        .delete();
  }

  // Function to show the delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String name, String docId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red), // Red delete button
              onPressed: () {
                _deleteName(docId); // Call the delete function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.masterType),
        actions: [
          TextButton(
            onPressed: () {
              showCustomInputDialog(
                context: context,
                title: 'Add New ${widget.masterType}',
                onSave: (value) {
                  _addNewName(value);
                },
              );
            },
            child: Row(
              children: [
                Text(
                  "Add ${widget.masterType}  ",
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Container(
        color: AppColors.primaryBlue.withOpacity(0.1),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Masterdata')
              .doc('collections')
              .collection(widget.masterType)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          data['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppColors.primaryBlue),
                              onPressed: () {
                                showCustomInputDialog(
                                  context: context,
                                  title: 'Edit ${widget.masterType}',
                                  initialValue: data['name'],
                                  onSave: (value) {
                                    _updateName(doc.id, value);
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, data['name'], doc.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
