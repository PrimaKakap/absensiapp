class AttendanceModel {
  final String attendanceId;
  final String employeeId;
  final String shiftId;
  final String locationId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final double latitudeIn;
  final double longitudeIn;
  final double? latitudeOut;
  final double? longitudeOut;
  final String photoInUrl;
  final String? photoOutUrl;
  final bool isOutOfBounds;
  final String? outOfBoundsReason;
  final int latenessMinutes;
  final String status;

  AttendanceModel({
    required this.attendanceId,
    required this.employeeId,
    required this.shiftId,
    required this.locationId,
    required this.clockInTime,
    this.clockOutTime,
    required this.latitudeIn,
    required this.longitudeIn,
    this.latitudeOut,
    this.longitudeOut,
    required this.photoInUrl,
    this.photoOutUrl,
    required this.isOutOfBounds,
    this.outOfBoundsReason,
    required this.latenessMinutes,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceId: json['attendance_id'],
      employeeId: json['employee_id'],
      shiftId: json['shift_id'],
      locationId: json['location_id'],
      clockInTime: DateTime.parse(json['clock_in_time']),
      clockOutTime: json['clock_out_time'] != null
          ? DateTime.parse(json['clock_out_time'])
          : null,
      latitudeIn: (json['latitude_in'] as num).toDouble(),
      longitudeIn: (json['longitude_in'] as num).toDouble(),
      latitudeOut: json['latitude_out'] != null
          ? (json['latitude_out'] as num).toDouble()
          : null,
      longitudeOut: json['longitude_out'] != null
          ? (json['longitude_out'] as num).toDouble()
          : null,
      photoInUrl: json['photo_in_url'],
      photoOutUrl: json['photo_out_url'],
      isOutOfBounds: json['is_out_of_bounds'] ?? false,
      outOfBoundsReason: json['out_of_bounds_reason'],
      latenessMinutes: json['lateness_minutes'] ?? 0,
      status: json['status'] ?? 'PRESENT',
    );
  }
}