import 'dart:convert';

class Base64Utils {
  static String encode(String data) {
    if (data.isEmpty) return '';
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  static String decode(String base64String) {
    final bytes = base64.decode(base64String);
    return utf8.decode(bytes);
  }
}
