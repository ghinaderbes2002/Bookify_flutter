class EventModel {
  final int eventId;
  final String title;
  final String? description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final int? createdBy;
  final int? maxParticipants;
  final DateTime createdAt;

  // معلومات إضافية قد ترجع من الـ API
  final int? currentParticipants;
  final bool? isRegistered;

  EventModel({
    required this.eventId,
    required this.title,
    this.description,
    required this.startDatetime,
    required this.endDatetime,
    this.createdBy,
    this.maxParticipants,
    required this.createdAt,
    this.currentParticipants,
    this.isRegistered,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: int.parse(json['event_id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      startDatetime: DateTime.parse(json['start_datetime']),
      endDatetime: DateTime.parse(json['end_datetime']),
      createdBy: json['created_by'] != null
          ? int.parse(json['created_by'].toString())
          : null,
      maxParticipants: json['max_participants'] != null
          ? int.parse(json['max_participants'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
      currentParticipants: json['current_participants'] != null
          ? int.parse(json['current_participants'].toString())
          : null,
      isRegistered: json['is_registered'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'title': title,
      'description': description,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'created_by': createdBy,
      'max_participants': maxParticipants,
      'created_at': createdAt.toIso8601String(),
      'current_participants': currentParticipants,
      'is_registered': isRegistered,
    };
  }

  // Helper: هل الفعالية ممتلئة؟
  bool get isFull {
    if (maxParticipants == null || currentParticipants == null) return false;
    return currentParticipants! >= maxParticipants!;
  }

  // Helper: هل الفعالية انتهت؟
  bool get isEnded {
    return DateTime.now().isAfter(endDatetime);
  }

  // Helper: هل الفعالية بدأت؟
  bool get isStarted {
    return DateTime.now().isAfter(startDatetime);
  }

  // Helper: هل الفعالية قيد التنفيذ الآن؟
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDatetime) && now.isBefore(endDatetime);
  }

  // Helper: حالة الفعالية
  String getEventStatus() {
    if (isEnded) return 'انتهت';
    if (isOngoing) return 'جارية الآن';
    if (isStarted) return 'بدأت';
    return 'قادمة';
  }

  // Helper: مدة الفعالية
  Duration get duration {
    return endDatetime.difference(startDatetime);
  }

  // Helper: عدد المقاعد المتبقية
  int? get availableSeats {
    if (maxParticipants == null || currentParticipants == null) return null;
    return maxParticipants! - currentParticipants!;
  }
}
