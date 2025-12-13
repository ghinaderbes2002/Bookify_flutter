import 'package:bookify/controller/users/reviews_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReviewsControllerImp());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تقييماتي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<ReviewsControllerImp>(
        builder: (controller) {
          return Column(
            children: [
              // Statistics Section
              if (controller.allReviews.isNotEmpty)
                _buildStatisticsSection(controller),

              // Filter Section
              _buildFilterSection(controller),

              // Reviews List
              Expanded(
                child: _buildReviewsList(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(ReviewsControllerImp controller) {
    final avgRating = controller.getAverageRating();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'إحصائيات تقييماتي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'المجموع',
                value: '${controller.allReviews.length}',
                icon: Icons.reviews,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                label: 'المتوسط',
                value: avgRating.toStringAsFixed(1),
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(ReviewsControllerImp controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildRatingChip(
              label: 'الكل',
              rating: null,
              isSelected: controller.selectedRating == null,
              onTap: () => controller.filterByRating(null),
            ),
            const SizedBox(width: 8),
            _buildRatingChip(
              label: '⭐⭐⭐⭐⭐',
              rating: 5,
              isSelected: controller.selectedRating == 5,
              onTap: () => controller.filterByRating(5),
            ),
            const SizedBox(width: 8),
            _buildRatingChip(
              label: '⭐⭐⭐⭐',
              rating: 4,
              isSelected: controller.selectedRating == 4,
              onTap: () => controller.filterByRating(4),
            ),
            const SizedBox(width: 8),
            _buildRatingChip(
              label: '⭐⭐⭐',
              rating: 3,
              isSelected: controller.selectedRating == 3,
              onTap: () => controller.filterByRating(3),
            ),
            const SizedBox(width: 8),
            _buildRatingChip(
              label: '⭐⭐',
              rating: 2,
              isSelected: controller.selectedRating == 2,
              onTap: () => controller.filterByRating(2),
            ),
            const SizedBox(width: 8),
            _buildRatingChip(
              label: '⭐',
              rating: 1,
              isSelected: controller.selectedRating == 1,
              onTap: () => controller.filterByRating(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip({
    required String label,
    required int? rating,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.teal,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(ReviewsControllerImp controller) {
    if (controller.staterequest == Staterequest.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (controller.staterequest == Staterequest.failure ||
        controller.staterequest == Staterequest.serverfailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل التقييمات',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.getUserReviews(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (controller.filteredReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              controller.selectedRating == null
                  ? 'لم تقم بأي تقييمات بعد'
                  : 'لا يوجد تقييمات بهذا التصنيف',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.getUserReviews();
      },
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredReviews.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(controller.filteredReviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final serverConfig = ServerConfig();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating & Date Row
            Row(
              children: [
                // Rating Stars
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(review.getRatingColor())
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        review.getRatingStars(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.getRatingLabel(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(review.getRatingColor()),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Time
                Text(
                  review.getTimeSinceReview(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content Info
            if (review.contentTitle != null) ...[
              Row(
                children: [
                  // Cover Image
                  if (review.contentCoverUrl != null &&
                      review.contentCoverUrl!.isNotEmpty)
                    Container(
                      width: 50,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          '${serverConfig.serverLink}${review.contentCoverUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.book,
                                color: Colors.grey.shade400);
                          },
                        ),
                      ),
                    ),
                  if (review.contentCoverUrl != null &&
                      review.contentCoverUrl!.isNotEmpty)
                    const SizedBox(width: 12),

                  // Content Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.contentTitle!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (review.contentAuthor != null &&
                            review.contentAuthor!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            review.contentAuthor!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (review.contentType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            review.contentType!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Review Text
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  review.reviewText!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
