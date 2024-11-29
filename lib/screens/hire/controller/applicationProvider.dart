import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class ApplicationProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  List<Map<String, dynamic>> _pendingApplications = [];
  String jobId = "";

  List<Map<String, dynamic>> get pendingApplications => _pendingApplications;

  void fetchPendingApplications(String jobId) {
    _service.fetchPendingApplications(jobId).listen((applications) {
      _pendingApplications = applications;
      notifyListeners();
    });
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ApplicationProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _pendingApplications = [];
//   List<Map<String, dynamic>> _selectedApplications = [];
//   List<Map<String, dynamic>> _rejectedApplications = [];
//
//   List<Map<String, dynamic>> get pendingApplications => _pendingApplications;
//   List<Map<String, dynamic>> get selectedApplications => _selectedApplications;
//   List<Map<String, dynamic>> get rejectedApplications => _rejectedApplications;
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Fetch applications from Firestore and filter based on their status
//   Future<void> fetchApplications(String jobId,String applicationId) async {
//     try {
//       // Query the applications collection under the jobId
//       QuerySnapshot snapshot = await _firestore
//           .collection('hiring')
//           .doc(jobId) // Reference the specific HR-2 document
//           .collection('applications') // Query the 'applications' subcollection
//           .where('applicationId', isEqualTo: applicationId) // Filter by jobId
//           .get();
//
//       List<Map<String, dynamic>> applications = [];
//
//       for (var doc in snapshot.docs) {
//         applications.add(doc.data() as Map<String, dynamic>);
//       }
//
//       // Filter the applications based on status
//       _pendingApplications = applications
//           .where((app) => app['status'] == 'Pending')
//           .toList();
//       _selectedApplications = applications
//           .where((app) => app['status'] == 'Selected')
//           .toList();
//       _rejectedApplications = applications
//           .where((app) => app['status'] == 'Rejected')
//           .toList();
//
//       notifyListeners(); // Notify listeners to rebuild the UI
//     } catch (e) {
//       print("Error fetching applications: $e");
//     }
//   }
// }
