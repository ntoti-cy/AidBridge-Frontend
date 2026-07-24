import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class BeneficiaryDetails extends StatefulWidget {
  const BeneficiaryDetails({super.key});

  @override
  State<BeneficiaryDetails> createState() => _BeneficiaryDetailsState();
}

class _BeneficiaryDetailsState extends State<BeneficiaryDetails> {
  late final Map<String, dynamic> beneficiary;

  bool collectingAid = false;

  @override
  void initState() {
    super.initState();
    beneficiary = Get.arguments as Map<String, dynamic>;
  }

  bool get active =>
      (beneficiary["token_status"] ?? "").toString().toLowerCase() == "active";

  //--------------------------------------------------
  // Profile Card
  //--------------------------------------------------

  Widget _profileCard() {
    final displayName =
        beneficiary["name"] ??
        beneficiary["beneficiary_name"] ??
        "Unknown Beneficiary";

    return Container(
      padding: const EdgeInsets.all(22),
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
          CircleAvatar(
            radius: 36,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primaryColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "National ID: ${beneficiary["national_id"] ?? "-"}",
            style: const TextStyle(color: textSecondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Chip(
            avatar: Icon(
              active ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: active ? successColor : errorColor,
              size: 16,
            ),
            backgroundColor: active
                ? successColor.withOpacity(0.1)
                : errorColor.withOpacity(0.1),
            label: Text(
              active ? "ACTIVE TOKEN" : "INVALID TOKEN",
              style: TextStyle(
                color: active ? successColor : errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // Small Statistics Card
  //--------------------------------------------------

  Widget _statCard(IconData icon, String title, dynamic value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: textSecondaryColor, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              "$value",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Information Tile
  //--------------------------------------------------

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, color: textSecondaryColor),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Build
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool aidCollected = beneficiary["aid_collected"] == true;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        title: const Text(
          "Beneficiary Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: Get.back,
        ),
      ),
      body: AppBackground(
        child: BlocConsumer<OfficerCubit, OfficerState>(
          listener: (context, state) {
            if (state is AidDistributed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: successColor,
                  content: Text("Aid distributed successfully."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Get.back(result: true);
            }

            if (state is OfficerFailure) {
              setState(() {
                collectingAid = false;
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
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //------------------------------------------------
                  // Profile Card
                  //------------------------------------------------
                  _profileCard(),

                  const SizedBox(height: 20),

                  //------------------------------------------------
                  // Household Information
                  //------------------------------------------------
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Household Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statCard(
                              Icons.people_outline,
                              "Members",
                              beneficiary["total_members"] ??
                                  beneficiary["household_members"] ??
                                  0,
                            ),
                            const SizedBox(width: 12),
                            _statCard(
                              Icons.child_care_rounded,
                              "Dependents",
                              beneficiary["dependents_count"] ?? 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _infoTile(
                          Icons.accessible_forward_rounded,
                          "Disability Status",
                          beneficiary["disability_present"] == true
                              ? "Present"
                              : "None",
                        ),
                        const Divider(height: 20, color: Color(0xFFE5E7EB)),
                        _infoTile(
                          Icons.payments_outlined,
                          "Income Level",
                          "KES ${beneficiary["income_level"] ?? 0}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //------------------------------------------------
                  // Distribution Information
                  //------------------------------------------------
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Distribution Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _infoTile(
                          Icons.location_city_rounded,
                          "Distribution Center",
                          beneficiary["distribution_center"] ?? "Not Assigned",
                        ),
                        const Divider(height: 20, color: Color(0xFFE5E7EB)),
                        _infoTile(
                          Icons.qr_code_rounded,
                          "Aid Token",
                          beneficiary["aid_token"] ?? "-",
                        ),
                        const Divider(height: 20, color: Color(0xFFE5E7EB)),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: aidCollected
                                  ? successColor.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              aidCollected
                                  ? Icons.check_circle_rounded
                                  : Icons.inventory_2_outlined,
                              color: aidCollected
                                  ? successColor
                                  : Colors.orange,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            "Aid Status",
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondaryColor,
                            ),
                          ),
                          subtitle: Text(
                            aidCollected
                                ? "Already Collected"
                                : "Pending Collection",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          trailing: Chip(
                            backgroundColor: aidCollected
                                ? successColor.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            label: Text(
                              aidCollected ? "COLLECTED" : "PENDING",
                              style: TextStyle(
                                color: aidCollected
                                    ? successColor
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
