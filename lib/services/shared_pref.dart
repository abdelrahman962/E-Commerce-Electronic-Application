import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  String userIdKey = "USERKEY";
  String userEmailKey = "USEREMAILKEY";
  String userNameKey = "USERNAMEKEY";
  String userAvatarKey = "USERAVATARKEY";
  Future<bool> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userIdKey, userId);
  }

  Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userEmailKey, userEmail);
  }

  Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userNameKey, userName);
  }

  Future<bool> saveUserAvatar(String userAvatar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userAvatarKey, userAvatar);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserAvatar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userAvatarKey);
  }
}
