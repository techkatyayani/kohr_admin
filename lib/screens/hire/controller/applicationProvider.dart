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

