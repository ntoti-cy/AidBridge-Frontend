import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/auth/auth_cubit.dart';
import 'package:aid_bridge/Controllers/auth/auth_state.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final firstnameController = TextEditingController();
    final secondnameController = TextEditingController();
    final nationalidController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.10),
      //appBar: AppBar(centerTitle: true, title: const Text('Register')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
             if (state.data["message"] == "Saved locally (offline mode)") {
              Get.snackbar(
                "Offline Mode",
                "Account saved locally. You can login offline.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
            Get.offAndToNamed(AppRoutes.login);
          }

          if (state is AuthFailure && state.generalError != null) {
            Get.snackbar(
              'Error',
              state.generalError!,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: errorColor,
              colorText: Colors.white,
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
                  padding: const EdgeInsets.all(10),
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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: firstnameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              errorText: errors["first_name"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "first_name",
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: secondnameController,
                            decoration: InputDecoration(
                              labelText: 'Second Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              errorText: errors["second_name"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "second_name",
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: nationalidController,
                            decoration: InputDecoration(
                              labelText: 'National ID',
                              prefixIcon: const Icon(
                                Icons.assignment_ind_outlined,
                              ),
                              errorText: errors["national_id"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "national_id",
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: contactController,
                            decoration: InputDecoration(
                              labelText: 'Contact',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              errorText: errors["contact"]?.first,
                            ),
                            onChanged: (_) {
                              context.read<AuthCubit>().clearFieldError(
                                "contact",
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                              labelText: 'Password',
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
                                    context.read<AuthCubit>().register(
                                      firstName: firstnameController.text
                                          .trim(),
                                      secondName: secondnameController.text
                                          .trim(),
                                      nationalId: nationalidController.text
                                          .trim(),
                                      contact: contactController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                  },
                                  child: const Text('Register'),
                                ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => Get.offAndToNamed(AppRoutes.login),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Already have an account? ",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  TextSpan(
                                    text: "Login",
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
