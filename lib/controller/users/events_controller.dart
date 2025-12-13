import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class EventsController extends GetxController {
  getUserEvents();
  getEventById(int eventId);
  registerEvent(int eventId);
  unregisterEvent(int eventId);
  filterByStatus(String? status);
}

class EventsControllerImp extends EventsController {
  Staterequest staterequest = Staterequest.none;
  Staterequest detailsStaterequest = Staterequest.none;
  List<EventModel> allEvents = [];
  List<EventModel> myEvents = [];
  List<EventModel> filteredEvents = [];
  EventModel? selectedEvent;
  String? selectedFilter; // null = all, 'upcoming', 'ongoing', 'ended'
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    getUserEvents();
  }

  @override
  getUserEvents() async {
    staterequest = Staterequest.loading;
    update();

    try {
      // جلب كل الفعاليات من /all
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/events/all',
      );

      print('Events Response: ${response.data}');
      print('Events Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        List data;

        // التحقق من نوع الـ response
        if (response.data is List) {
          // إذا كان الـ response مباشرة array
          data = response.data;
        } else if (response.data is Map && response.data['success'] == true) {
          // إذا كان الـ response object فيه success و data
          data = response.data['data'] ?? [];
        } else if (response.data is Map && response.data['data'] != null) {
          // إذا كان الـ response object فيه data بس
          data = response.data['data'];
        } else {
          data = [];
        }

        allEvents = data.map((item) => EventModel.fromJson(item)).toList();

        // ترتيب حسب تاريخ البداية (الأقرب أولاً)
        allEvents.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

        // فصل الفعاليات المسجل فيها المستخدم
        myEvents = allEvents.where((event) => event.isRegistered == true).toList();

        filteredEvents = List.from(allEvents);
        staterequest = Staterequest.success;
        print('Events loaded: ${allEvents.length} events');
        print('My Events: ${myEvents.length} events');
      } else {
        staterequest = Staterequest.failure;
        print('Events API failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Events Error: $e');
      print('Stack Trace: $stackTrace');
    }

    update();
  }

  @override
  getEventById(int eventId) async {
    detailsStaterequest = Staterequest.loading;
    update();

    try {
      // جلب تفاصيل الفعالية من /all/:id
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/events/all/$eventId',
      );

      print('Event Details Response: ${response.data}');

      if (response.statusCode == 200) {
        var data = response.data;

        // التحقق من نوع الـ response
        if (data is Map && data['success'] == true) {
          data = data['data'];
        }

        selectedEvent = EventModel.fromJson(data);
        detailsStaterequest = Staterequest.success;
        print('Event details loaded: ${selectedEvent?.title}');
      } else {
        detailsStaterequest = Staterequest.failure;
        print('Event Details API failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      detailsStaterequest = Staterequest.serverfailure;
      print('Event Details Error: $e');
      print('Stack Trace: $stackTrace');
    }

    update();
  }

  @override
  registerEvent(int eventId) async {
    try {
      final response = await api.postData(
        url: '${serverConfig.serverLink}/api/user/events/register',
        data: {'event_id': eventId},
      );

      print('Register Event Response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تم التسجيل في الفعالية بنجاح',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إعادة تحميل الفعاليات
        await getUserEvents();

        // تحديث تفاصيل الفعالية إذا كانت مفتوحة
        if (selectedEvent?.eventId == eventId) {
          await getEventById(eventId);
        }

        return true;
      } else if (response.statusCode == 400) {
        // المستخدم مسجل مسبقاً أو الفعالية ممتلئة
        final message = response.data['message'] ?? 'لا يمكن التسجيل في الفعالية';
        String arabicMessage = message;

        if (message == 'User already registered for this event') {
          arabicMessage = 'أنت مسجل في هذه الفعالية مسبقاً';
        } else if (message == 'Event is full') {
          arabicMessage = 'الفعالية ممتلئة';
        }

        Get.snackbar(
          'تنبيه',
          arabicMessage,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return false;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'خطأ',
          'الفعالية غير موجودة',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشل التسجيل في الفعالية',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Register Event Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التسجيل',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
  }

  @override
  unregisterEvent(int eventId) async {
    try {
      final response = await api.postData(
        url: '${serverConfig.serverLink}/api/user/events/unregister',
        data: {'event_id': eventId},
      );

      print('Unregister Event Response: ${response.data}');
      print('Unregister Event Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تم إلغاء التسجيل من الفعالية',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إعادة تحميل الفعاليات
        await getUserEvents();

        // تحديث تفاصيل الفعالية إذا كانت مفتوحة
        if (selectedEvent?.eventId == eventId) {
          await getEventById(eventId);
        }

        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'تنبيه',
          'أنت غير مسجل في هذه الفعالية',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشل إلغاء التسجيل من الفعالية',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Unregister Event Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إلغاء التسجيل',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
  }

  @override
  filterByStatus(String? status) {
    selectedFilter = status;

    if (status == null) {
      filteredEvents = List.from(allEvents);
    } else {
      filteredEvents = allEvents.where((event) {
        switch (status.toLowerCase()) {
          case 'upcoming':
          case 'قادمة':
            return !event.isStarted;
          case 'ongoing':
          case 'جارية':
            return event.isOngoing;
          case 'ended':
          case 'انتهت':
            return event.isEnded;
          default:
            return true;
        }
      }).toList();
    }

    update();
  }

  // Helper method للحصول على الفعاليات القادمة
  List<EventModel> getUpcomingEvents({int limit = 5}) {
    return allEvents.where((event) => !event.isStarted).take(limit).toList();
  }

  // Helper method للحصول على الفعاليات الجارية
  List<EventModel> getOngoingEvents() {
    return allEvents.where((event) => event.isOngoing).toList();
  }
}
