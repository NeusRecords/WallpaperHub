import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import '../data/data.dart';
import '../models/wallpaper_model.dart';

class BackgroundService {
  static const String modeKey = "auto_changer_mode";
  static const int randomAlarmId = 100;
  static const int dayAlarmId = 101;
  static const int nightAlarmId = 102;

  // Initialization
  static Future<void> init() async {
    if (kIsWeb) return;
    await AndroidAlarmManager.initialize();
  }

  // Schedule Random Mode
  static Future<void> scheduleRandom() async {
    if (kIsWeb) return;
    await AndroidAlarmManager.cancel(dayAlarmId);
    await AndroidAlarmManager.cancel(nightAlarmId);
    await AndroidAlarmManager.periodic(
      const Duration(hours: 12),
      randomAlarmId,
      callbackRandom,
      exact: true,
      wakeup: true,
    );
  }

  // Schedule Day/Night Mode
  static Future<void> scheduleDayNight() async {
    if (kIsWeb) return;
    await AndroidAlarmManager.cancel(randomAlarmId);

    // 6:00 AM for Day
    final now = DateTime.now();
    var firstDay = DateTime(now.year, now.month, now.day, 6, 0);
    if (firstDay.isBefore(now)) firstDay = firstDay.add(const Duration(days: 1));

    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      dayAlarmId,
      callbackDay,
      startAt: firstDay,
      exact: true,
      wakeup: true,
    );

    // 6:00 PM (18:00) for Night
    var firstNight = DateTime(now.year, now.month, now.day, 18, 0);
    if (firstNight.isBefore(now)) firstNight = firstNight.add(const Duration(days: 1));

    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      nightAlarmId,
      callbackNight,
      startAt: firstNight,
      exact: true,
      wakeup: true,
    );
  }

  static Future<void> stopAll() async {
    if (kIsWeb) return;
    await AndroidAlarmManager.cancel(randomAlarmId);
    await AndroidAlarmManager.cancel(dayAlarmId);
    await AndroidAlarmManager.cancel(nightAlarmId);
  }

  // Callbacks
  @pragma('vm:entry-point')
  static Future<void> callbackRandom() async {
    print("BackgroundService: Random Mode triggered");
    await _fetchAndSet("trending");
  }

  @pragma('vm:entry-point')
  static Future<void> callbackDay() async {
    print("BackgroundService: Day Mode triggered");
    await _fetchAndSet("daylight landscape");
  }

  @pragma('vm:entry-point')
  static Future<void> callbackNight() async {
    print("BackgroundService: Night Mode triggered");
    await _fetchAndSet("night city stars");
  }

  static Future<void> _fetchAndSet(String query) async {
    try {
      String url = query == "trending" 
          ? "https://api.pexels.com/v1/curated?per_page=15&page=${Random().nextInt(10) + 1}"
          : "https://api.pexels.com/v1/search?query=$query&per_page=15&page=${Random().nextInt(5) + 1}";

      var response = await http.get(Uri.parse(url), headers: {"Authorization": apiKey});
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (jsonData["photos"].isNotEmpty) {
        int index = Random().nextInt(jsonData["photos"].length);
        String imgUrl = jsonData["photos"][index]["src"]["portrait"];
        
        // Download image
        var imgRes = await Dio().get(imgUrl, options: Options(responseType: ResponseType.bytes));
        final appDir = await getTemporaryDirectory();
        final file = io.File('${appDir.path}/bg_wallpaper.jpg');
        await file.writeAsBytes(imgRes.data);

        // Set wallpaper
        if (!kIsWeb) {
          await WallpaperManagerFlutter().setWallpaper(file, WallpaperManagerFlutter.bothScreens);
        }
        print("BackgroundService: Wallpaper set successfully");
      }
    } catch (e) {
      print("BackgroundService Error: $e");
    }
  }
}
