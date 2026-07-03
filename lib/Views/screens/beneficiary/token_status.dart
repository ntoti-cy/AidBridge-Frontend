import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/history/history_cubit.dart';
import 'package:aid_bridge/Controllers/history/history_state.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TokenStatus extends StatelessWidget {
  const TokenStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(AuthService())..loadHistory(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Collection History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
        ),

        body: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            context.read<HistoryCubit>().refresh();
          },

          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {

              if (state is HistoryLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (state is HistoryFailure) {
                return _buildErrorState(
                  context,
                  state.message,
                );
              }

              if (state is HistoryLoaded) {

                if (state.history.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [

                    if (state.offline)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(.1),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [

                            Icon(
                              Icons.wifi_off,
                              color: Colors.orange,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Offline Mode\nShowing saved collection history.",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        physics:
                            const BouncingScrollPhysics(),
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {

                          final record =
                              state.history[index];

                          final status =
                              record["token_status"] ??
                                  "inactive";

                          Color color;

                          IconData icon;

                          switch (status) {

                            case "active":
                              color = successColor;
                              icon = Icons.check_circle;
                              break;

                            case "used":
                              color = primaryColor;
                              icon =
                                  Icons.inventory_2_rounded;
                              break;

                            case "expired":
                              color = errorColor;
                              icon =
                                  Icons.timer_off_rounded;
                              break;

                            default:
                              color = Colors.grey;
                              icon =
                                  Icons.confirmation_num;
                          }

                          return _buildHistoryCard(
                            record: record,
                            status: status,
                            color: color,
                            icon: icon,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
    Widget _buildHistoryCard({
    required Map<String, dynamic> record,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(.1),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    record["center_name"] ??
                        "Distribution Centre",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Token: ${record["aid_token"]}",
                    style: const TextStyle(
                      fontFamily: "monospace",
                      color: textSecondaryColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    record["token_issued_at"] ??
                        "",
                    style: const TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),

        Icon(
          Icons.receipt_long_outlined,
          size: 80,
          color: primaryColor.withOpacity(.5),
        ),

        const SizedBox(height: 24),

        const Center(
          child: Text(
            "No Collection History",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Text(
            "Generate an aid token and complete your first collection.\nYour history will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [

        const SizedBox(height: 120),

        const Icon(
          Icons.error_outline_rounded,
          color: errorColor,
          size: 70,
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ),

        const SizedBox(height: 30),

        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              context
                  .read<HistoryCubit>()
                  .refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ),
      ],
    );
  }
}