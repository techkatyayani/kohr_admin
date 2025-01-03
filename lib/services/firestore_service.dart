import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, Leave>> fetchLeaveData(String email) async {
    try {
      // Get the leave balances from the correct subcollection
      final leaveBalances = await _firestore
          .collection('profiles')
          .doc(email)
          .collection('leaveBalances')
          .get();

      Map<String, Leave> result = {};

      for (var doc in leaveBalances.docs) {
        final data = doc.data();
        result[doc.id] = Leave.fromMap({
          'accrued': data['accrued'] ?? 0.0,
          'used': data['used'] ?? 0.0,
          'requested': data['requested'] ?? 0.0,
          'accruedDisplay': data['accrued']?.toString() ?? '0.0',
        });
      }

      // If no data exists, provide default values
      if (result.isEmpty) {
        result = {
          'thisMonthSickLeaves': Leave.fromMap({}),
          'leaveWithoutPay': Leave.fromMap({}),
          'thisMonthCasualLeaves': Leave.fromMap({}),
        };
      }

      return result;
    } catch (e) {
      print('Error fetching leave data: $e');
      return {
        'thisMonthSickLeaves': Leave.fromMap({}),
        'leaveWithoutPay': Leave.fromMap({}),
        'thisMonthCasualLeaves': Leave.fromMap({}),
      };
    }
  }
}
