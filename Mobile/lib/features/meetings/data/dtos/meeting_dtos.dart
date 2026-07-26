import '../../domain/entities/meeting.dart';

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}

String _asTime(dynamic value) {
  if (value == null) return '';
  final raw = '$value';
  // Backend may send "14:00:00" or "14:00".
  return raw.length >= 5 ? raw.substring(0, 5) : raw;
}

class MeetingDto {
  const MeetingDto({
    required this.id,
    required this.chamaId,
    required this.title,
    this.description,
    required this.meetingType,
    required this.venue,
    required this.meetingDate,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.attendanceFinalized,
    this.createdById,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chamaId;
  final String title;
  final String? description;
  final String meetingType;
  final String venue;
  final String meetingDate;
  final String startTime;
  final String? endTime;
  final String status;
  final bool attendanceFinalized;
  final String? createdById;
  final String? createdAt;
  final String? updatedAt;

  factory MeetingDto.fromJson(Map<String, dynamic> json) {
    return MeetingDto(
      id: '${json['id']}',
      chamaId: '${json['chama_id']}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      meetingType: json['meeting_type'] as String? ?? 'ordinary',
      venue: json['venue'] as String? ?? '',
      meetingDate: '${json['meeting_date'] ?? ''}',
      startTime: '${json['start_time'] ?? ''}',
      endTime: json['end_time']?.toString(),
      status: json['status'] as String? ?? 'scheduled',
      attendanceFinalized: json['attendance_finalized'] as bool? ?? false,
      createdById: json['created_by_id']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Meeting toEntity() {
    return Meeting(
      id: id,
      chamaId: chamaId,
      title: title,
      description: description,
      meetingType: MeetingType.fromApi(meetingType),
      venue: venue,
      meetingDate: _asDate(meetingDate) ?? DateTime.now(),
      startTime: _asTime(startTime),
      endTime: endTime == null ? null : _asTime(endTime),
      status: MeetingStatus.fromApi(status),
      attendanceFinalized: attendanceFinalized,
      createdById: createdById,
      createdAt: _asDate(createdAt),
      updatedAt: _asDate(updatedAt),
    );
  }
}

class AttendanceRecordDto {
  const AttendanceRecordDto({
    required this.memberId,
    required this.memberName,
    this.attendanceId,
    this.status,
    this.arrivalTime,
    this.remarks = '',
    this.recordedById,
  });

  final String memberId;
  final String memberName;
  final String? attendanceId;
  final String? status;
  final String? arrivalTime;
  final String remarks;
  final String? recordedById;

  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordDto(
      memberId: '${json['member_id']}',
      memberName: json['member_name'] as String? ?? '',
      attendanceId: json['attendance_id']?.toString(),
      status: json['status'] as String?,
      arrivalTime: json['arrival_time']?.toString(),
      remarks: json['remarks'] as String? ?? '',
      recordedById: json['recorded_by_id']?.toString(),
    );
  }

  AttendanceRecord toEntity() {
    return AttendanceRecord(
      memberId: memberId,
      memberName: memberName,
      attendanceId: attendanceId,
      status: status == null ? null : AttendanceStatus.fromApi(status),
      arrivalTime: arrivalTime == null ? null : _asTime(arrivalTime),
      remarks: remarks,
      recordedById: recordedById,
    );
  }
}

class AttendanceDto {
  const AttendanceDto({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.status,
    this.arrivalTime,
    this.remarks = '',
    this.recordedById,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String memberId;
  final String status;
  final String? arrivalTime;
  final String remarks;
  final String? recordedById;
  final String? createdAt;
  final String? updatedAt;

  factory AttendanceDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDto(
      id: '${json['id']}',
      meetingId: '${json['meeting_id']}',
      memberId: '${json['member_id']}',
      status: json['status'] as String? ?? 'absent',
      arrivalTime: json['arrival_time']?.toString(),
      remarks: json['remarks'] as String? ?? '',
      recordedById: json['recorded_by_id']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Attendance toEntity() {
    return Attendance(
      id: id,
      meetingId: meetingId,
      memberId: memberId,
      status: AttendanceStatus.fromApi(status),
      arrivalTime: arrivalTime == null ? null : _asTime(arrivalTime),
      remarks: remarks,
      recordedById: recordedById,
      createdAt: _asDate(createdAt),
      updatedAt: _asDate(updatedAt),
    );
  }
}

class MeetingMinutesDto {
  const MeetingMinutesDto({
    required this.id,
    required this.meetingId,
    required this.minutes,
    required this.resolutions,
    required this.actionItems,
    this.preparedById,
    required this.approved,
    this.approvedById,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String meetingId;
  final String minutes;
  final List<dynamic> resolutions;
  final List<dynamic> actionItems;
  final String? preparedById;
  final bool approved;
  final String? approvedById;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;

  factory MeetingMinutesDto.fromJson(Map<String, dynamic> json) {
    return MeetingMinutesDto(
      id: '${json['id']}',
      meetingId: '${json['meeting_id']}',
      minutes: json['minutes'] as String? ?? '',
      resolutions: json['resolutions'] as List<dynamic>? ?? const [],
      actionItems: json['action_items'] as List<dynamic>? ?? const [],
      preparedById: json['prepared_by_id']?.toString(),
      approved: json['approved'] as bool? ?? false,
      approvedById: json['approved_by_id']?.toString(),
      approvedAt: json['approved_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  MeetingMinutes toEntity() {
    return MeetingMinutes(
      id: id,
      meetingId: meetingId,
      minutes: minutes,
      resolutions: resolutions.map((e) => '$e').toList(),
      actionItems: actionItems.map((e) {
        if (e is Map<String, dynamic>) {
          return MeetingActionItem.fromJson(e);
        }
        if (e is Map) {
          return MeetingActionItem.fromJson(Map<String, dynamic>.from(e));
        }
        return MeetingActionItem(task: '$e');
      }).toList(),
      preparedById: preparedById,
      approved: approved,
      approvedById: approvedById,
      approvedAt: _asDate(approvedAt),
      createdAt: _asDate(createdAt),
      updatedAt: _asDate(updatedAt),
    );
  }
}
