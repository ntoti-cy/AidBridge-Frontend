import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<OfficerCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          "Officer Dashboard",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.settings);
            },
            icon: const Icon(Icons.settings_outlined, color: textColor),
          ),
        ],
      ),

      body: BlocConsumer<OfficerCubit, OfficerState>(
        listener: (context, state) {
          if (state is OfficerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: errorColor,
                content: Text(state.message),
              ),
            );
          }

          if (state is AidDistributed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: successColor,
                content: Text("Aid distributed successfully."),
              ),
            );
          }
        },

        builder: (context, state) {
          if (state is OfficerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (state is OfficerFailure) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<OfficerCubit>().loadDashboard();
                },
                child: const Text("Retry"),
              ),
            );
          }

          if (state is! OfficerLoaded) {
            return const SizedBox();
          }

          final officer = state.officer;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<OfficerCubit>().loadDashboard();
            },

            child: ListView(
              padding: const EdgeInsets.all(20),

              children: [
                _welcomeCard(officer),

                const SizedBox(height: 25),

                const Text(
                  "Today's Statistics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        "Served",
                        state.servedToday.toString(),
                        Icons.people,
                        Colors.green,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        "Remaining",
                        state.remainingAid.toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _statCard(
                        "Verified",
                        state.servedToday.toString(),
                        Icons.verified,
                        primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _quickActions(),

                const SizedBox(height: 28),

                _recentActivity(state),

                const SizedBox(height: 28),

                _syncCard(state),
              ],
            ),
          );
        },
      ),
    );
  }

  //====================================================
  // WELCOME CARD
  //====================================================

  Widget _welcomeCard(Map<String, dynamic> officer) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor.withOpacity(.1),
            child: const Icon(Icons.admin_panel_settings, color: primaryColor),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Officer",
                  style: TextStyle(color: textSecondaryColor),
                ),

                const SizedBox(height: 6),

                Text(
                  "Good Morning,\n${officer["first_name"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  //====================================================
  // QUICK ACTIONS
  //====================================================

  Widget _quickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _infoCard(
                icon: Icons.qr_code_scanner,
                title: "Scan QR",
                color: primaryColor,
                onTap: () => Get.toNamed(AppRoutes.qrScanner),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _infoCard(
                icon: Icons.groups_outlined,
                title: "Beneficiaries",
                color: Colors.blue,
                onTap: () => Get.toNamed(AppRoutes.beneficiaryList),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _infoCard(
                icon: Icons.settings,
                title: "Settings",
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////
  // RECENT ACTIVITY
  //////////////////////////////////////////////////////

  Widget _recentActivity(OfficerLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),

          child: state.recentActivity.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text("No recent activity")),
                )
              : Column(
                  children: state.recentActivity
                      .map(
                        (activity) => ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: primaryColor,
                          ),

                          title: Text(activity["action"] ?? ""),

                          subtitle: Text(activity["description"] ?? ""),

                          trailing: Text(activity["time"] ?? ""),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////
  // SYNC CARD
  //////////////////////////////////////////////////////

  Widget _syncCard(OfficerLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.green, size: 40),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Synchronization",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text("Pending: ${state.pendingSync}"),

                Text("Last Sync: ${state.lastSync}"),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              context.read<OfficerCubit>().synchronize();
            },
            child: const Text("Sync"),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  // STAT CARD
  //////////////////////////////////////////////////////

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(title),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  // ACTION CARD
  //////////////////////////////////////////////////////

  Widget _infoCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),

            const SizedBox(height: 10),

            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
