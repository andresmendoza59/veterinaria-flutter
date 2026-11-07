import 'package:flutter_app/shared/models/activity_status.dart';

enum SyncState { synced, queued, rejected }

class ItineraryActivity {
  final String id;
  final String ownerUid;
  final String catalogId;
  final String title;
  final String category;
  final String location;
  final DateTime startAt;
  final DateTime endAt;
  final int estimatedCost;
  final ActivityStatus status;
  final String slotId;
  final int reservedCost;
  final int realCost;
  final String reason;
  final bool returnRequested;
  final DateTime updatedAt;
  final bool pendingSync;
  final String syncError;

  const ItineraryActivity({
    required this.id,
    required this.ownerUid,
    required this.catalogId,
    required this.title,
    required this.category,
    required this.location,
    required this.startAt,
    required this.endAt,
    required this.estimatedCost,
    required this.status,
    required this.slotId,
    required this.reservedCost,
    required this.realCost,
    required this.reason,
    required this.returnRequested,
    required this.updatedAt,
    required this.pendingSync,
    required this.syncError,
  });

  static String generateId(String ownerUid) {
    return '${ownerUid}_${DateTime.now().microsecondsSinceEpoch}';
  }

  SyncState get syncState {
    if (!pendingSync) return SyncState.synced;
    return syncError.isEmpty ? SyncState.queued : SyncState.rejected;
  }

  bool get hasSlot => slotId.isNotEmpty;

  ItineraryActivity copyWith({
    String? id,
    String? ownerUid,
    String? catalogId,
    String? title,
    String? category,
    String? location,
    DateTime? startAt,
    DateTime? endAt,
    int? estimatedCost,
    ActivityStatus? status,
    String? slotId,
    int? reservedCost,
    int? realCost,
    String? reason,
    bool? returnRequested,
    DateTime? updatedAt,
    bool? pendingSync,
    String? syncError,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      catalogId: catalogId ?? this.catalogId,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      slotId: slotId ?? this.slotId,
      reservedCost: reservedCost ?? this.reservedCost,
      realCost: realCost ?? this.realCost,
      reason: reason ?? this.reason,
      returnRequested: returnRequested ?? this.returnRequested,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      syncError: syncError ?? this.syncError,
    );
  }

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] as String,
      ownerUid: json['owner_uid'] as String,
      catalogId: json['catalog_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      estimatedCost: (json['estimated_cost'] as num).toInt(),
      status: ActivityStatus.fromValue(json['status'] as String),
      slotId: json['slot_id'] as String,
      reservedCost: (json['reserved_cost'] as num).toInt(),
      realCost: (json['real_cost'] as num).toInt(),
      reason: json['reason'] as String,
      returnRequested: json['return_requested'] as bool,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pendingSync: false,
      syncError: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_uid': ownerUid,
        'catalog_id': catalogId,
        'title': title,
        'category': category,
        'location': location,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'estimated_cost': estimatedCost,
        'status': status.value,
        'slot_id': slotId,
        'reserved_cost': reservedCost,
        'real_cost': realCost,
        'reason': reason,
        'return_requested': returnRequested,
        'updated_at': updatedAt.toIso8601String(),
      };
}
