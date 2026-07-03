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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: primaryColor.withOpacity(.1),
            child: const Icon(Icons.person, color: primaryColor, size: 42),
          ),

          const SizedBox(height: 18),

          Text(
            beneficiary["beneficiary_name"] ??
                beneficiary["name"] ??
                "Unknown Beneficiary",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            "National ID: ${beneficiary["national_id"] ?? "-"}",
            style: const TextStyle(color: textSecondaryColor),
          ),

          const SizedBox(height: 18),

          Chip(
            avatar: Icon(
              active ? Icons.check_circle : Icons.cancel,
              color: active ? successColor : errorColor,
              size: 18,
            ),
            backgroundColor: active
                ? successColor.withOpacity(.12)
                : errorColor.withOpacity(.12),
            label: Text(
              active ? "ACTIVE TOKEN" : "INVALID TOKEN",
              style: TextStyle(
                color: active ? successColor : errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////
  // Small Statistics Card
  ////////////////////////////////////////////////////

  Widget _statCard(IconData icon, String title, dynamic value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor),

            const SizedBox(height: 10),

            Text(title, style: const TextStyle(color: textSecondaryColor)),

            const SizedBox(height: 6),

            Text(
              "$value",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////
  // Information Tile
  ////////////////////////////////////////////////////

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(.1),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }
  //--------------------------------------------------
  // Build
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfficerCubit, OfficerState>(
      listener: (context, state) {
        if (state is AidDistributed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: successColor,
              content: Text("Aid distributed successfully."),
            ),
          );

          Get.back(result: true);
        }

        if (state is OfficerFailure) {
          setState(() {
            collectingAid = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: errorColor, content: Text(state.message)),
          );
        }
      },

      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: textColor,

            title: const Text(
              "Beneficiary Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: Get.back,
            ),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                //------------------------------------------------
                // Profile
                //------------------------------------------------
                _profileCard(),

                const SizedBox(height: 24),

                //------------------------------------------------
                // Household Information
                //------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(Icons.groups_outlined, color: primaryColor),

                          SizedBox(width: 10),

                          Text(
                            "Household Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          _statCard(
                            Icons.people_outline,
                            "Members",
                            beneficiary["total_members"] ??
                                beneficiary["household_members"] ??
                                0,
                          ),

                          const SizedBox(width: 14),

                          _statCard(
                            Icons.child_care,
                            "Dependents",
                            beneficiary["dependents_count"] ?? 0,
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _infoTile(
                        Icons.accessible_forward,
                        "Disability",
                        beneficiary["disability_present"] == true
                            ? "Present"
                            : "None",
                      ),

                      const Divider(height: 28),

                      _infoTile(
                        Icons.payments_outlined,
                        "Income",
                        "KES ${beneficiary["income_level"] ?? 0}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                //------------------------------------------------
                // Distribution Information
                //------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: primaryColor),

                          SizedBox(width: 10),

                          Text(
                            "Distribution Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _infoTile(
                        Icons.location_city,
                        "Distribution Centre",
                        beneficiary["distribution_center"] ?? "Not Assigned",
                      ),

                      const Divider(height: 28),

                      _infoTile(
                        Icons.qr_code,
                        "Aid Token",
                        beneficiary["aid_token"] ?? "-",
                      ),

                      const Divider(height: 28),

                      ListTile(
                        contentPadding: EdgeInsets.zero,

                        leading: CircleAvatar(
                          backgroundColor: beneficiary["aid_collected"] == true
                              ? successColor.withOpacity(.12)
                              : Colors.orange.withOpacity(.12),

                          child: Icon(
                            beneficiary["aid_collected"] == true
                                ? Icons.check_circle
                                : Icons.inventory_2_outlined,

                            color: beneficiary["aid_collected"] == true
                                ? successColor
                                : Colors.orange,
                          ),
                        ),

                        title: const Text("Aid Status"),

                        subtitle: Text(
                          beneficiary["aid_collected"] == true
                              ? "Already Collected"
                              : "Pending Collection",
                        ),

                        trailing: Chip(
                          backgroundColor: beneficiary["aid_collected"] == true
                              ? successColor.withOpacity(.12)
                              : Colors.orange.withOpacity(.12),

                          label: Text(
                            beneficiary["aid_collected"] == true
                                ? "COLLECTED"
                                : "PENDING",

                            style: TextStyle(
                              color: beneficiary["aid_collected"] == true
                                  ? successColor
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                //------------------------------------------------
                // Distribute Aid Button
                //------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    onPressed:
                        collectingAid || beneficiary["aid_collected"] == true
                        ? null
                        : () {
                            setState(() {
                              collectingAid = true;
                            });

                            context.read<OfficerCubit>().distributeAid(
                              beneficiary["aid_token"],
                            );
                          },

                    icon: collectingAid
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.volunteer_activism),

                    label: Text(
                      beneficiary["aid_collected"] == true
                          ? "Aid Already Collected"
                          : collectingAid
                          ? "Processing..."
                          : "Distribute Aid",
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
