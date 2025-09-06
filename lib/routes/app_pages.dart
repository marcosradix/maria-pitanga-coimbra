import 'package:get/get.dart';
import 'package:maria_pitanga/screen/custom_acai_screen.dart';
import 'package:maria_pitanga/screen/login_screen.dart';
import 'package:maria_pitanga/screen/loyalty_card_adm_screen.dart';
import 'package:maria_pitanga/screen/loyalty_card_screen.dart';
import 'package:maria_pitanga/screen/sign_up.dart';
import 'package:maria_pitanga/services/adm_auth_guard.dart';
import 'package:maria_pitanga/services/auth_guard.dart';

part './app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.LOGIN_PAGE, page: () => AcaiBuilderScreen()),
    GetPage(
      name: Routes.CARD,
      page: () => LoyaltyCardScreen(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.CARD_ADM,
      page: () => LoyaltyCardAdmScreen(),
      middlewares: [AuthGuard(), AdmAuthGuard()],
    ),
    GetPage(name: Routes.CUSTOM_ACAI, page: () => AcaiBuilderScreen()),
    GetPage(name: Routes.INITIAL, page: () => LoginPage()),
    GetPage(name: Routes.SIGN_UP, page: () => const SignUpPage()),
  ];
}
