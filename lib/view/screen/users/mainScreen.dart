import 'package:bookify/controller/users/main_controller.dart';
import 'package:bookify/view/screen/users/all_events_screen.dart';
import 'package:bookify/view/screen/users/categories_screen.dart';
import 'package:bookify/view/screen/users/my_library_screen.dart';
import 'package:bookify/view/screen/users/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    final List<Widget> screens = [
      // const HomeScreen(),
      const CategoriesScreen(),
      const CategoriesScreen(),
      const MyLibraryScreen(),
      const AllEventsScreen(),
      const ProfileScreen(),
      // const ProfileScreen(),
    ];

    return GetBuilder<MainController>(
      builder: (_) {
        return Scaffold(
          body: screens[controller.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category),
                label: 'التصنيفات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                activeIcon: Icon(Icons.library_books),
                label: 'مكتبتي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),
                activeIcon: Icon(Icons.event),
                label: 'الفعاليات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'حسابي',
              ),
            ],
          ),
        );
      },
    );
  }
}
