import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _postTaskWalkthroughKey = 'post_task_walkthrough_shown';
  static const String _taskerCategoriesCompletedKey = 'tasker_categories_completed';
  
  // Get onboarding completion status
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }
  
  // Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }
  
  // Reset onboarding status (useful for testing or if user wants to see onboarding again)
  static Future<void> resetOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }

  // App walkthrough (Post Task FAB) flag
  static Future<bool> isPostTaskWalkthroughShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_postTaskWalkthroughKey) ?? false;
  }

  static Future<void> markPostTaskWalkthroughShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_postTaskWalkthroughKey, true);
  }

  // Reset the post task walkthrough flag so it can show again
  static Future<void> resetPostTaskWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postTaskWalkthroughKey);
  }

  // First-time tasker categories completion flag
  static Future<bool> isTaskerCategoriesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_taskerCategoriesCompletedKey) ?? false;
  }

  static Future<void> markTaskerCategoriesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_taskerCategoriesCompletedKey, true);
  }

  static Future<void> resetTaskerCategoriesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taskerCategoriesCompletedKey);
  }
} 