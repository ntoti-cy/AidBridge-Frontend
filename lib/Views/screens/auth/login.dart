import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/auth/auth_cubit.dart';
import 'package:aid_bridge/Controllers/auth/auth_state.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.10),
      // appBar: AppBar(centerTitle: true, title: const Text("LOGIN")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Show offline snackbar if offline
            if (state.token == "OFFLINE_TOKEN") {
              Get.snackbar(
                "Offline Mode",
                "Logged in offline",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }
            // 🚨 OPTION 2: READING DATA DIRECTLY FROM THE /me ENDPOINT 🚨
           
            final role = state.data?['role'] ?? 'beneficiary';
            final requiresPasswordChange = state.data?['requires_password_change'] ?? false;

            // 1. Check if they are forced to change password
            if (requiresPasswordChange) {
              // Get.toNamed('/change_password'); 
            } 
            // 2. Route Aid Workers
            else if (role == 'aid_worker') {
              Get.toNamed(AppRoutes.beneficiaryList);
            } 
            // 3. Route Beneficiaries
            else {
              Get.toNamed(
                AppRoutes.beneficiaryDashboard,
                arguments: {
                  // We get these directly from the Python /me JSON response!
                  'firstName': state.data?['first_name'] ?? 'User',
                  'secondName': state.data?['second_name'] ?? '',
                },
              );
            }
            }

          if (state is AuthFailure && state.generalError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.generalError!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          Map<String, List<String>> errors = {};

          if (state is AuthFailure) {
            errors = state.fieldErrors;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                ClipOval(
                  child: Image.asset(
                    'lib/assets/images/aidbridge_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 7,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Sign in to continue",
                            style: TextStyle(fontSize: 14, color: primaryColor),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: errors["email"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "email",
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.password),
                              errorText: errors["password"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "password",
                              );
                            },
                          ),

                          const SizedBox(height: 25),
                          //Syncing state
                          if (state is AuthSyncing)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(
                                    color: successColor,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Syncing offline data..."),
                                ],
                              ),
                            ),

                          state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: successColor,
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: cardColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<AuthCubit>().login(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                  },
                                  child: const Text("Login"),
                                ),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.register),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  TextSpan(
                                    text: "Register",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 22, 148, 212),
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
