import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/token/token_cubit.dart';
import 'package:aid_bridge/Controllers/token/token_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Tokens extends StatefulWidget {
  const Tokens({super.key});

  @override
  State<Tokens> createState() => _TokensState();
}

class _TokensState extends State<Tokens> {
  bool showTokenCode = false;

  @override
  Widget build(BuildContext context) {
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
            await context.read<TokenCubit>().loadDashboard();
          },
          child: BlocBuilder<TokenCubit, TokenState>(
            builder: (context, state) {
              if (state is TokenLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (state is TokenFailure) {
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
              }

              if (state is! TokenDashboardLoaded) {
                context.read<TokenCubit>().loadDashboard();
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final token = state.status;
              final history = state.history;
              final bool hasToken = token["has_token"] == true;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  const Text(
                    "Current Token",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!hasToken) _emptyToken() else _tokenCard(token),
                  const SizedBox(height: 28),
                  const Text(
                    "Collection History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (history.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: const Text(
                        "No collection history recorded",
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ...history.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _historyCard(item),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tokenCard(Map<String, dynamic> token) {
    final status = (token["token_status"] ?? "").toString().toUpperCase();
    final isActive = status == "ACTIVE";
    final badgeColor = isActive ? successColor : accentColor;
    final rawToken = token["aid_token"]?.toString() ?? "";

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
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
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 28,
                  color: primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.isEmpty ? "ACTIVE" : status,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showTokenCode ? rawToken : "••••••••••••",
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    showTokenCode = !showTokenCode;
                  });
                },
                icon: Icon(
                  showTokenCode
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          _detail("Centre", token["center_name"] ?? "Distribution Centre"),
          _detail("Issued", token["token_issued_at"] ?? "-"),
          _detail("Expiry", token["expiry_time"] ?? "-"),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final status = (item["token_status"] ?? item["status"] ?? "")
        .toString()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: secondaryColor,
            size: 22,
          ),
        ),
        title: Text(
          item["center_name"] ?? item["center"] ?? "Distribution Centre",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        subtitle: Text(
          item["token_issued_at"] ?? item["date"] ?? "",
          style: const TextStyle(color: textSecondaryColor, fontSize: 11),
        ),
        trailing: Text(
          status,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyToken() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.qr_code_2_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No Active Token",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Generate an active token from your dashboard to proceed.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
