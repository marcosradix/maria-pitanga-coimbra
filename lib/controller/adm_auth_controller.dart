// import 'package:get/get.dart';
// import 'package:maria_pitanga/services/secure_storage.dart';

// class AdminAuthController extends GetxController {
//   SecureStorageService secureStorage = SecureStorageService();
//   final _isAdmin = false.obs;

//   bool get isAdmin => _isAdmin.value;
//   set isAdmin(value) => _isAdmin.value = value;

//   @override
//   void onInit() {
//     isAdmin = secureStorage.isAdmin();
//     ever(_isAdmin, (value) {
//       if (value) {
//         // Do something when the user is an admin
//       }
//     });
//     super.onInit();
//   }
// }
