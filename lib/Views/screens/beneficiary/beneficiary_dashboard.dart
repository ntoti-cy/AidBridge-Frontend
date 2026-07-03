import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/beneficiary/beneficiary_cubit.dart';
import 'package:aid_bridge/Controllers/beneficiary/beneficiary_state.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_state.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BeneficiaryDashboard extends StatefulWidget {
  const BeneficiaryDashboard({super.key});

  @override
  State<BeneficiaryDashboard> createState() =>
      _BeneficiaryDashboardState();
}

class _BeneficiaryDashboardState
    extends State<BeneficiaryDashboard> {
  @override
  void initState() {
    super.initState();

    context.read<BeneficiaryCubit>().loadProfile();
    context.read<TokenCubit>().loadHistory();
  }

  Future<void> _refresh() async {
    await context.read<BeneficiaryCubit>().refreshProfile();
    await context.read<TokenCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          "Beneficiary Dashboard",
          style: TextStyle(color: textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () {
              Get.offAllNamed(AppRoutes.login);
            },
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            //------------------------------------------------------------------
            // PROFILE
            //------------------------------------------------------------------

            BlocBuilder<
                BeneficiaryCubit,
                BeneficiaryState>(
              builder: (context, state) {

                if (state is BeneficiaryLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (state is BeneficiaryFailure) {
                  return Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Text(state.message),
                    ),
                  );
                }

                if (state is BeneficiaryLoaded) {
                  final profile = state.profile;

                  return Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Welcome ${profile["first_name"]}",
                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                              "Name : ${profile["first_name"]} ${profile["second_name"]}"),

                          Text(
                              "National ID : ${profile["national_id"]}"),

                          Text(
                              "Contact : ${profile["contact"]}"),

                          Text(
                              "Email : ${profile["email"]}"),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),

            const SizedBox(height: 20),

            //------------------------------------------------------------------
            // TOKEN
            //------------------------------------------------------------------

            BlocConsumer<TokenCubit, TokenState>(
              listener: (context, state) {

                if (state is TokenGenerated) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text("Token generated"),
                    ),
                  );

                  context
                      .read<TokenCubit>()
                      .loadHistory();
                }
              },

              builder: (context, state) {

                List history = [];

                if (state is TokenHistoryLoaded) {
                  history = state.history;
                }

                String currentToken = "";

                if (history.isNotEmpty) {
                  currentToken =
                      history.first["aid_token"]
                          .toString();
                }

                return Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Aid Token",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        SelectableText(
                          currentToken.isEmpty
                              ? "No active token"
                              : currentToken,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state
                                    is TokenLoading
                                ? null
                                : () {
                                    context
                                        .read<
                                            TokenCubit>()
                                        .requestToken();
                                  },
                            child: state
                                    is TokenLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    "Generate Token"),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            //------------------------------------------------------------------
            // HISTORY
            //------------------------------------------------------------------

            BlocBuilder<TokenCubit, TokenState>(
              builder: (context, state) {

                if (state is! TokenHistoryLoaded) {
                  return const SizedBox();
                }

                return Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Token History",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        if (state.history.isEmpty)
                          const Text(
                              "No previous tokens."),

                        ...state.history.map(
                          (token) => ListTile(
                            leading: const Icon(
                              Icons.qr_code,
                            ),
                            title: Text(
                              token["aid_token"]
                                  .toString(),
                            ),
                            subtitle: Text(
                              (token["token_status"] ?? token["status"])
                                  .toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}