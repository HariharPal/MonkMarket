import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/app_constants.dart';

class LocalStorage {
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeModeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeModeKey);
  }
}
