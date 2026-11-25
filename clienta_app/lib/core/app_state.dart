import 'package:flutter/material.dart';

enum UserRole { client, employee }

class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.company,
    required this.title,
    required this.country,
    required this.flag,
    required this.role,
    this.phone = '+94 77 123 4567',
    this.photoUrl,
  });

  String name;
  String email;
  String company;
  String title;
  String country;
  String flag;
  String phone;
  String? photoUrl;
  final UserRole role;

  String get firstName => name.split(' ').first;
  bool get isEmployee => role == UserRole.employee;
}

/// Theme mode lives in its own notifier so toggling it re-themes the app
/// without rebuilding unrelated listeners.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light);
  static final instance = ThemeController._();

  void toggle(Brightness current) =>
      value = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
}

/// Session, preferences and demo switches.
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  AppUser? user;
  bool onboardingSeen = false;
  String language = 'English';
  String regionCountry = 'Sri Lanka';
  String regionFlag = '🇱🇰';

  // Demo switches (Settings → Developer)
  bool offline = false;
  bool simulateErrors = false;

  // Notification preferences
  final Map<String, bool> notificationPrefs = {
    'Event announcements': true,
    'Agenda & live sessions': true,
    'Chat messages': true,
    'Meeting invitations': true,
    'PCU news': true,
    'Email digest': false,
  };

  // Privacy preferences
  final Map<String, bool> privacyPrefs = {
    'Show my profile to event participants': true,
    'Allow participants to message me': true,
    'Show online status': true,
    'Share anonymous usage analytics': false,
    'Personalised news by country': true,
  };

  // Permissions granted in this session (camera, location, notifications)
  final Set<String> grantedPermissions = {};

  void signIn(AppUser u) {
    user = u;
    notifyListeners();
  }

  void signOut() {
    user = null;
    notifyListeners();
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  static AppUser demoClient() => AppUser(
        name: 'Induwara Perera',
        email: 'induwara.perera@example.com',
        company: 'Crystal Apparel (Pvt) Ltd',
        title: 'Sustainability Manager',
        country: 'Sri Lanka',
        flag: '🇱🇰',
        role: UserRole.client,
        photoUrl: 'assets/images/profile/induwara.jpg',
      );

  static AppUser demoEmployee() => AppUser(
        name: 'Dilini Jayasinghe',
        email: 'dilini.jayasinghe@example.com',
        company: 'Peterson & Control Union',
        title: 'Client Experience Lead',
        country: 'Sri Lanka',
        flag: '🇱🇰',
        role: UserRole.employee,
        photoUrl: 'assets/images/profile/dilini.jpg',
      );
}
