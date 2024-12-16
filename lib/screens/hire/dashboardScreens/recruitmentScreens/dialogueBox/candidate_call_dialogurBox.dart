import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateCallDialog extends StatefulWidget {
  final String jobId;
  final String applicationId;
  final String callStatus;
  final int callAttempts;

  const CandidateCallDialog({
    Key? key,
    required this.jobId,
    required this.applicationId,
    required this.callStatus,
    required this.callAttempts,
  }) : super(key: key);

  @override
  _CandidateCallDialogState createState() => _CandidateCallDialogState();
}

class _CandidateCallDialogState extends State<CandidateCallDialog> {
  // Questions for assessment
  final List<String> questions = [
    "Q1: Rate the candidate's communication.",
    "Q2: Rate the candidate's confidence.",
    "Q3: Rate the candidate's experience relevance.",
    "Q4: Rate the candidate's clarity of responses.",
    "Q5: Rate the candidate's enthusiasm."
  ];

  // Ratings for each question, initialized to 0
  late List<int> ratings;

  @override
  void initState() {
    super.initState();
    ratings = List<int>.filled(questions.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Call Assessment"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please evaluate the candidate based on the following questions:"),
            const SizedBox(height: 16),
            ...List.generate(questions.length, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(questions[index]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (starIndex) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: starIndex < ratings[index] ? Colors.orange : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            ratings[index] = starIndex + 1; // Update rating
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

          onPressed: () {
            final int totalRating = ratings.reduce((a, b) => a + b);

            // Update Firestore with callStatus, callAttempts, and ratings
            FirebaseFirestore.instance
                .collection('hiring/${widget.jobId}/applications')
                .doc(widget.applicationId)
                .update({
              'callStatus': widget.callStatus,
              'callAttempts': widget.callAttempts,
              'callRatings': {
                'ratings': ratings,
                'totalRating': totalRating,
              },
            }).then((_) {
              Navigator.pop(context); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call data successfully updated!')),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating call data: $error')),
              );
            });
          },
          child: const Text("Submit",style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
//
// class CallStatusButtons extends StatelessWidget {
//   final Map<String, dynamic> candidate;
//   final String jobId;
//
//   const CallStatusButtons({
//     Key? key,
//     required this.candidate,
//     required this.jobId,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final int callAttempts = candidate['callAttempts'] ?? 0;
//
//     // Ensure that candidate's resumeStatus and callStatus are not null
//     final String? callStatus = candidate['callStatus'];
//     final String resumeStatus = candidate['resumeStatus'] ?? 'No Status'; // Default to 'No Status' if null
//
//     if (callStatus == null && resumeStatus == 'Selected') {
//       return Positioned(
//         bottom: 20,
//         right: 20,
//         child: Column(
//           children: [
//             if (callAttempts < 3)
//               SizedBox(
//                 width: 140,
//                 height: 40,
//                 child: FloatingActionButton.extended(
//                   heroTag: "Call Received",
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => CandidateCallDialog(
//                         jobId: jobId,
//                         applicationId: candidate['applicationId'] ?? '',
//                         callStatus: "Received",
//                         callAttempts: callAttempts + 1,
//                       ),
//                     );
//                   },
//                   backgroundColor: Colors.green,
//                   label: const Text(
//                     "Call Received",
//                     style: TextStyle(fontSize: 12), // Smaller text
//                   ),
//                   icon: const Icon(Icons.check, size: 18), // Smaller icon
//                 ),
//               ),
//             const SizedBox(height: 8),
//             if (callAttempts < 3)
//               SizedBox(
//                 width: 140,
//                 height: 40,
//                 child: FloatingActionButton.extended(
//                   heroTag: "Not Received",
//                   onPressed: () {
//                     if (callAttempts + 1 < 3) {
//                       showDialog(
//                         context: context,
//                         builder: (context) => CandidateCallDialog(
//                           jobId: jobId,
//                           applicationId: candidate['applicationId'] ?? '',
//                           callStatus: "Not-Received",
//                           callAttempts: callAttempts + 1,
//                         ),
//                       );
//                     } else {
//                       FirebaseFirestore.instance
//                           .collection('hiring/$jobId/applications')
//                           .doc(candidate['applicationId'] ?? '')
//                           .update({
//                         'callStatus': "Not-Received",
//                         'callAttempts': callAttempts + 1,
//                       }).then((_) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Candidate marked as Not-Received permanently')),
//                         );
//                       });
//                     }
//                   },
//                   backgroundColor: Colors.red,
//                   label: const Text(
//                     "Not Received",
//                     style: TextStyle(fontSize: 12), // Smaller text
//                   ),
//                   icon: const Icon(Icons.close, size: 18), // Smaller icon
//                 ),
//               ),
//             if (callAttempts >= 3)
//               const Text(
//                 "No more call attempts allowed",
//                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//               ),
//           ],
//         ),
//       );
//     }
//     return const SizedBox.shrink(); // Return an empty widget if conditions are not met
//   }
// }
