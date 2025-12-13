import 'package:bookify/controller/users/events_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final EventsControllerImp controller;
  late final int eventId;

  @override
  void initState() {
    super.initState();
    eventId = Get.arguments['eventId'] as int;
    controller = Get.put(EventsControllerImp());

    // تحميل تفاصيل الفعالية بعد بناء الـ Widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getEventById(eventId);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'تفاصيل الفعالية',
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
          if (controller.detailsStaterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2C3E50),
              ),
            );
          }

          if (controller.detailsStaterequest == Staterequest.failure ||
              controller.detailsStaterequest == Staterequest.serverfailure ||
              controller.selectedEvent == null) {
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
                    'حدث خطأ في تحميل تفاصيل الفعالية',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getEventById(eventId),
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

          final event = controller.selectedEvent!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status
                _buildHeader(event),

                // Event Info Card
                _buildInfoCard(event),

                // Date & Time Card
                _buildDateTimeCard(event),

                // Participants Card
                _buildParticipantsCard(event),

                // Description Card
                if (event.description != null && event.description!.isNotEmpty)
                  _buildDescriptionCard(event),

                // Action Buttons
                _buildActionButtons(controller, event),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(EventModel event) {
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
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (event.isRegistered == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'أنت مسجل',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF2C3E50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'معلومات الفعالية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.event,
            label: 'رقم الفعالية',
            value: '#${event.eventId}',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'مدة الفعالية',
            value: _formatDuration(event.duration),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(EventModel event) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Color(0xFF2C3E50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'التاريخ والوقت',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.event_available,
            label: 'تاريخ البداية',
            value: dateFormat.format(event.startDatetime),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              'الوقت: ${timeFormat.format(event.startDatetime)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.event_busy,
            label: 'تاريخ الانتهاء',
            value: dateFormat.format(event.endDatetime),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              'الوقت: ${timeFormat.format(event.endDatetime)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.people,
                color: Color(0xFF2C3E50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'المشاركون',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildParticipantsStat(
                  label: 'المشاركون الحاليون',
                  value: '${event.currentParticipants ?? 0}',
                  icon: Icons.people_outline,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildParticipantsStat(
                  label: 'الحد الأقصى',
                  value: '${event.maxParticipants ?? 0}',
                  icon: Icons.group,
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          if (event.availableSeats != null) ...[
            const SizedBox(height: 12),
            _buildParticipantsStat(
              label: 'المقاعد المتبقية',
              value: '${event.availableSeats}',
              icon: Icons.event_seat,
              color: event.availableSeats! > 0
                  ? const Color(0xFF4CAF50)
                  : Colors.red,
            ),
          ],
          if (event.isFull) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'الفعالية ممتلئة',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantsStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description,
                color: Color(0xFF2C3E50),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'الوصف',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.description!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EventsControllerImp controller, EventModel event) {
    if (event.isEnded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'هذه الفعالية انتهت',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (event.isRegistered != true) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: event.isFull
                    ? null
                    : () => controller.registerEvent(event.eventId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      event.isFull ? Icons.block : Icons.check_circle_outline,
                      color: event.isFull ? Colors.grey[600] : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.isFull ? 'الفعالية ممتلئة' : 'سجل في الفعالية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: event.isFull ? Colors.grey[600] : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showUnregisterDialog(controller, event),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'إلغاء التسجيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else {
      return '${duration.inMinutes} دقيقة';
    }
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
