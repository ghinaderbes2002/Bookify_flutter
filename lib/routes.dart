import 'package:bookify/core/Binding/auth_binding.dart';
import 'package:bookify/core/constant/App_routes.dart';
import 'package:bookify/view/screen/auth/Signup.dart';
import 'package:bookify/view/screen/auth/login.dart';
import 'package:bookify/view/screen/speech_to_text_page.dart';
import 'package:bookify/view/screen/users/mainScreen.dart';
import 'package:bookify/view/screen/users/all_events_screen.dart';
import 'package:bookify/view/screen/users/event_details_screen.dart';
import 'package:bookify/view/screen/users/my_events_screen.dart';
import 'package:bookify/view/screen/users/profile_screen.dart';
import 'package:bookify/view/screen/users/my_wishlist_screen.dart';
import 'package:bookify/view/screen/users/my_reviews_screen.dart';
import 'package:bookify/view/screen/users/uploads_screen.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? routes = [

  GetPage(name: AppRoute.login, page: () => const Login() , binding: AuthBinding(),
),
  GetPage(name: AppRoute.signup, page: () => const Signup()),
  GetPage(name: AppRoute.mainScreen, page: () => const MainScreen()),

  // Events Routes
  GetPage(name: AppRoute.allEvents, page: () => const AllEventsScreen()),
  GetPage(name: AppRoute.eventDetails, page: () => const EventDetailsScreen()),
  GetPage(name: AppRoute.myEvents, page: () => const MyEventsScreen()),

  // Profile Routes
  GetPage(name: AppRoute.profileScreen, page: () => const ProfileScreen()),
  GetPage(name: AppRoute.myWishlist, page: () => const MyWishlistScreen()),
  GetPage(name: AppRoute.myReviews, page: () => const MyReviewsScreen()),
  GetPage(name: AppRoute.myUploads, page: () => const UploadsScreen()),


  GetPage(name: AppRoute.speech, page: () =>  SpeechToTextPage()),

];
