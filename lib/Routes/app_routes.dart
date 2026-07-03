import 'package:aid_bridge/Controllers/beneficiary/beneficiary_state.dart';
import 'package:aid_bridge/Views/screens/crud/profile.dart';
import 'package:aid_bridge/Views/screens/crud/settings.dart';
import 'package:aid_bridge/Views/screens/officer/beneficiary_details.dart';
import 'package:get/get.dart';

// Common imports
import 'package:aid_bridge/Views/screens/splash.dart';
import 'package:aid_bridge/Views/screens/auth/login.dart';
import 'package:aid_bridge/Views/screens/auth/register.dart';
import '../Views/screens/crud/changepassword.dart';

// beneficiary imports
import 'package:aid_bridge/Views/screens/beneficiary/beneficiary_dashboard.dart';
import 'package:aid_bridge/Views/screens/beneficiary/qrcode.dart';
import 'package:aid_bridge/Views/screens/beneficiary/token_status.dart';
import '../Views/screens/beneficiary/complete profile.dart';

// officer imports
import 'package:aid_bridge/Views/screens/officer/officer_dashboard.dart';
import 'package:aid_bridge/Views/screens/officer/beneficiary_list.dart';
import 'package:aid_bridge/Views/screens/officer/qrscanner.dart';

class AppRoutes {
  // Common
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const changePassword = '/changePassword';
  static const settings = '/settings';
  static const profile = '/profile';

  // Beneficiary
  static const beneficiaryDashboard = '/beneficiaryDashboard';
  static const qrcode = '/qrcode';
  static const tokenStatus = '/tokenStatus';
  static const completeProfile = '/completeProfile';

  // Officer
  static const officerDashboard = '/officerDashboard';
  static const qrScanner = '/qrScanner';
  static const beneficiaryList = '/beneficiaryList';
  static const beneficiaryDetails = '/beneficiaryDetails';
  // Route Definitions

  static final pages = [
    //  Common Pages
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => Login()),
    GetPage(name: register, page: () => const Register()),
    GetPage(name: changePassword, page: () => ChangePassword()),
    GetPage(name: settings, page: () => Settings()),
    GetPage(name: profile, page: () => Profile()),

    // Beneficiary Pages
    GetPage(name: completeProfile, page: () => CompleteProfile()),
    GetPage(name: qrcode, page: () => QrCode()),
    GetPage(name: tokenStatus, page: () => TokenStatus()),
    GetPage(name: beneficiaryDashboard, page: () => BeneficiaryDashboard()),

    //  Officer Pages
    GetPage(
      name: beneficiaryList,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return BeneficiaryList(token: args['token'] ?? '');
      },
    ),

    GetPage(name: officerDashboard, page: () => OfficerDashboard()),
    GetPage(name: qrScanner, page: () => QRScanner()),
    GetPage(name: beneficiaryDetails, page: () => BeneficiaryDetails()),
  ];
}
