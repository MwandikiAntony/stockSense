import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class TrialService {
  static const String _firstLaunchKey = 'first_launch_date';
  static const String _trialUsedKey = 'trial_used';
  static const int trialDurationDays = 14;

  // The trial clock comes only from the account's server-side trialStartDate.
  static DateTime? get _trialStart => AuthService.currentUser?.trialStartDate;

  /// Kept for existing callers.
  static Future<DateTime> getFirstLaunchDate() async =>
      _trialStart ?? DateTime.now();

  static Future<bool> isTrialExpired() async {
    final start = _trialStart;
    if (start == null) return false;
    return DateTime.now().difference(start) >=
        const Duration(days: trialDurationDays);
  }

  static Future<int> getRemainingDays() async {
    final start = _trialStart;
    if (start == null) return trialDurationDays;
    final remaining =
        trialDurationDays - DateTime.now().difference(start).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Set when an expired trial is logged out; stops this browser restarting a trial.
  static Future<bool> isTrialUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trialUsedKey) ?? false;
  }

  static Future<void> markTrialUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trialUsedKey, true);
  }

  /// Development/testing only.
  static Future<void> resetTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLaunchKey);
    await prefs.remove(_trialUsedKey);
  }
}
