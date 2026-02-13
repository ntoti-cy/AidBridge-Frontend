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
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Register')),

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            Get.offAndToNamed(AppRoutes.login);
          }else
          if (state is AuthFailure) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Container(
              width: 300,
              height: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                  color: Colors.black,
                  blurRadius: 7,
                  offset: Offset(0,5),
                )]

              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person)),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email)),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.password)),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
              
                  ElevatedButton(
                    onPressed: () {
                            if (nameController.text.isEmpty||emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter name,email and password"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }



                      context.read<AuthCubit>().register(
                            name: nameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                          );
                    },
                    child: const Text('Register'),
                  ),
                  SizedBox(height: 16),

                   GestureDetector(
                    onTap: () => Get.offAndToNamed(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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
      ),
    );
  }
}
