class WishlistItemModel {
  final int wishlistItemId;
  final int wishlistId;
  final int contentId;
  final DateTime addedAt;

  // Content details (nested from backend)
  final String title;
  final String? description;
  final String contentType;
  final String? author;
  final String? coverImageUrl;
  final String? fileUrl;

  WishlistItemModel({
    required this.wishlistItemId,
    required this.wishlistId,
    required this.contentId,
    required this.addedAt,
    required this.title,
    this.description,
    required this.contentType,
    this.author,
    this.coverImageUrl,
    this.fileUrl,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    // البيانات قد تأتي مع content object متداخل
    final content = json['content'] ?? json;

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

    return WishlistItemModel(
      wishlistItemId: safeParseInt(json['wishlist_item_id']),
      wishlistId: safeParseInt(json['wishlist_id']),
      contentId: safeParseInt(content['content_id'] ?? json['content_id']),
      addedAt: DateTime.parse(json['added_at'].toString()),
      title: content['title']?.toString() ?? '',
      description: content['description']?.toString(),
      contentType: content['content_type']?.toString() ?? 'محتوى',
      author: content['author']?.toString(),
      coverImageUrl: content['cover_image_url']?.toString() ?? content['cover_url']?.toString(),
      fileUrl: content['file_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlist_item_id': wishlistItemId,
      'wishlist_id': wishlistId,
      'content_id': contentId,
      'added_at': addedAt.toIso8601String(),
      'title': title,
      'description': description,
      'content_type': contentType,
      'author': author,
      'cover_image_url': coverImageUrl,
      'file_url': fileUrl,
    };
  }

  // Helper methods مثل المكتبة
  String getContentTypeIcon() {
    final type = contentType.toLowerCase();
    switch (type) {
      case 'book':
      case 'كتاب':
        return '📚';
      case 'magazine':
      case 'مجلة':
        return '📰';
      case 'podcast':
      case 'بودكاست':
        return '🎙️';
      case 'audiobook':
      case 'كتاب صوتي':
        return '🎧';
      case 'video':
      case 'فيديو':
        return '🎬';
      default:
        return '📄';
    }
  }

  String getContentTypeLabel() {
    final type = contentType.toLowerCase();
    switch (type) {
      case 'book':
      case 'كتاب':
        return 'كتاب';
      case 'magazine':
      case 'مجلة':
        return 'مجلة';
      case 'podcast':
      case 'بودكاست':
        return 'بودكاست';
      case 'audiobook':
      case 'كتاب صوتي':
        return 'كتاب صوتي';
      case 'video':
      case 'فيديو':
        return 'فيديو';
      default:
        return contentType;
    }
  }

  String getTimeSinceAdded() {
    final now = DateTime.now();
    final difference = now.difference(addedAt);

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
}
