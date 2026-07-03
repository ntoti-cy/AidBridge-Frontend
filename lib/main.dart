import 'package:aid_bridge/Controllers/auth/auth_cubit.dart';
import 'package:aid_bridge/Controllers/beneficiary/beneficiary_cubit.dart';
import 'package:aid_bridge/Controllers/crud/crud_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  DioClient.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  // final AuthService authService;

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthService())),
        BlocProvider<CrudCubit>(create: (_) => CrudCubit(AuthService())), 
        BlocProvider<BeneficiaryCubit>(create: (_) => BeneficiaryCubit(AuthService())),
        BlocProvider<OfficerCubit>(create: (_) => OfficerCubit(AuthService())),
        BlocProvider<TokenCubit>(create: (_) => TokenCubit(AuthService())),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false, 
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
      ),
    );
  }
} 