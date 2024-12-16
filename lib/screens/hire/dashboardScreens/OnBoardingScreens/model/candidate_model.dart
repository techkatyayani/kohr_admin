// import 'package:cloud_firestore/cloud_firestore.dart';

// class CandidateModel {
//   final String firstName;
//   final String lastName;
//   final String email;
//   final String contactNumber;
//   final String address;
//   final String? graduation;
//   final String experience;
//   final List<String> skills;
//   final String recruiter;
//   final String expectedSalary;
//   final DateTime? submittedAt;
//   final String resumeUrl;
//   final String status;
//   final String source;
//   final String profile;
//   final String? callStatus;
//   final String finalStatus;
//   final String remarks;
//   final String offerLetter;
//   final String? resumeStatus;
//   final String? assessmentStatus;
//   final String? hrRoundStatus;
//   final String? techRoundStatus;
//   final String techRecruiter;
//   final String hrRecruiter;
//   final String callBy;
//   final int assessmentMarks;
//   final String? assessmentRemark;
//   final double? technicalRating;
//   final String? technicalRemark;
//   final String? hrRemark;
//   final int callAttempts;
//   final CallRatings callRatings;

//   CandidateModel({
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.contactNumber,
//     required this.address,
//     this.graduation,
//     required this.experience,
//     required this.skills,
//     required this.recruiter,
//     required this.expectedSalary,
//     this.submittedAt,
//     required this.resumeUrl,
//     required this.status,
//     required this.source,
//     required this.profile,
//     this.callStatus,
//     required this.finalStatus,
//     required this.remarks,
//     required this.offerLetter,
//     this.resumeStatus,
//     this.assessmentStatus,
//     this.hrRoundStatus,
//     this.techRoundStatus,
//     required this.techRecruiter,
//     required this.hrRecruiter,
//     required this.callBy,
//     required this.assessmentMarks,
//     this.assessmentRemark,
//     this.technicalRating,
//     this.technicalRemark,
//     this.hrRemark,
//     required this.callAttempts,
//     required this.callRatings,
//   });

//   factory CandidateModel.fromJson(Map<String, dynamic> json) {
//     return CandidateModel(
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       email: json['email'] as String,
//       contactNumber: json['contactNumber'] as String,
//       address: json['address'] as String,
//       graduation: json['graduation'] as String?,
//       experience: json['experience'] as String,
//       skills: List<String>.from(json['skills'] as List),
//       recruiter: json['recruiter'] as String,
//       expectedSalary: json['expectedSalary'] as String,
//       submittedAt: json['submittedAt'] != null
//           ? (json['submittedAt'] as Timestamp).toDate()
//           : null,
//       resumeUrl: json['resumeUrl'] as String,
//       status: json['status'] as String,
//       source: json['source'] as String,
//       profile: json['profile'] as String,
//       callStatus: json['callStatus'] as String?,
//       finalStatus: json['finalStatus'] as String,
//       remarks: json['remarks'] as String,
//       offerLetter: json['offerLetter'] as String,
//       resumeStatus: json['resumeStatus'] as String?,
//       assessmentStatus: json['assessmentStatus'] as String?,
//       hrRoundStatus: json['hrRoundStatus'] as String?,
//       techRoundStatus: json['techRoundStatus'] as String?,
//       techRecruiter: json['techRecruiter'] as String,
//       hrRecruiter: json['hrRecruiter'] as String,
//       callBy: json['callBy'] as String,
//       assessmentMarks: json['assessmentMarks'] as int,
//       assessmentRemark: json['assessmentRemark'] as String?,
//       technicalRating: (json['technicalRating'] as num?)?.toDouble(),
//       technicalRemark: json['technicalRemark'] as String?,
//       hrRemark: json['hrRemark'] as String?,
//       callAttempts: json['callAttempts'] as int,
//       callRatings: CallRatings.fromJson(json['callRatings']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'firstName': firstName,
//       'lastName': lastName,
//       'email': email,
//       'contactNumber': contactNumber,
//       'address': address,
//       'graduation': graduation,
//       'experience': experience,
//       'skills': skills,
//       'recruiter': recruiter,
//       'expectedSalary': expectedSalary,
//       'submittedAt': submittedAt,
//       'resumeUrl': resumeUrl,
//       'status': status,
//       'source': source,
//       'profile': profile,
//       'callStatus': callStatus,
//       'finalStatus': finalStatus,
//       'remarks': remarks,
//       'offerLetter': offerLetter,
//       'resumeStatus': resumeStatus,
//       'assessmentStatus': assessmentStatus,
//       'hrRoundStatus': hrRoundStatus,
//       'techRoundStatus': techRoundStatus,
//       'techRecruiter': techRecruiter,
//       'hrRecruiter': hrRecruiter,
//       'callBy': callBy,
//       'assessmentMarks': assessmentMarks,
//       'assessmentRemark': assessmentRemark,
//       'technicalRating': technicalRating,
//       'technicalRemark': technicalRemark,
//       'hrRemark': hrRemark,
//       'callAttempts': callAttempts,
//       'callRatings': callRatings.toJson(),
//     };
//   }
// }

