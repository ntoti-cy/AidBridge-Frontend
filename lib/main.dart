import 'dart:async';

import 'package:aid_bridge/Controllers/auth/auth_cubit.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Removed 'show' to ensure all classes are available
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
  // Use StreamSubscription<List<ConnectivityResult>> for compatibility with latest connectivity_plus
  late final StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    
    // 1. Initialize the Cubit once
    authCubit = AuthCubit(AuthService());

    // 2. Listen for network changes
    // This handles the list of results returned by newer versions of the plugin
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // If the list contains any valid connection (wifi, mobile, ethernet) and NOT 'none'
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        debugPrint("Network available, syncing offline users...");
        authCubit.syncOfflineUsers();
      }
    });
  }

  @override
  void dispose() {
    // 3. Cancel the subscription to prevent memory leaks
    connectivitySubscription.cancel();
    // It's also good practice to close the cubit if it's not needed after MyApp is destroyed
    authCubit.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Using .value because the cubit is already instantiated in initState
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false, // Cleaner UI during development
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
      ),
    );
  }
}