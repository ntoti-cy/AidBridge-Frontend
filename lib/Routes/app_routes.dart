import 'package:aid_bridge/Views/screens/auth/login.dart';
import 'package:aid_bridge/Views/screens/auth/register.dart';
import 'package:aid_bridge/Views/screens/beneficiary/home.dart';
import 'package:aid_bridge/Views/screens/beneficiary/qrcode.dart';


import 'package:get/get.dart';


class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const homescreen ='/homeScreen';
   static const qrcode = '/Qrcode';

  static final pages = [
    GetPage(name: login, page: () => Login()),
    GetPage(name: register, page: () => Register()),
    GetPage(name: homescreen,page: ()=>HomeScreen()),
    GetPage(name: qrcode, page: () =>Qrcode()),
   
  ];
}