// class CallRatings {
//   final int ratings;
//   final int totalRating;

//   CallRatings({required this.ratings, required this.totalRating});

//   factory CallRatings.fromJson(Map<String, dynamic> json) {
//     return CallRatings(
//       ratings: json['ratings'] as int,
//       totalRating: json['totalRating'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'ratings': ratings,
//       'totalRating': totalRating,
//     };
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class CandidateModel {
  final String? applicationId;
  final String firstName;
  final String lastName;
  final String email;
  final String contactNumber;
  final String address;
  final String graduation;
  final String experience;
  final List<String> skills;
  final String recruiter;
  final String expectedSalary;
  final DateTime? submittedAt;
  final String resumeUrl;
  final String status;
  final String source;
  final String profile;
  final String? callStatus;
  final String finalStatus;
  final String remarks;
  final String offerLetter;
  final String? resumeStatus;
  final String? assessmentStatus;
  final String? hrRoundStatus;
  final String? techRoundStatus;
  final String techRecruiter;
  final String hrRecruiter;
  final String callBy;
  final int assessmentMarks;
  final String? assessmentRemark;
  final String? technicalRating;
  final String? technicalRemark;
  final String? hrRemark;
  final int callAttempts;
  final Map<String, dynamic> callRatings;

  CandidateModel({
    this.applicationId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.graduation,
    required this.experience,
    required this.skills,
    required this.recruiter,
    required this.expectedSalary,
    this.submittedAt,
    required this.resumeUrl,
    required this.status,
    required this.source,
    required this.profile,
    this.callStatus,
    required this.finalStatus,
    required this.remarks,
    required this.offerLetter,
    this.resumeStatus,
    this.assessmentStatus,
    this.hrRoundStatus,
    this.techRoundStatus,
    required this.techRecruiter,
    required this.hrRecruiter,
    required this.callBy,
    required this.assessmentMarks,
    this.assessmentRemark,
    this.technicalRating,
    this.technicalRemark,
    this.hrRemark,
    required this.callAttempts,
    required this.callRatings,
  });

  // Convert Firestore document to CandidateModel
  factory CandidateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CandidateModel(
      applicationId: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      address: data['address'] ?? '',
      graduation: data['graduation'] ?? '',
      experience: data['experience'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      recruiter: data['recruiter'] ?? '',
      expectedSalary: data['expectedSalary'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      resumeUrl: data['resumeUrl'] ?? '',
      status: data['status'] ?? '',
      source: data['source'] ?? '',
      profile: data['profile'] ?? '',
      callStatus: data['callStatus'],
      finalStatus: data['finalStatus'] ?? '',
      remarks: data['remarks'] ?? '',
      offerLetter: data['offerLetter'] ?? '',
      resumeStatus: data['resumeStatus'],
      assessmentStatus: data['assessmentStatus'],
      hrRoundStatus: data['hrRoundStatus'],
      techRoundStatus: data['techRoundStatus'],
      techRecruiter: data['techRecruiter'] ?? '',
      hrRecruiter: data['hrRecruiter'] ?? '',
      callBy: data['callBy'] ?? '',
      assessmentMarks: data['assessmentMarks'] ?? 0,
      assessmentRemark: data['assessmentRemark'],
      technicalRating: data['technicalRating'],
      technicalRemark: data['technicalRemark'],
      hrRemark: data['hrRemark'],
      callAttempts: data['callAttempts'] ?? 0,
      callRatings: Map<String, dynamic>.from(data['callRatings'] ?? {}),
    );
  }

  // Convert CandidateModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'contactNumber': contactNumber,
      'address': address,
      'graduation': graduation,
      'experience': experience,
      'skills': skills,
      'recruiter': recruiter,
      'expectedSalary': expectedSalary,
      'submittedAt':
          submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'resumeUrl': resumeUrl,
      'status': status,
      'source': source,
      'profile': profile,
      'callStatus': callStatus,
      'finalStatus': finalStatus,
      'remarks': remarks,
      'offerLetter': offerLetter,
      'resumeStatus': resumeStatus,
      'assessmentStatus': assessmentStatus,
      'hrRoundStatus': hrRoundStatus,
      'techRoundStatus': techRoundStatus,
      'techRecruiter': techRecruiter,
      'hrRecruiter': hrRecruiter,
      'callBy': callBy,
      'assessmentMarks': assessmentMarks,
      'assessmentRemark': assessmentRemark,
      'technicalRating': technicalRating,
      'technicalRemark': technicalRemark,
      'hrRemark': hrRemark,
      'callAttempts': callAttempts,
      'callRatings': callRatings,
    };
  }
}
