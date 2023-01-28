import 'package:shared_preferences/shared_preferences.dart';

class SavedUserData{

  // ignore: prefer_typing_uninitialized_variables
  static var isSignedIn = false;
  // ignore: prefer_typing_uninitialized_variables
  static var userName = '';
  // ignore: prefer_typing_uninitialized_variables
  static var temporaryIp = '';
  // ignore: prefer_typing_uninitialized_variables
  static var sharedPreferences;
  // ignore: prefer_typing_uninitialized_variables
  static var savedUserData;

  static Future<SharedPreferences> init() async {
    savedUserData ??= SavedUserData();
    sharedPreferences = await SharedPreferences.getInstance();

    return sharedPreferences;
  }

  static void rememberUser(String ip, String name, String password) {
    sharedPreferences.setString('ip', ip);
    sharedPreferences.setString('name', name);
    sharedPreferences.setString('password', password);
  }

  static String? getUserName() {
    var _name;
    if(sharedPreferences.getString('name') != null){
      _name = sharedPreferences.getString('name');
    } else {
      _name = userName;
    }

    return _name;
  }

  static String? getPassword(){
    var _password;
    if(sharedPreferences.getString('password') != null){
      _password = sharedPreferences.getString('password');
    }

    return _password;
  }

  static String? getIP() {
    // ignore: prefer_typing_uninitialized_variables
    var _ip;
    if (sharedPreferences.getString('ip') != null) {
      _ip = sharedPreferences.getString('ip');
    } else {
      _ip = temporaryIp;
    }
    return _ip;
  }

  static void clear() {
    sharedPreferences.clear();
    userName = '';
    isSignedIn = false;
    temporaryIp = '';
  }
}
