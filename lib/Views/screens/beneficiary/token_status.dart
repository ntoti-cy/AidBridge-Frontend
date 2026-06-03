import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/history/history_cubit.dart';
import 'package:aid_bridge/Controllers/history/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class TokenStatus extends StatelessWidget {
  final String token; // The JWT token passed into the view

  const TokenStatus({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit()..fetchTokenHistory(token),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Collection History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
          centerTitle: true,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (state is HistoryError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_toggle_off_rounded, color: errorColor, size: 48),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: textColor)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        onPressed: () => context.read<HistoryCubit>().fetchTokenHistory(token),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              );
            }

            if (state is HistoryLoaded) {
              if (state.history.isEmpty) {
                return _buildEmptyStatePlaceholder();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final record = state.history[index];
                  final String status = record['token_status'] ?? 'inactive';
                  
                  // Color code the status dynamically matching your system colors
                  Color statusColor = textSecondaryColor;
                  if (status == 'active') statusColor = successColor;
                  if (status == 'used') statusColor = primaryColor;
                  if (status == 'expired') statusColor = errorColor;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            status == 'used' ? Icons.inventory_2_rounded : Icons.confirmation_num_rounded,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['session_name'] ?? 'Distribution Center',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Token: ${record['aid_token']}",
                                style: const TextStyle(fontFamily: 'Monospace', fontSize: 13, color: textSecondaryColor),
                              ),
                              if (record['token_issued_at'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  record['token_issued_at'],
                                  style: TextStyle(fontSize: 11, color: textSecondaryColor.withOpacity(0.8)),
                                ),
                              ]
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder() {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.04,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  ...List.generate(3, (index) => _buildGhostTile()),
                  const Spacer(),
                  ...List.generate(2, (index) => _buildGhostTile()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 0.65, 1.0],
                colors: [
                  backgroundColor.withOpacity(0.0),
                  backgroundColor,
                  backgroundColor,
                  backgroundColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 40, color: primaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "No History Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your generated tokens and collection\nactivity will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondaryColor, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGhostTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: textColor.withOpacity(0.5)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 8, width: 80, decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Container(height: 5, width: 140, decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(4))),
            ],
          )
        ],
      ),
    );
  }
}