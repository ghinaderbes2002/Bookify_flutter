import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:get/get.dart';

class ServerConfig {
  static final ServerConfig _instance = ServerConfig._internal();
  factory ServerConfig() => _instance;
  ServerConfig._internal();

  static const String _key = "server_link";
  String _serverLink =
      "http://192.168.0.8:3000";
      // "http://10.100.164.196:3000";

  String get serverLink => _serverLink;

  Future<void> loadServerLink() async {
    final myServices = Get.find<MyServices>();
    final savedLink = myServices.sharedPref.getString(_key);
    if (savedLink != null && savedLink.isNotEmpty) {
      _serverLink = savedLink;
    }
  }

  // Future<void> updateServerLink(String newLink) async {
  //   _serverLink = newLink;
  //   final myServices = Get.find<MyServices>();
  //   await myServices.sharedPref.setString(_key, newLink);
  // }

  // Future<void> resetToDefault() async {
  //   _serverLink = "http://192.168.74.4:5000/api";
  //   final myServices = Get.find<MyServices>();
  //   await myServices.sharedPref.setString(_key, _serverLink);
  // }
}
