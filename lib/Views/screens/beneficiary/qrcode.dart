import 'dart:async';
import 'dart:convert';

import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final int maxTime = 120;

  int timeLeft = 120;

  Timer? _timer;

  bool isExpired = false;
  bool showCode = false;

  String qrData = "";
  String manualToken = "";
  String sessionName = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TokenCubit>().requestToken();
    });
  }

  void startTimer() {
    _timer?.cancel();

    timeLeft = maxTime;
    isExpired = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          setState(() {
            isExpired = true;
          });

          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TokenCubit, TokenState>(
      listener: (context, state) {
        if (state is TokenGenerated) {
          manualToken = state.token["aid_token"];

          sessionName =
              state.token["session_name"] ??
              "Distribution Center";

          qrData = jsonEncode({
            "token": manualToken,
            "exp": maxTime.toString(),
          });

          startTimer();
        }
      },

      builder: (context, state) {
        if (state is TokenLoading) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is TokenFailure) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<TokenCubit>()
                          .requestToken();
                    },
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! TokenGenerated) {
          return const Scaffold(
            body: SizedBox(),
          );
        }

        final progress = timeLeft / maxTime;

        final activeColor = isExpired
            ? Colors.red
            : (timeLeft <= 30
                ? Colors.orange
                : primaryColor);

        return Scaffold(
          backgroundColor: backgroundColor,

          appBar: AppBar(
            title: const Text(
              "Digital Aid Token",
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

          body: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [

                Text(
                  sessionName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                CircularProgressIndicator(
                  value: progress,
                  color: activeColor,
                ),

                const SizedBox(height: 20),

                QrImageView(
                  data: qrData,
                  size: 220,
                ),

                const SizedBox(height: 20),

                Text(
                  isExpired
                      ? "Expired"
                      : "$timeLeft seconds remaining",
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        const Text(
                          "Manual Token",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          showCode
                              ? manualToken
                              : "••••••••••••",
                          style:
                              const TextStyle(
                            fontSize: 24,
                            letterSpacing: 2,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: isExpired
                              ? null
                              : () {
                                  setState(() {
                                    showCode =
                                        !showCode;
                                  });
                                },
                          icon: Icon(
                            showCode
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isExpired
                        ? () {
                            context
                                .read<
                                    TokenCubit>()
                                .requestToken();
                          }
                        : null,
                    child: Text(
                      isExpired
                          ? "Generate New Token"
                          : "Token Active",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}