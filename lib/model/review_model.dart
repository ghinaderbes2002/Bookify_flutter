class ReviewModel {
  final int reviewId;
  final int userId;
  final int contentId;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;

  // Content details (nested from backend)
  final String? contentTitle;
  final String? contentType;
  final String? contentAuthor;
  final String? contentCoverUrl;

  // User details (nested from backend)
  final String? userName;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.contentId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    this.contentTitle,
    this.contentType,
    this.contentAuthor,
    this.contentCoverUrl,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int safeParseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      try {
        return int.parse(value.toString());
      } catch (e) {
        return defaultValue;
      }
    }

    // Content و User قد تكون nested objects
    final content = json['content'];
    final user = json['user'];

    return ReviewModel(
      reviewId: safeParseInt(json['review_id']),
      userId: safeParseInt(json['user_id']),
      contentId: safeParseInt(json['content_id']),
      rating: safeParseInt(json['rating'], defaultValue: 0),
      reviewText: json['review_text']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      contentTitle: content?['title']?.toString(),
      contentType: content?['content_type']?.toString(),
      contentAuthor: content?['author']?.toString(),
      contentCoverUrl: content?['cover_url']?.toString() ?? content?['cover_image_url']?.toString(),
      userName: user?['full_name']?.toString() ??
                user?['name']?.toString() ??
                user?['username']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_id': userId,
      'content_id': contentId,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method للتقييم النجمي
  String getRatingStars() {
    return '⭐' * rating.clamp(0, 5);
  }

  // Helper method للوقت منذ المراجعة
  String getTimeSinceReview() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  // Helper method لنص التقييم
  String getRatingLabel() {
    switch (rating) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد جداً';
      case 3:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 1:
        return 'ضعيف';
      default:
        return 'لا يوجد تقييم';
    }
  }

  // Helper method للون التقييم
  int getRatingColor() {
    if (rating >= 4) return 0xFF4CAF50; // أخضر
    if (rating >= 3) return 0xFFFFC107; // أصفر
    if (rating >= 2) return 0xFFFF9800; // برتقالي
    return 0xFFF44336; // أحمر
  }
}
