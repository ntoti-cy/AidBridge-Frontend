import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_state.dart';
import 'package:aid_bridge/Local/offline_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Tokens extends StatefulWidget {
  const Tokens({super.key});

  @override
  State<Tokens> createState() => _TokensState();
}

class _TokensState extends State<Tokens> {
  bool showTokenCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isOffline = context.read<ConnectivityCubit>().state.isOffline;
      if (isOffline) {
        context.read<OfflineCubit>().loadBeneficiaryDashboard();
      } else {
        context.read<TokenCubit>().loadDashboard();
      }
    });
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select(
      (ConnectivityCubit c) => c.state.isOffline,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        centerTitle: true,
        title: const Text(
          "My Aid Token",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: AppBackground(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            if (isOffline) {
              context.read<OfflineCubit>().loadBeneficiaryDashboard();
              return;
            }
            await context.read<TokenCubit>().loadDashboard();
          },
          child: BlocBuilder<OfflineCubit, OfflineState>(
            builder: (context, offlineState) {
              if (isOffline) {
                if (offlineState is! OfflineBeneficiaryLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (offlineState.tokens.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.signal_wifi_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Offline Data",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Connect to the internet once to\ndownload your aid information.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondaryColor),
                        ),
                      ],
                    ),
                  );
                }
                final token = Map<String, dynamic>.from(
                  offlineState.tokens.first,
                );

                return _buildTokenScreen(
                  token,
                  true,
                  offlineState.history,
                  isOffline: true,
                );
              }

              return BlocBuilder<TokenCubit, TokenState>(
                builder: (context, state) {
                  if (state is TokenLoading)
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  if (state is TokenFailure)
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: errorColor),
                        ),
                      ),
                    );
                  if (state is! TokenDashboardLoaded)
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  return _buildTokenScreen(
                    state.status,
                    state.status["has_token"] == true,
                    state.history,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTokenScreen(
    Map<String, dynamic> token,
    bool hasToken,
    List<dynamic> history, {
    bool isOffline = false,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // _buildSummaryCard(hasToken, history.length, token, offline: isOffline),
        // const SizedBox(height: 28),
        const Row(
          children: [
            Text(
              "Current Token",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!hasToken)
          _emptyToken()
        else
          _tokenCard(token, isOffline: isOffline),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        const Row(
          children: [
            Icon(Icons.history, color: secondaryColor),
            SizedBox(width: 8),
            Text(
              "Collection History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  "No Collection History",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Your previous aid collections will appear here.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...history
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _historyCard(item),
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _tokenCard(Map<String, dynamic> token, {bool isOffline = false}) {
    final status = (token["token_status"] ?? token["status"] ?? "ACTIVE")
        .toString()
        .toUpperCase();
    final rawToken = token["aid_token"] ?? token["token"] ?? "";
    final statusColor = status == "ACTIVE"
        ? successColor
        : (status == "EXPIRED" ? errorColor : accentColor);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status == "ACTIVE"
                        ? Icons.check_circle
                        : Icons.error_outline,
                    size: 15,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isOffline)
                    const Text(
                      " (OFFLINE)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            showTokenCode ? rawToken : "••••••••••••",
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => showTokenCode = !showTokenCode),
            icon: Icon(showTokenCode ? Icons.visibility_off : Icons.visibility),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          _detail(
            "Centre",
            token["center_name"] ??
                token["distribution_center"] ??
                "Distribution Centre",
          ),
          _detail(
            "Issued",
            _formatDate(token["token_issued_at"] ?? token["issued_at"] ?? "-"),
          ),
          _detail(
            "Expiry",
            _formatDate(token["expiry_time"] ?? token["expires_at"] ?? "-"),
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: textSecondaryColor, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _historyCard(Map<String, dynamic> item) {
    final status = (item["token_status"] ?? "").toString().toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.history, color: secondaryColor, size: 20),
        ),
        title: Text(
          item["center_name"] ?? "Centre",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDate(item["token_issued_at"] ?? item["date"] ?? "-"),
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _emptyToken() => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      children: [
        const Icon(Icons.qr_code_2, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          "No Active Token",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Generate Token from Dashboard",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
