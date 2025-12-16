import 'package:bookify/controller/users/content_controller.dart';
import 'package:bookify/controller/users/library_controller.dart';
import 'package:bookify/controller/users/reviews_controller.dart';
import 'package:bookify/controller/users/wishlist_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:bookify/model/review_model.dart';
import 'package:bookify/view/screen/users/audio_player_screen.dart';
import 'package:bookify/view/screen/users/pdf_viewer_screen.dart';
import 'package:bookify/view/screen/users/video_player_screen.dart';
import 'package:bookify/view/widget/speech_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContentDetailsScreen extends StatefulWidget {
  final int contentId;

  const ContentDetailsScreen({super.key, required this.contentId});

  @override
  State<ContentDetailsScreen> createState() => _ContentDetailsScreenState();
}

class _ContentDetailsScreenState extends State<ContentDetailsScreen> {
  late ContentControllerImp controller;
  final myServices = Get.find<MyServices>();
  int _reviewsRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ContentControllerImp());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getContentById(widget.contentId);
    });
  }

  // Helper method to get current user ID
  int _getCurrentUserId() {
    return myServices.sharedPref.getInt('userId') ?? 0;
  }

  // Helper method to refresh reviews section
  void _refreshReviews() {
    setState(() {
      _reviewsRefreshKey++;
    });
  }

  void _openPdfViewer(String? url, String title) {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرابط غير متوفر',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.to(() => PdfViewerScreen(pdfUrl: url, title: title));
  }

  // Helper method to check if file is video
  bool _isVideoFile(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.webm');
  }

  void _openMediaPlayer(String? url, String title, String? coverUrl) {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الرابط غير متوفر',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Check if it's a video file
    if (_isVideoFile(url)) {
      Get.to(
        () => VideoPlayerScreen(
          videoUrl: url,
          title: title,
          coverUrl: coverUrl,
        ),
      );
    } else {
      // Audio file
      Get.to(
        () => AudioPlayerScreen(
          audioUrl: url,
          title: title,
          coverUrl: coverUrl,
        ),
      );
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ContentControllerImp>(
        builder: (controller) {
          if (controller.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (controller.staterequest == Staterequest.failure ||
              controller.selectedContent == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'فشل تحميل التفاصيل',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        controller.getContentById(widget.contentId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            );
          }

          final content = controller.selectedContent!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.teal,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (content.coverUrl != null)
                        Image.network(
                          content.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.teal.shade700,
                              child: Center(
                                child: Text(
                                  content.getContentTypeIcon(),
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.teal.shade700,
                          child: Center(
                            child: Text(
                              content.getContentTypeIcon(),
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          content.getContentTypeLabel(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (content.author != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'المؤلف: ${content.author}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (content.publisher != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الناشر: ${content.publisher}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (content.pagesCount != null)
                            _buildInfoChip(
                              Icons.book_outlined,
                              '${content.pagesCount} صفحة',
                            ),
                          if (content.language != null)
                            _buildInfoChip(Icons.language, content.language!),
                          if (content.durationSeconds != null)
                            _buildInfoChip(
                              Icons.timer_outlined,
                              _formatDuration(content.durationSeconds),
                            ),
                          if (content.releaseDate != null)
                            _buildInfoChip(
                              Icons.calendar_today_outlined,
                              '${content.releaseDate!.year}/${content.releaseDate!.month}/${content.releaseDate!.day}',
                            ),
                          if (content.issueNumber != null)
                            _buildInfoChip(
                              Icons.numbers,
                              'العدد: ${content.issueNumber}',
                            ),
                          if (content.episodeNumber != null)
                            _buildInfoChip(
                              Icons.video_library_outlined,
                              'الحلقة: ${content.episodeNumber}',
                            ),
                        ],
                      ),
                      if (content.description != null &&
                          content.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'الوصف',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.description!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (content.fileUrl != null ||
                          content.audioUrl != null) ...[
                        const Text(
                          'الملفات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (content.fileUrl != null) ...[
                        _buildActionButton(
                          icon: Icons.picture_as_pdf,
                          label: 'فتح الملف',
                          color: Colors.teal,
                          onTap: () =>
                              _openPdfViewer(content.fileUrl, content.title),
                        ),
                      ],
                      if (content.audioUrl != null) ...[
                        _buildActionButton(
                          icon: _isVideoFile(content.audioUrl)
                              ? Icons.play_circle_filled
                              : Icons.headphones,
                          label: _isVideoFile(content.audioUrl)
                              ? 'تشغيل الفيديو'
                              : 'تشغيل الصوت',
                          color: Colors.orange,
                          onTap: () => _openMediaPlayer(
                            content.audioUrl,
                            content.title,
                            content.coverUrl,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.bookmark_add_outlined,
                        label: 'إضافة إلى مكتبتي',
                        color: Colors.teal,
                        onTap: () {
                          final libraryController = Get.put(
                            LibraryControllerImp(),
                          );
                          libraryController.addToLibrary(content.contentId);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.favorite_border,
                        label: 'إضافة لقائمة الأمنيات',
                        color: Colors.pink,
                        onTap: () {
                          final wishlistController = Get.put(
                            WishlistControllerImp(),
                          );
                          wishlistController.addToWishlist(content.contentId);
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildReviewsSection(content.contentId),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewsSection(int contentId) {
    final reviewsController = Get.put(ReviewsControllerImp());

    return FutureBuilder<List<ReviewModel>>(
      key: ValueKey(_reviewsRefreshKey),
      future: reviewsController.getAllReviews(contentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        final reviews = snapshot.data ?? [];

        // البحث عن تقييم المستخدم الحالي
        final currentUserId = _getCurrentUserId();
        final userReview = reviews.firstWhere(
          (review) => review.userId == currentUserId,
          orElse: () => ReviewModel(
            reviewId: 0,
            userId: 0,
            contentId: 0,
            rating: 0,
            createdAt: DateTime.now(),
          ),
        );

        final hasUserReview = userReview.reviewId != 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'التقييمات والمراجعات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (reviews.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          _calculateAverageRating(reviews).toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          ' (${reviews.length})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // زر إضافة تقييم إذا لم يكن المستخدم قد قيّم مسبقاً
            if (!hasUserReview) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showReviewDialog(contentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.rate_review, size: 20),
                  label: const Text(
                    'إضافة تقييم ومراجعة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // زر تعديل التقييم إذا كان المستخدم قد قيّم مسبقاً
            if (hasUserReview) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: Colors.amber.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userReview.rating > 0
                                ? 'تقييمك: ${userReview.getRatingStars()}'
                                : 'مراجعتك',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'اضغط لتعديل أو حذف تقييمك',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showReviewDialog(
                        contentId,
                        existingReview: userReview,
                      ),
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد تقييمات بعد',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'كن أول من يضيف تقييم لهذا المحتوى',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length > 3 ? 3 : reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildReviewCard(review, contentId);
                },
              ),
            if (reviews.length > 3) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showAllReviews(reviews, contentId);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'عرض جميع التقييمات',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review, int contentId) {
    // Check if this review belongs to current user
    final isUserReview = review.userId == _getCurrentUserId();

    return InkWell(
      onTap: isUserReview
          ? () => _showReviewDialog(contentId, existingReview: review)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUserReview ? Colors.amber.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUserReview ? Colors.amber.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isUserReview
                            ? Colors.amber.shade100
                            : Colors.teal.withValues(alpha: 0.1),
                        child: Text(
                          review.userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: isUserReview
                                ? Colors.amber.shade700
                                : Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    review.userName ?? 'مستخدم',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isUserReview) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'أنت',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              review.getTimeSinceReview(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (review.rating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        review.getRatingColor(),
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Color(review.getRatingColor()),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${review.rating}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(review.getRatingColor()),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.reviewText!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
            if (isUserReview) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'اضغط للتعديل أو الحذف',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllReviews(List<ReviewModel> reviews, int contentId) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جميع التقييمات (${reviews.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(reviews[index], contentId);
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  double _calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    // Count only reviews with rating > 0 for average
    final validReviews = reviews.where((review) => review.rating > 0).toList();
    if (validReviews.isEmpty) return 0.0;
    final sum = validReviews.fold<int>(
      0,
      (prev, review) => prev + review.rating,
    );
    return sum / validReviews.length;
  }

  void _showReviewDialog(int contentId, {ReviewModel? existingReview}) {
    final reviewsController = Get.put(ReviewsControllerImp());
    int selectedRating = existingReview?.rating ?? 0;
    final reviewTextController = TextEditingController(
      text: existingReview?.reviewText ?? '',
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingReview == null
                              ? 'إضافة تقييم'
                              : 'تعديل التقييم',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'التقييم (اختياري)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                selectedRating = rating;
                              });
                            },
                            icon: Icon(
                              selectedRating >= rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: selectedRating >= rating
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ),
                    if (selectedRating > 0) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _getRatingLabel(selectedRating),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(_getRatingColor(selectedRating)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // const Text(
                    //   'المراجعة (اختياري)',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),

                    // TextField(
                    //   controller: reviewTextController,
                    //   maxLines: 4,
                    //   decoration: InputDecoration(
                    //     hintText: 'شارك رأيك حول هذا المحتوى...',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //       borderSide: const BorderSide(
                    //         color: Colors.teal,
                    //         width: 2,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SpeechTextField(
                      controller: reviewTextController,
                      label: 'المراجعة (اختياري)',

                      hint: 'شارك رأيك حول هذا المحتوى... ',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        if (existingReview != null) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                final success = await reviewsController
                                    .deleteReview(existingReview.reviewId);
                                if (success) {
                                  _refreshReviews();
                                  controller.getContentById(contentId);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'حذف',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              bool success;
                              if (existingReview == null) {
                                success = await reviewsController.createReview(
                                  contentId,
                                  selectedRating > 0 ? selectedRating : null,
                                  reviewTextController.text.isEmpty
                                      ? null
                                      : reviewTextController.text,
                                );
                              } else {
                                success = await reviewsController.updateReview(
                                  existingReview.reviewId,
                                  selectedRating > 0 ? selectedRating : null,
                                  reviewTextController.text.isEmpty
                                      ? null
                                      : reviewTextController.text,
                                );
                              }
                              if (success) {
                                _refreshReviews();
                                controller.getContentById(contentId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              existingReview == null
                                  ? 'إضافة التقييم'
                                  : 'تحديث التقييم',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
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
        return '';
    }
  }

  int _getRatingColor(int rating) {
    if (rating >= 4) return 0xFF4CAF50; // Green
    if (rating >= 3) return 0xFFFFC107; // Yellow
    if (rating >= 2) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
