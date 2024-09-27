class Attendance {
  String clockInAddress;
  double clockInLatitude;
  double clockInLongitude;
  String clockInTime;
  String clockOutAddress;
  double clockOutLatitude;
  double clockOutLongitude;
  String clockOutTime;
  String clockInImage;
  String clockOutImage;
  String startBreak;
  String startBreakAddress;
  double startBreakLatitude;
  double startBreakLongitude;
  String stopBreak;
  String stopBreakAddress;
  double stopBreakLatitude;
  double stopBreakLongitude;

  Attendance({
    this.clockInAddress = '',
    this.clockInLatitude = 0.0,
    this.clockInLongitude = 0.0,
    this.clockInTime = '',
    this.clockOutAddress = '',
    this.clockOutLatitude = 0.0,
    this.clockOutLongitude = 0.0,
    this.clockOutTime = '',
    this.clockInImage = '',
    this.clockOutImage = '',
    this.startBreak = '',
    this.startBreakAddress = '',
    this.startBreakLatitude = 0.0,
    this.startBreakLongitude = 0.0,
    this.stopBreak = '',
    this.stopBreakAddress = '',
    this.stopBreakLatitude = 0.0,
    this.stopBreakLongitude = 0.0,
  });

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      clockInAddress: data['clockInAddress'] ?? 'NA',
      clockInLatitude: (data['clockInLatitude'] as num?)?.toDouble() ?? 0.0,
      clockInLongitude: (data['clockInLongitude'] as num?)?.toDouble() ?? 0.0,
      clockInTime: data['clockInTime'] ?? 'NA',
      clockOutAddress: data['clockOutAddress'] ?? 'NA',
      clockOutLatitude: (data['clockOutLatitude'] as num?)?.toDouble() ?? 0.0,
      clockOutLongitude: (data['clockOutLongitude'] as num?)?.toDouble() ?? 0.0,
      clockOutTime: data['clockOutTime'] ?? 'NA',
      clockInImage: data['clockInImage'] ?? 'NA',
      clockOutImage: data['clockOutImage'] ?? 'NA',
      startBreak: data['startBreak'] ?? 'NA',
      startBreakAddress: data['StartBreakAddress'] ?? 'NA',
      startBreakLatitude:
          (data['startBreakLatitude'] as num?)?.toDouble() ?? 0.0,
      startBreakLongitude:
          (data['startBreakLongitude'] as num?)?.toDouble() ?? 0.0,
      stopBreak: data['stopBreak'] ?? 'NA',
      stopBreakAddress: data['StartBreakAddress'] ?? 'NA',
      stopBreakLatitude: (data['stopBreakLatitude'] as num?)?.toDouble() ?? 0.0,
      stopBreakLongitude:
          (data['stopBreakLongitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clockInAddress': clockInAddress,
      'clockInLatitude': clockInLatitude,
      'clockInLongitude': clockInLongitude,
      'clockInTime': clockInTime,
      'clockOutAddress': clockOutAddress,
      'clockOutLatitude': clockOutLatitude,
      'clockOutLongitude': clockOutLongitude,
      'clockOutTime': clockOutTime,
      'clockInImage': clockInImage,
      'clockOutImage': clockOutImage,
      'startBreak': startBreak,
      'StartBreakAddress': startBreakAddress,
      'startBreakLatitude': startBreakLatitude,
      'startBreakLongitude': startBreakLongitude,
      'stopBreak': stopBreak,
      'StopBreakAddress': stopBreakAddress,
      'stopBreakLatitude': stopBreakLatitude,
      'stopBreakLongitude': stopBreakLongitude,
    };
  }
}
