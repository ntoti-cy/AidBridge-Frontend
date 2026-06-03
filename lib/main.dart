import 'package:aid_bridge/Controllers/auth/auth_cubit.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit authCubit;
  

  @override
  void initState() {
    super.initState();
    
    //Initialize the Cubit 
    authCubit = AuthCubit(AuthService());
  }

  @override
  void dispose() {
    authCubit.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false, 
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
      ),
    );
  }
}