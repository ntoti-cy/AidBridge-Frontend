import 'package:get/get.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var rememberMe = false.obs;


  void toggleRemember(bool value) {
    rememberMe.value = value;
  }
}
