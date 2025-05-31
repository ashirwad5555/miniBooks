import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _isPremiumKey = 'isPremium';
  static const String _subscriptionDateKey = 'subscriptionDate';

  // Save premium status
  static Future<void> savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, true);
    await prefs.setString(
        _subscriptionDateKey, DateTime.now().toIso8601String());
  }

  // Check if user has premium access
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
  }

  // Get subscription date
  static Future<DateTime?> getSubscriptionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_subscriptionDateKey);
    if (dateStr == null) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Remove premium status (for testing purposes)
  static Future<void> removePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isPremiumKey);
    await prefs.remove(_subscriptionDateKey);
  }
}
