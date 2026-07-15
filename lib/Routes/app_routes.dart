import 'package:aid_bridge/Views/screens/beneficiary/beneficiary_profile.dart';
import 'package:aid_bridge/Views/screens/beneficiary/tokens.dart';
import 'package:aid_bridge/Views/screens/officer/beneficiary_details.dart';
import 'package:aid_bridge/Views/screens/officer/officer_profile.dart';
import 'package:get/get.dart';

// Common imports
import 'package:aid_bridge/Views/screens/splash.dart';
import 'package:aid_bridge/Views/screens/auth/login.dart';
import 'package:aid_bridge/Views/screens/auth/register.dart';
import '../Views/screens/crud/changepassword.dart';

// beneficiary imports
import 'package:aid_bridge/Views/screens/beneficiary/beneficiary_dashboard.dart';
import 'package:aid_bridge/Views/screens/beneficiary/qrcode.dart';
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

  // Beneficiary
  static const beneficiaryDashboard = '/beneficiaryDashboard';
  static const qrcode = '/qrcode';
  static const tokens = '/tokens';
  static const completeProfile = '/completeProfile';
  static const beneficiaryProfile = '/beneficiaryProfile';

  // Officer
  static const officerDashboard = '/officerDashboard';
  static const qrScanner = '/qrScanner';
  static const beneficiaryList = '/beneficiaryList';
  static const beneficiaryDetails = '/beneficiaryDetails';
  static const officerProfile = '/officerProfile';

  // Route Definitions

  static final pages = [
    //  Common Pages
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => Login()),
    GetPage(name: register, page: () => const Register()),
    GetPage(name: changePassword, page: () => ChangePassword()),

    // Beneficiary Pages
    GetPage(name: completeProfile, page: () => CompleteProfile()),
    GetPage(name: qrcode, page: () => QrCode()),
    GetPage(name: tokens, page: () => Tokens()),
    GetPage(name: beneficiaryDashboard, page: () => BeneficiaryDashboard()),
    GetPage(name: beneficiaryProfile, page: () => BeneficiaryProfile()),

    //  Officer Pages
    GetPage(name: beneficiaryList, page: () => BeneficiaryList()),

    GetPage(name: officerDashboard, page: () => OfficerDashboard()),
    GetPage(name: qrScanner, page: () => QRScanner()),
    GetPage(name: beneficiaryDetails, page: () => BeneficiaryDetails()),
    GetPage(name: officerProfile, page: () => OfficerProfile()),
  ];
}
