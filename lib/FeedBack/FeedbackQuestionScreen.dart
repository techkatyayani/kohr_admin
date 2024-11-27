import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/kpi/feedback-screen.dart';
import 'Controller/FirebaseFuntion.dart';
import 'DepartmentsScreen.dart';

class FeedbackDetailScreen extends StatefulWidget {
  final String feedbackDocId;

  const FeedbackDetailScreen({Key? key, required this.feedbackDocId})
      : super(key: key);

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  bool selectAll = false;
  bool isLoading = false;
  List<bool> toggleStates = [];
  List<Map<String, dynamic>> responses = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedbackDetails();
  }

  Future<void> _fetchFeedbackDetails() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('FeedBack Form')
          .doc('lbKYsR8dnXn3BBbKL8ru')
          .collection('FeedBack Survey Data')
          .doc(widget.feedbackDocId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final responseList = List<Map<String, dynamic>>.from(data['Responses']);

        setState(() {
          responses = responseList;
          toggleStates = responses
              .map((question) => question['Status'] == "Verified")
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching feedback details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to FeedbackScreen when tapped anywhere on the screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FeedbackScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Feedback Details"),
        ),
        body: responses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SwitchListTile(
                    title: const Text("Select All"),
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value;
                        toggleStates =
                            List<bool>.filled(responses.length, value);
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: responses.length,
                      itemBuilder: (context, index) {
                        final question = responses[index];
                        final questionDesc = question['Question Description'];
                        final rating = question['Rating'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: ListTile(
                            title: Text(questionDesc),
                            subtitle: Text("Rating: $rating"),
                            trailing: Switch(
                              value: toggleStates[index],
                              onChanged: (value) {
                                setState(() {
                                  toggleStates[index] = value;
                                });
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: Colors.redAccent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true; // Start the loader
                            });

                            await Future.delayed(
                                const Duration(seconds: 2)); // Simulate a delay

                            setState(() {
                              isLoading = false; // Stop the loader
                            });

                            _showConfirmationDialog(
                                context); // Show the confirmation dialog
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Submit"),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    for (int i = 0; i < responses.length; i++) {
      final question = responses[i];
      if (toggleStates[i]) {
        question['result']= false;
        question['Status'] = "Verified";
        question['Response Verified'] = true;
        question['Response_Status'] = "Verified";
        question['Response Verified By'] = user?.displayName ?? "Unknown";
        question['Response Checker Email ID'] = user?.email ?? "Unknown";
        question['Response Verification Date'] =
            DateTime.now().toIso8601String();
      } else {
        question['Status'] = "Rejected";
        question['Response Verified'] = false;
        question['Response_Status'] = "Rejected";
        question['Response Verified By'] = user?.displayName ?? "Unknown";
        question['Response Checker Email ID'] = user?.email ?? "Unknown";
        question['Response Verification Date'] =
            DateTime.now().toIso8601String();
      }
    }

    final docRef = FirebaseFirestore.instance
        .collection('FeedBack Form')
        .doc('lbKYsR8dnXn3BBbKL8ru')
        .collection('FeedBack Survey Data')
        .doc(widget.feedbackDocId);
    await docRef.update({
      'Response_Status': 'Verified',
      'Responses': responses,
    });

    print("Firestore updated successfully.");
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to submit the changes?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close

              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await _submitChanges();

                Navigator.of(context).pop();
                Navigator.of(context).pop();// Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Changes submitted successfully!")),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
