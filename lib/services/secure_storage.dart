import 'package:localstorage/localstorage.dart';

class SecureStorageService {
  void addNewItem(String key, String value) {
    localStorage.setItem(key, value);
  }

  String? getEmail() {
    return localStorage.getItem("email");
  }

  bool isLogged() {
    return localStorage.getItem("email") != null;
  }
}
