import 'package:cloud_firestore/cloud_firestore.dart';

class FetchSelectedCandidate {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Function to fetch applications for the given jobId
  Stream<List<Map<String, dynamic>>> fetchSelectedCandidates(String jobId) {
    return _firestore
        .collection(
        'hiring/$jobId/applications') // Access applications under the given job ID
        .where('hrRound', isEqualTo: 'Selected') // Filter by status
        .snapshots()
        .map((snapshot) {
      // Map each document to include applicationId (doc.id)
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['applicationId'] = doc.id; // Add the document ID
        return data;
      }).toList();
    });
  }
}
