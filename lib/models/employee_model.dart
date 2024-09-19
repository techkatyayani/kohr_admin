class Employee {
  String aadharNumber;
  String age;
  String bankAccountNumber;
  String bankName;
  String birthday;
  String confirmationDate;
  String countryCode;
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

  Employee({
    required this.aadharNumber,
    required this.age,
    required this.bankAccountNumber,
    required this.bankName,
    required this.birthday,
    required this.confirmationDate,
    required this.countryCode,
    required this.department,
    required this.email,
    required this.employeeCode,
    required this.employeeStatus,
    required this.employeeType,
    required this.fatherName,
    required this.firstName,
    required this.gender,
    required this.id,
    required this.ifscCode,
    required this.joiningDate,
    required this.lastName,
    required this.location,
    required this.middleName,
    required this.mobile,
    required this.name,
    required this.noticeDuringProbation,
    required this.noticePeriod,
    required this.noticePostProbation,
    required this.probationPeriod,
    required this.reportingManager,
    required this.reportingManagerCode,
    required this.retirementAge,
    required this.workEmail,
    required this.workExperience,
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
    };
  }
}
