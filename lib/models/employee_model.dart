import 'package:kohr_admin/models/attendance_model.dart';

class Employee {
  String aadharNumber;
  String age;
  String bankAccountNumber;
  String bankName;
  String birthday;
  String confirmationDate;
  String countryCode;
  String phoneNumber;
  String department;
  String email;
  String employeeCode;
  String employeeStatus;
  String employeeType;
  String fatherName;
  String firstName;
  String gender;
  String id;
  String ifscCode;
  String joiningDate;
  String lastName;
  String location;
  String middleName;
  String mobile;
  String homePhoneNumber;
  String permanentAddress;
  String correspondenceAddress;
  String name;
  String noticeDuringProbation;
  String noticePeriod;
  String noticePostProbation;
  String probationPeriod;
  String reportingManager;
  String reportingManagerCode;
  String retirementAge;
  String workEmail;
  String workExperience;
  String personalEmail;
  String bloodGroup;
  String healthInsurancePolicy;
  String healthInsurancePremium;
  String accidentalInsurancePolicy;
  String anniversary;
  String familyName;
  String familyRelationship;
  String familyDateOfBirth;
  String familyContact;
  String familyAddress;
  String degree;
  String specialization;
  String college;
  String degreeTime;
  String experienceTitle;
  String experienceLocation;
  String experienceTime;
  String experienceDescription;
  String cardNumber;
  String beneficiaryName;
  String panCardNumber;
  String grossSalary;
  String ctc;
  String contractPeriod;
  String tenureLastDate;
  String retirementDate;
  String workMode;
  List<Attendance> attendanceRecords;

  Employee({
    this.aadharNumber = '',
    this.age = '',
    this.bankAccountNumber = '',
    this.bankName = '',
    this.birthday = '',
    this.confirmationDate = '',
    this.countryCode = '',
    this.phoneNumber = '',
    this.department = '',
    this.email = '',
    this.employeeCode = '',
    this.employeeStatus = '',
    this.employeeType = '',
    this.fatherName = '',
    this.firstName = '',
    this.gender = '',
    this.id = '',
    this.ifscCode = '',
    this.joiningDate = '',
    this.lastName = '',
    this.location = '',
    this.middleName = '',
    this.mobile = '',
    this.homePhoneNumber = '',
    this.permanentAddress = '',
    this.correspondenceAddress = '',
    this.name = '',
    this.noticeDuringProbation = '',
    this.noticePeriod = '',
    this.noticePostProbation = '',
    this.probationPeriod = '',
    this.reportingManager = '',
    this.reportingManagerCode = '',
    this.retirementAge = '',
    this.workEmail = '',
    this.workExperience = '',
    this.personalEmail = '',
    this.bloodGroup = '',
    this.healthInsurancePolicy = '',
    this.healthInsurancePremium = '',
    this.accidentalInsurancePolicy = '',
    this.anniversary = '',
    this.familyName = '',
    this.familyRelationship = '',
    this.familyDateOfBirth = '',
    this.familyContact = '',
    this.familyAddress = '',
    this.degree = '',
    this.specialization = '',
    this.college = '',
    this.degreeTime = '',
    this.experienceTitle = '',
    this.experienceLocation = '',
    this.experienceTime = '',
    this.experienceDescription = '',
    this.cardNumber = '',
    this.beneficiaryName = '',
    this.panCardNumber = '',
    this.grossSalary = '',
    this.ctc = '',
    this.contractPeriod = '',
    this.tenureLastDate = '',
    this.retirementDate = '',
    this.workMode = '',
    this.attendanceRecords = const [],
  });

