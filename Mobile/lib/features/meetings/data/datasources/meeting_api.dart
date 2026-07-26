import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/meeting_dtos.dart';

/// Remote meetings / attendance / minutes API.
abstract class MeetingRemoteDataSource {
  Future<List<MeetingDto>> listMeetings({
    required String chamaId,
    String? search,
    String? status,
  });

  Future<MeetingDto> getMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<MeetingDto> scheduleMeeting({
    required String chamaId,
    required Map<String, dynamic> body,
  });

  Future<MeetingDto> updateMeeting({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  });

  Future<MeetingDto> cancelMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<MeetingDto> startMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<MeetingDto> closeMeeting({
    required String chamaId,
    required String meetingId,
  });

  Future<List<AttendanceRecordDto>> listAttendance({
    required String chamaId,
    required String meetingId,
  });

  Future<AttendanceDto> recordAttendance({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  });

  Future<List<AttendanceDto>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  });

  Future<AttendanceDto> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required Map<String, dynamic> body,
  });

  Future<MeetingMinutesDto?> getMinutes({
    required String chamaId,
    required String meetingId,
  });

  Future<MeetingMinutesDto> createMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  });

  Future<MeetingMinutesDto> updateMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  });

  Future<MeetingMinutesDto> approveMinutes({
    required String chamaId,
    required String meetingId,
  });
}

class MeetingApi implements MeetingRemoteDataSource {
  MeetingApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MeetingDto>> listMeetings({
    required String chamaId,
    String? search,
    String? status,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMeetings(chamaId),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
        'ordering': '-meeting_date',
      },
    );
    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!
        .map((e) => MeetingDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MeetingDto> getMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMeetingDetail(chamaId, meetingId),
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingDto> scheduleMeeting({
    required String chamaId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetings(chamaId),
      data: body,
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingDto> updateMeeting({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.chamaMeetingDetail(chamaId, meetingId),
      data: body,
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingDto> cancelMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiConstants.chamaMeetingDetail(chamaId, meetingId),
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingDto> startMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingStart(chamaId, meetingId),
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingDto> closeMeeting({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingClose(chamaId, meetingId),
    );
    return MeetingDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<List<AttendanceRecordDto>> listAttendance({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.chamaMeetingAttendance(chamaId, meetingId),
    );
    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!
        .map((e) => AttendanceRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceDto> recordAttendance({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingAttendance(chamaId, meetingId),
      data: body,
    );
    return AttendanceDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<List<AttendanceDto>> recordAttendanceBulk({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingAttendance(chamaId, meetingId),
      data: body,
    );
    final envelope = ApiResponse<List<dynamic>>.fromJson(
      response.data ?? {},
      (data) => data as List<dynamic>? ?? [],
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!
        .map((e) => AttendanceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AttendanceDto> updateAttendance({
    required String chamaId,
    required String meetingId,
    required String attendanceId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.chamaMeetingAttendanceDetail(
        chamaId,
        meetingId,
        attendanceId,
      ),
      data: body,
    );
    return AttendanceDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingMinutesDto?> getMinutes({
    required String chamaId,
    required String meetingId,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.chamaMeetingMinutes(chamaId, meetingId),
      );
      return MeetingMinutesDto.fromJson(_unwrapMap(response.data));
    } on AppException catch (e) {
      if (e.message.toLowerCase().contains('not found') ||
          e.message.contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<MeetingMinutesDto> createMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingMinutes(chamaId, meetingId),
      data: body,
    );
    return MeetingMinutesDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingMinutesDto> updateMinutes({
    required String chamaId,
    required String meetingId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiConstants.chamaMeetingMinutes(chamaId, meetingId),
      data: body,
    );
    return MeetingMinutesDto.fromJson(_unwrapMap(response.data));
  }

  @override
  Future<MeetingMinutesDto> approveMinutes({
    required String chamaId,
    required String meetingId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.chamaMeetingMinutesApprove(chamaId, meetingId),
    );
    return MeetingMinutesDto.fromJson(_unwrapMap(response.data));
  }

  Map<String, dynamic> _unwrapMap(Map<String, dynamic>? json) {
    final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
      json ?? {},
      (data) => Map<String, dynamic>.from(data as Map? ?? {}),
    );
    if (!envelope.success || envelope.data == null) {
      throw ServerException(message: envelope.message);
    }
    return envelope.data!;
  }
}
