import 'package:bookify/controller/users/events_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EventsControllerImp());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          'الفعاليات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'فعالياتي',
            onPressed: () => Get.toNamed('/my-events'),
          ),
        ],
      ),
      body: GetBuilder<EventsControllerImp>(
        builder: (controller) {
          if (controller.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }

          if (controller.staterequest == Staterequest.failure ||
              controller.staterequest == Staterequest.serverfailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'حدث خطأ في تحميل الفعاليات',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getUserEvents(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.getUserEvents();
            },
            color: const Color(0xFF2C3E50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  _buildFilterSection(controller),

                  // Ongoing Events Section
                  if (controller.getOngoingEvents().isNotEmpty)
                    _buildOngoingEventsSection(controller),

                  // All Events List
                  _buildEventsListSection(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(EventsControllerImp controller) {
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
            _buildFilterChip(
              label: 'الكل',
              icon: Icons.list,
              isSelected: controller.selectedFilter == null,
              onTap: () => controller.filterByStatus(null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'قادمة',
              icon: Icons.event,
              isSelected: controller.selectedFilter == 'upcoming' ||
                  controller.selectedFilter == 'قادمة',
              onTap: () => controller.filterByStatus('upcoming'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'جارية الآن',
              icon: Icons.event_available,
              isSelected: controller.selectedFilter == 'ongoing' ||
                  controller.selectedFilter == 'جارية',
              onTap: () => controller.filterByStatus('ongoing'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'انتهت',
              icon: Icons.event_busy,
              isSelected: controller.selectedFilter == 'ended' ||
                  controller.selectedFilter == 'انتهت',
              onTap: () => controller.filterByStatus('ended'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.teal,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingEventsSection(EventsControllerImp controller) {
    final ongoingEvents = controller.getOngoingEvents();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(
                Icons.event_available,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'الفعاليات الجارية الآن',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ongoingEvents.length,
            itemBuilder: (context, index) {
              return _buildOngoingEventCard(ongoingEvents[index], controller);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOngoingEventCard(
      EventModel event, EventsControllerImp controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/event-details', arguments: {'eventId': event.eventId});
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'جارية الآن',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (event.isRegistered == true)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (event.description != null)
                Text(
                  event.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${event.currentParticipants ?? 0}/${event.maxParticipants ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (event.availableSeats != null && event.availableSeats! > 0)
                    Text(
                      'متبقي ${event.availableSeats}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsListSection(EventsControllerImp controller) {
    if (controller.filteredEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'لا يوجد فعاليات',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'جميع الفعاليات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredEvents.length,
            itemBuilder: (context, index) {
              return _buildEventCard(
                  controller.filteredEvents[index], controller);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event, EventsControllerImp controller) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: () {
        Get.toNamed('/event-details', arguments: {'eventId': event.eventId});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(event),
                ],
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(event.startDatetime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(event.startDatetime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${event.currentParticipants ?? 0}/${event.maxParticipants ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (event.availableSeats != null && event.availableSeats! > 0)
                    Text(
                      '(متبقي ${event.availableSeats})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (event.isFull)
                    const Text(
                      '(ممتلئة)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const Spacer(),
                  if (event.isRegistered == true)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مسجل',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (!event.isEnded && event.isRegistered != true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: event.isFull
                        ? null
                        : () => controller.registerEvent(event.eventId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      event.isFull ? 'الفعالية ممتلئة' : 'سجل الآن',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: event.isFull ? Colors.grey[600] : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              if (event.isRegistered == true && !event.isEnded) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showUnregisterDialog(controller, event),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'إلغاء التسجيل',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(EventModel event) {
    String status = event.getEventStatus();
    Color color;

    if (event.isEnded) {
      color = Colors.grey;
    } else if (event.isOngoing) {
      color = const Color(0xFF4CAF50);
    } else {
      color = const Color(0xFF2196F3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUnregisterDialog(
      EventsControllerImp controller, EventModel event) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'إلغاء التسجيل',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('هل أنت متأكد من إلغاء التسجيل في فعالية "${event.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.unregisterEvent(event.eventId);
            },
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
