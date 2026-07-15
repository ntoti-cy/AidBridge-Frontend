import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
import 'package:aid_bridge/Models/beneficiary_model.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BeneficiaryList extends StatefulWidget {
  const BeneficiaryList({super.key});

  @override
  State<BeneficiaryList> createState() => _BeneficiaryListState();
}

class _BeneficiaryListState extends State<BeneficiaryList> {
  final DBHelper db = DBHelper();

  final searchController = TextEditingController();
  final tokenController = TextEditingController();

  List<Beneficiary> beneficiaries = [];
  List<Beneficiary> filtered = [];
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
              final name = (b.name).toString().toLowerCase();
              final nationalId = (b.nationalId).toString().toLowerCase();
              final aidToken = (b.aidToken).toString().toLowerCase();
              return name.contains(q) ||
                  nationalId.contains(q) ||
                  aidToken.contains(q);
            }).toList();
    });
  }

  void _updateLastSync() {
    setState(() {
      lastSync =
          "${DateTime.now().hour.toString().padLeft(2, '0')}:"
          "${DateTime.now().minute.toString().padLeft(2, '0')}";
    });
  }

  void _openDetails(Beneficiary b) async {
    // Convert SQLite model object or Map safely into a standard Map for Get.arguments
    final Map<String, dynamic> beneficiaryMap = {
      "name": b.name,
      "national_id": b.nationalId,
      "aid_token": b.aidToken,
      "token_status": b.tokenStatus,
      "total_members": b.totalMembers,
      "dependents_count": b.dependentsCount,
      "income_level": b.incomeLevel,
      "disability_present": b.disabilityPresent,
      "distribution_center": b.distributionCenter,
      "aid_collected": (b.tokenStatus).toString().toLowerCase() == "used",
    };

    final result = await Get.toNamed(
      AppRoutes.beneficiaryDetails,
      arguments: beneficiaryMap,
    );
    if (result == true) {
      _loadOfflineData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfficerCubit(AuthService()),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: textColor,
          title: const Text(
            "Offline Beneficiaries",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: Get.back,
          ),
        ),
        body: AppBackground(
          child: BlocConsumer<OfficerCubit, OfficerState>(
            listener: (context, state) async {
              if (state is OfficerLoading) {
                setState(() {
                  downloading = true;
                });
              }

              if (state is BeneficiariesDownloaded) {
                setState(() {
                  downloading = false;
                });
                await _loadOfflineData();
                _updateLastSync();

                if (!mounted) return;
                _updateLastSync();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: successColor,
                    content: Text("${state.count} beneficiaries downloaded."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }

              if (state is OfficerFailure) {
                setState(() {
                  downloading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: errorColor,
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (_, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _downloadCard(),
                    const SizedBox(height: 20),
                    _searchBar(),
                    const SizedBox(height: 20),
                    _beneficiaryList(),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Offline Database",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Download beneficiaries for seamless offline verification.",
          style: TextStyle(color: textSecondaryColor, fontSize: 13),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      context.read<OfficerCubit>().downloadBeneficiaries();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                  : const Icon(Icons.sync_rounded, size: 20),
              label: Text(
                downloading ? "Downloading..." : "Download Latest",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
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
        hintText: "Search beneficiary by name or ID...",
        hintStyle: const TextStyle(color: textSecondaryColor, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: textSecondaryColor),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
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
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            "No beneficiaries found.",
            style: TextStyle(color: textSecondaryColor, fontSize: 14),
          ),
        ),
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

  Widget _beneficiaryCard(Beneficiary b) {
    final active = (b.tokenStatus).toString().toLowerCase() == "active";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetails(b),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "ID: ${b.nationalId}",
                          style: const TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(b.tokenStatus),
                    backgroundColor: active
                        ? successColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: active ? successColor : textSecondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b.aidToken,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: textColor,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: textSecondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SMALL INFO BOX
  // =====================================================

  Widget _infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: textSecondaryColor, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
