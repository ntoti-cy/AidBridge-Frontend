import 'package:get/get.dart';

// Common imports
import 'package:aid_bridge/Views/screens/splash.dart';
import 'package:aid_bridge/Views/screens/auth/login.dart';
import 'package:aid_bridge/Views/screens/auth/register.dart';

// beneficiary imports
import 'package:aid_bridge/Views/screens/beneficiary/beneficiary_dashboard.dart';
import 'package:aid_bridge/Views/screens/beneficiary/qrcode.dart';
import 'package:aid_bridge/Views/screens/beneficiary/token_status.dart';

// officer imports
import 'package:aid_bridge/Views/screens/officer/officer_dashboard.dart';
import 'package:aid_bridge/Views/screens/officer/beneficiary_list.dart';
import 'package:aid_bridge/Views/screens/officer/qrscanner.dart';
class AppRoutes {
  
  // Common
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  // Beneficiary
  static const beneficiaryDashboard = '/beneficiaryDashboard';
  static const qrcode = '/qrcode';
  static const tokenStatus = '/tokenStatus';

  // Officer
  static const officerDashboard = '/officerDashboard';
  static const qrScanner = '/qrScanner';
  static const beneficiaryList = '/beneficiaryList';


  // Route Definitions
  
  static final pages = [
    //  Common Pages 
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => Login()),
    GetPage(name: register, page: () => const Register()),

    // Beneficiary Pages 
    GetPage(
      name: qrcode, page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return QrCode(
          token: args['token'] ?? '',
        );
      }
    ),
      
    GetPage(
      name: tokenStatus, page: (){
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return TokenStatus(
          token: args['token'] ?? '',
        );
      },
    ),


    GetPage(
      name: beneficiaryDashboard,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return BeneficiaryDashboard(
          firstName: args['firstName'] ?? 'User',
          secondName: args['secondName'] ?? '',
          token: args['token'] ?? '',
          isEligible: args['isEligible'] ?? true, 
        );
      },
    ),



    //  Officer Pages 

    GetPage(
      name: beneficiaryList, 
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return BeneficiaryList(token: args['token'] ?? '');
      }
    ),
    
    
    GetPage(
      name: officerDashboard,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return OfficerDashboard(
          firstName: args['firstName'] ?? 'Officer',
          secondName: args['secondName'] ?? '',
          aidCenter: args['aidCenter'] ?? 'Main Distribution Center',
          token: args['token'] ?? '',
        );
      },
    ),
    GetPage(
      name: qrScanner,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return QRScanner(token: args['token'] ?? '');
      },
    ),
  ];
}