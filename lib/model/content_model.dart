class ContentModel {
  final int contentId;
  final String title;
  final String? description;
  final String contentType;
  final String? author;
  final String? publisher;
  final int? pagesCount;
  final String? language;
  final DateTime? releaseDate;
  final String? issueNumber;
  final int? episodeNumber;
  final int? durationSeconds;
  final String? audioUrl;
  final String? coverUrl;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentModel({
    required this.contentId,
    required this.title,
    this.description,
    required this.contentType,
    this.author,
    this.publisher,
    this.pagesCount,
    this.language,
    this.releaseDate,
    this.issueNumber,
    this.episodeNumber,
    this.durationSeconds,
    this.audioUrl,
    this.coverUrl,
    this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      contentId: json['content_id'],
      title: json['title'],
      description: json['description'],
      contentType: json['content_type'],
      author: json['author'],
      publisher: json['publisher'],
      pagesCount: json['pages_count'],
      language: json['language'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      issueNumber: json['issue_number'],
      episodeNumber: json['episode_number'],
      durationSeconds: json['duration_seconds'],
      audioUrl: json['audio_url'],
      coverUrl: json['cover_url'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content_id': contentId,
      'title': title,
      'description': description,
      'content_type': contentType,
      'author': author,
      'publisher': publisher,
      'pages_count': pagesCount,
      'language': language,
      'release_date': releaseDate?.toIso8601String(),
      'issue_number': issueNumber,
      'episode_number': episodeNumber,
      'duration_seconds': durationSeconds,
      'audio_url': audioUrl,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getContentTypeIcon() {
    final type = contentType.toLowerCase();
    switch (type) {
      case 'book':
      case 'كتاب':
        return '📚';
      case 'article':
      case 'مقالة':
        return '📰';
      case 'audio':
      case 'صوتي':
      case 'audiobook':
      case 'كتاب صوتي':
        return '🎵';
      case 'video':
      case 'فيديو':
        return '🎥';
      case 'magazine':
      case 'مجلة':
        return '📖';
      case 'podcast':
      case 'بودكاست':
        return '🎙️';
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
      case 'article':
      case 'مقالة':
        return 'مقالة';
      case 'audio':
      case 'صوتي':
        return 'صوتي';
      case 'audiobook':
      case 'كتاب صوتي':
        return 'كتاب صوتي';
      case 'video':
      case 'فيديو':
        return 'فيديو';
      case 'magazine':
      case 'مجلة':
        return 'مجلة';
      case 'podcast':
      case 'بودكاست':
        return 'بودكاست';
      default:
        return contentType; // إرجاع النص الأصلي إذا لم يطابق أي حالة
    }
  }
}
