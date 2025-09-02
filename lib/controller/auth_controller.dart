// import 'package:get/get.dart';
// import 'package:maria_pitanga/services/secure_storage.dart';

// class AuthController extends GetxController {
//   SecureStorageService secureStorage = SecureStorageService();
//   final _authenticated = false.obs;
//   final _username = RxString('');

//   bool get authenticated => _authenticated.value;
//   set authenticated(value) => _authenticated.value = value;
//   String get username => _username.value;
//   set username(value) => _username.value = value;

//   @override
//   void onInit() {
//     authenticated = secureStorage.isLogged();
//     ever(_authenticated, (value) {
//       if (value) {
//         username = secureStorage.getEmail();
//       }
//     });
//     super.onInit();
//   }
// }
