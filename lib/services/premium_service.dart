import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_books/Services/api_service.dart';

class PremiumService {
  static const String _isPremiumKey = 'isPremium';
  static const String _subscriptionDateKey = 'subscriptionDate';
  static const String _userEmailKey = 'userEmail';

  // Save premium status locally and update backend
  static Future<void> savePremiumStatus({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, true);
    await prefs.setString(
        _subscriptionDateKey, DateTime.now().toIso8601String());
    await prefs.setString(
        _userEmailKey, email); // Store email for future API calls

    // Update backend
    await ApiService.updateSubscriptionStatus(email, true);
  }

  // Check if user has premium access - first check locally, then verify with backend
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final localIsPremium = prefs.getBool(_isPremiumKey) ?? false;

    // If local status says we're premium, double check with backend
    if (localIsPremium) {
      final email = prefs.getString(_userEmailKey);
      if (email != null) {
        final userProfile = await ApiService.getUserProfile(email);
        if (userProfile != null) {
          return userProfile['is_premium'] ?? false;
        }
      }
    }

    return localIsPremium;
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
    final email = prefs.getString(_userEmailKey);

    await prefs.remove(_isPremiumKey);
    await prefs.remove(_subscriptionDateKey);

    // Update backend if we have the email
    if (email != null) {
      await ApiService.updateSubscriptionStatus(email, false);
    }
  }

  // Sync with backend - call this at login time
  static Future<bool> syncWithBackend(String email) async {
    try {
      final userProfile = await ApiService.getUserProfile(email);
      if (userProfile != null) {
        final isPremium = userProfile['is_premium'] ?? false;
        final premiumUntil = userProfile['premium_until'];

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isPremiumKey, isPremium);
        await prefs.setString(_userEmailKey, email);

        if (premiumUntil != null) {
          await prefs.setString(_subscriptionDateKey, premiumUntil);
        }

        return isPremium;
      }
      return false;
    } catch (e) {
      print('Error syncing premium status: $e');
      // Default to false on error
      return false;
    }
  }
}