  factory Employee.fromMap(Map<String, dynamic> data) {
    return Employee(
      aadharNumber: data['aadharNumber'] ?? '',
      age: data['age'] ?? '',
      bankAccountNumber: data['bankAccountNumber'] ?? '',
      bankName: data['bankName'] ?? '',
      birthday: data['birthday'] ?? '',
      confirmationDate: data['confirmationDate'] ?? '',
      countryCode: data['countryCode'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      department: data['department'] ?? '',
      email: data['email'] ?? '',
      employeeCode: data['employeeCode'] ?? '',
      employeeStatus: data['employeeStatus'] ?? '',
      employeeType: data['employeeType'] ?? '',
      fatherName: data['fatherName'] ?? '',
      firstName: data['firstName'] ?? '',
      gender: data['gender'] ?? '',
      id: data['id'] ?? '',
      ifscCode: data['ifscCode'] ?? '',
      joiningDate: data['joiningDate'] ?? '',
      lastName: data['lastName'] ?? '',
      location: data['location'] ?? '',
      middleName: data['middleName'] ?? '',
      mobile: data['mobile'] ?? '',
      homePhoneNumber: data['homePhoneNumber'] ?? '',
      permanentAddress: data['permanentAddress'] ?? '',
      correspondenceAddress: data['correspondenceAddress'] ?? '',
      name: data['name'] ?? '',
      noticeDuringProbation: data['noticeDuringProbation'] ?? '',
      noticePeriod: data['noticePeriod'] ?? '',
      noticePostProbation: data['noticePostProbation'] ?? '',
      probationPeriod: data['probationPeriod'] ?? '',
      reportingManager: data['reportingManager'] ?? '',
      reportingManagerCode: data['reportingManagerCode'] ?? '',
      retirementAge: data['retirementAge'] ?? '',
      workEmail: data['workEmail'] ?? '',
      workExperience: data['workExperience'] ?? '',
      personalEmail: data['personalEmail'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      healthInsurancePolicy: data['healthInsurancePolicy'] ?? '',
      healthInsurancePremium: data['healthInsurancePremium'] ?? '',
      accidentalInsurancePolicy: data['accidentalInsurancePolicy'] ?? '',
      anniversary: data['anniversary'] ?? '',
      familyName: data['familyName'] ?? '',
      familyRelationship: data['familyRelationship'] ?? '',
      familyDateOfBirth: data['familyDateOfBirth'] ?? '',
      familyContact: data['familyContact'] ?? '',
      familyAddress: data['familyAddress'] ?? '',
      degree: data['degree'] ?? '',
      specialization: data['specialization'] ?? '',
      college: data['college'] ?? '',
      degreeTime: data['degreeTime'] ?? '',
      experienceTitle: data['experienceTitle'] ?? '',
      experienceLocation: data['experienceLocation'] ?? '',
      experienceTime: data['experienceTime'] ?? '',
      experienceDescription: data['experienceDescription'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      beneficiaryName: data['beneficiaryName'] ?? '',
      panCardNumber: data['panCardNumber'] ?? '',
      grossSalary: data['grossSalary'] ?? '',
      ctc: data['ctc'] ?? '',
      contractPeriod: data['contractPeriod'] ?? '',
      tenureLastDate: data['tenureLastDate'] ?? '',
      retirementDate: data['retirementDate'] ?? '',
      workMode: data['workMode'] ?? '',
      attendanceRecords: data['attendanceRecords'] != null
          ? List<Attendance>.from(
              data['attendanceRecords'].map((item) => Attendance.fromMap(item)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aadharNumber': aadharNumber,
      'age': age,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'birthday': birthday,
      'confirmationDate': confirmationDate,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'department': department,
      'email': email,
      'employeeCode': employeeCode,
      'employeeStatus': employeeStatus,
      'employeeType': employeeType,
      'fatherName': fatherName,
      'firstName': firstName,
      'gender': gender,
      'id': id,
      'ifscCode': ifscCode,
      'joiningDate': joiningDate,
      'lastName': lastName,
      'location': location,
      'middleName': middleName,
      'mobile': mobile,
      'homePhoneNumber': homePhoneNumber,
      'permanentAddress': permanentAddress,
      'correspondenceAddress': correspondenceAddress,
      'name': name,
      'noticeDuringProbation': noticeDuringProbation,
      'noticePeriod': noticePeriod,
      'noticePostProbation': noticePostProbation,
      'probationPeriod': probationPeriod,
      'reportingManager': reportingManager,
      'reportingManagerCode': reportingManagerCode,
      'retirementAge': retirementAge,
      'workEmail': workEmail,
      'workExperience': workExperience,
      'personalEmail': personalEmail,
      'bloodGroup': bloodGroup,
      'healthInsurancePolicy': healthInsurancePolicy,
      'healthInsurancePremium': healthInsurancePremium,
      'accidentalInsurancePolicy': accidentalInsurancePolicy,
      'anniversary': anniversary,
      'familyName': familyName,
      'familyRelationship': familyRelationship,
      'familyDateOfBirth': familyDateOfBirth,
      'familyContact': familyContact,
      'familyAddress': familyAddress,
      'degree': degree,
      'specialization': specialization,
      'college': college,
      'degreeTime': degreeTime,
      'experienceTitle': experienceTitle,
      'experienceLocation': experienceLocation,
      'experienceTime': experienceTime,
      'experienceDescription': experienceDescription,
      'cardNumber': cardNumber,
      'beneficiaryName': beneficiaryName,
      'panCardNumber': panCardNumber,
      'grossSalary': grossSalary,
      'ctc': ctc,
      'contractPeriod': contractPeriod,
      'tenureLastDate': tenureLastDate,
      'retirementDate': retirementDate,
      'workMode': workMode,
      'attendanceRecords':
          attendanceRecords.map((item) => item.toMap()).toList(),
    };
  }
}
