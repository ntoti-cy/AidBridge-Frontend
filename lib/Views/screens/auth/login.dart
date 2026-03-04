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
            Get.toNamed(AppRoutes.beneficiaryList);
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
                const SizedBox(height: 40),

                ClipOval(
                  child: Image.asset(
                    'lib/assets/images/aidbridge_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 30),

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
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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

                          const SizedBox(height: 30),

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

                          const SizedBox(height: 30),

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
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

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
                            fontWeight: FontWeight.w100,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
