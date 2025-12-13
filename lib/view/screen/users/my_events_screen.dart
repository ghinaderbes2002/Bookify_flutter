import 'package:bookify/controller/users/events_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EventsControllerImp());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'فعالياتي',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: GetBuilder<EventsControllerImp>(
        builder: (controller) {
          if (controller.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2C3E50),
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
                      backgroundColor: const Color(0xFF2C3E50),
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

          if (controller.myEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لم تسجل في أي فعالية بعد',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/all-events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.explore),
                    label: const Text('استكشف الفعاليات'),
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
                  // Summary Card
                  _buildSummaryCard(controller),

                  // Ongoing Events
                  if (controller.myEvents.any((event) => event.isOngoing))
                    _buildEventsSection(
                      title: 'جارية الآن',
                      icon: Icons.event_available,
                      iconColor: const Color(0xFF4CAF50),
                      events: controller.myEvents
                          .where((event) => event.isOngoing)
                          .toList(),
                      controller: controller,
                    ),

                  // Upcoming Events
                  if (controller.myEvents
                      .any((event) => !event.isStarted && !event.isEnded))
                    _buildEventsSection(
                      title: 'قادمة',
                      icon: Icons.event,
                      iconColor: const Color(0xFF2196F3),
                      events: controller.myEvents
                          .where((event) => !event.isStarted && !event.isEnded)
                          .toList(),
                      controller: controller,
                    ),

                  // Past Events
                  if (controller.myEvents.any((event) => event.isEnded))
                    _buildEventsSection(
                      title: 'انتهت',
                      icon: Icons.event_busy,
                      iconColor: Colors.grey,
                      events: controller.myEvents
                          .where((event) => event.isEnded)
                          .toList(),
                      controller: controller,
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(EventsControllerImp controller) {
    final upcomingCount =
        controller.myEvents.where((event) => !event.isStarted).length;
    final ongoingCount =
        controller.myEvents.where((event) => event.isOngoing).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'ملخص فعالياتي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat(
                label: 'المجموع',
                value: '${controller.myEvents.length}',
                icon: Icons.event_note,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildSummaryStat(
                label: 'قادمة',
                value: '$upcomingCount',
                icon: Icons.event,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildSummaryStat(
                label: 'جارية',
                value: '$ongoingCount',
                icon: Icons.event_available,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
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

  Widget _buildEventsSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<EventModel> events,
    required EventsControllerImp controller,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${events.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _buildEventCard(events[index], controller);
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
          border: event.isOngoing
              ? Border.all(color: const Color(0xFF4CAF50), width: 2)
              : null,
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
              if (!event.isEnded) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showUnregisterDialog(controller, event),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 18),
                        label: const Text(
                          'إلغاء التسجيل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed('/event-details',
                              arguments: {'eventId': event.eventId});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    icon: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // كمان خلي النص أبيض إذا بدك
                          ),
                        ),

                      ),
                    ),
                  ],
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
