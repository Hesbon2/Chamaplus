import '../../domain/entities/chama.dart';

class ChamaDto {
  const ChamaDto({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.currency,
    this.inviteCode,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? location;
  final String currency;
  final String? inviteCode;
  final bool isActive;
  final String? createdAt;

  factory ChamaDto.fromJson(Map<String, dynamic> json) {
    return ChamaDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      currency: json['currency'] as String? ?? 'KES',
      inviteCode: json['invite_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
    );
  }

  Chama toEntity() {
    return Chama(
      id: id,
      name: name,
      description: description,
      location: location,
      currency: currency,
      inviteCode: inviteCode,
      isActive: isActive,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}

class MembershipDto {
  const MembershipDto({
    required this.id,
    required this.user,
    required this.role,
    required this.status,
    this.joinedAt,
    this.createdAt,
    this.chamaId,
    this.chamaName,
  });

  final String id;
  final MemberUserDto user;
  final MemberRoleDto role;
  final String status;
  final String? joinedAt;
  final String? createdAt;
  final String? chamaId;
  final String? chamaName;

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    final chama = json['chama'];
    String? chamaId;
    String? chamaName;
    if (chama is Map<String, dynamic>) {
      chamaId = chama['id']?.toString();
      chamaName = chama['name'] as String?;
    }
    return MembershipDto(
      id: json['id'] as String,
      user: MemberUserDto.fromJson(json['user'] as Map<String, dynamic>),
      role: MemberRoleDto.fromJson(json['role'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joined_at'] as String?,
      createdAt: json['created_at'] as String?,
      chamaId: chamaId,
      chamaName: chamaName,
    );
  }

  Membership toEntity() {
    return Membership(
      id: id,
      user: user.toEntity(),
      role: role.toEntity(),
      status: MembershipStatus.fromApi(status),
      joinedAt: joinedAt != null ? DateTime.tryParse(joinedAt!) : null,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      chamaId: chamaId,
      chamaName: chamaName,
    );
  }
}

class MemberUserDto {
  const MemberUserDto({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;

  factory MemberUserDto.fromJson(Map<String, dynamic> json) {
    return MemberUserDto(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }

  MemberUser toEntity() {
    return MemberUser(
      id: id,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

class MemberRoleDto {
  const MemberRoleDto({
    required this.id,
    required this.slug,
    required this.name,
  });

  final String id;
  final String slug;
  final String name;

  factory MemberRoleDto.fromJson(Map<String, dynamic> json) {
    return MemberRoleDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
    );
  }

  MemberRole toEntity() {
    return MemberRole(id: id, slug: slug, name: name);
  }
}

class MembersPageDto {
  const MembersPageDto({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<MembershipDto> results;

  factory MembersPageDto.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return MembersPageDto(
      count: json['count'] as int? ?? results.length,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results
          .map((e) => MembershipDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
