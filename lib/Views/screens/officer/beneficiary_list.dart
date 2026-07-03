import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:aid_bridge/Controllers/sync/sync_cubit.dart';
import 'package:aid_bridge/Controllers/sync/sync_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryList extends StatefulWidget {
  final String token;

  const BeneficiaryList({super.key, required this.token});

  @override
  State<BeneficiaryList> createState() => _BeneficiaryListState();
}

class _BeneficiaryListState extends State<BeneficiaryList> {
  final DBHelper db = DBHelper();

  final searchController = TextEditingController();

  final tokenController = TextEditingController();

  List beneficiaries = [];

  List filtered = [];

  bool loading = true;

  bool downloading = false;

  String tokenStatus = "";

  String lastSync = "Never";

  @override
  void initState() {
    super.initState();

    _loadOfflineData();

    searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    searchController.dispose();
    tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadOfflineData() async {
    final data = await db.getBeneficiaries();

    if (!mounted) return;

    setState(() {
      beneficiaries = data;
      filtered = data;
      loading = false;
    });
  }

  void _filterList() {
    final q = searchController.text.trim().toLowerCase();

    setState(() {
      filtered = q.isEmpty
          ? beneficiaries
          : beneficiaries.where((b) {
              return b.name.toLowerCase().contains(q) ||
                  b.nationalId.toLowerCase().contains(q) ||
                  b.aidToken.toLowerCase().contains(q);
            }).toList();
    });
  }

  Future<void> _checkToken() async {
    final status = await db.getTokenStatus(tokenController.text.trim());

    if (!mounted) return;

    setState(() {
      tokenStatus = status.isEmpty ? "Token not found" : status;
    });
  }

  void _updateLastSync() {
    setState(() {
      lastSync =
          "${DateTime.now().hour.toString().padLeft(2, '0')}:"
          "${DateTime.now().minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SyncCubit(),
      child: Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: textColor,
          title: const Text("Offline Beneficiaries"),
        ),

        body: BlocConsumer<SyncCubit, SyncState>(
          listener: (context, state) async {
            if (state is SyncLoading) {
              setState(() {
                downloading = true;
              });
            }

            if (state is SyncSuccess) {
              downloading = false;

              await _loadOfflineData();

              _updateLastSync();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: successColor,
                  content: Text("${state.count} beneficiaries downloaded."),
                ),
              );

              context.read<SyncCubit>().resetState();
            }

            if (state is SyncFailure) {
              downloading = false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: errorColor,
                  content: Text(state.error),
                ),
              );

              context.read<SyncCubit>().resetState();
            }
          },

          builder: (_, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _header(),

                  const SizedBox(height: 20),

                  _downloadCard(),

                  const SizedBox(height: 20),

                  _verifyCard(),

                  const SizedBox(height: 20),

                  _searchBar(),

                  const SizedBox(height: 20),

                  _beneficiaryList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  // =====================================================
  // HEADER
  // =====================================================

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Offline Database",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          "Download beneficiaries for offline verification.",
          style: TextStyle(color: textSecondaryColor),
        ),
      ],
    );
  }

  // =====================================================
  // DOWNLOAD CARD
  // =====================================================

  Widget _downloadCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _infoBox("Downloaded", beneficiaries.length.toString()),
              ),

              const SizedBox(width: 12),

              Expanded(child: _infoBox("Last Sync", lastSync)),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: downloading
                  ? null
                  : () {
                      context.read<SyncCubit>().syncData(widget.token);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: downloading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(downloading ? "Downloading..." : "Download Latest"),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // VERIFY TOKEN
  // =====================================================

  Widget _verifyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          TextField(
            controller: tokenController,
            decoration: InputDecoration(
              labelText: "Aid Token",
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Verify Token"),
            ),
          ),

          if (tokenStatus.isNotEmpty) ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokenStatus.toLowerCase() == "active"
                    ? successColor.withOpacity(.12)
                    : errorColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tokenStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokenStatus.toLowerCase() == "active"
                      ? successColor
                      : errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Widget _searchBar() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Search beneficiary...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // =====================================================
  // BENEFICIARY LIST
  // =====================================================

  Widget _beneficiaryList() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: Text("No beneficiaries found.")),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (_, index) => _beneficiaryCard(filtered[index]),
    );
  }

  // =====================================================
  // BENEFICIARY CARD
  // =====================================================

  Widget _beneficiaryCard(dynamic b) {
    final active = b.tokenStatus.toLowerCase() == "active";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      b.nationalId,
                      style: const TextStyle(color: textSecondaryColor),
                    ),
                  ],
                ),
              ),

              Chip(
                label: Text(b.tokenStatus),
                backgroundColor: active
                    ? successColor.withOpacity(.15)
                    : Colors.grey.shade200,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.qr_code, size: 18, color: primaryColor),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  b.aidToken,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SMALL INFO BOX
  // =====================================================

  Widget _infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
