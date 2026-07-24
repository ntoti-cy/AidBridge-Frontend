import 'package:aid_bridge/Configs/background.dart';
import 'package:aid_bridge/Configs/colors.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_cubit.dart';
import 'package:aid_bridge/Controllers/connectivity/connectivity_state.dart';
import 'package:aid_bridge/Controllers/officer/officer_cubit.dart';
import 'package:aid_bridge/Controllers/officer/officer_state.dart';
import 'package:aid_bridge/Controllers/sync/sync_cubit.dart';
import 'package:aid_bridge/Controllers/sync/sync_state.dart';
import 'package:aid_bridge/Local/offline_cubit.dart';
import 'package:aid_bridge/Routes/app_routes.dart';
import 'package:aid_bridge/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  bool startingSession = false;
  bool endingSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final offline = context.read<ConnectivityCubit>().state.isOffline;

    if (offline) {
      context.read<OfflineCubit>().loadStatistics();
    } else {
      context.read<OfficerCubit>().loadDashboard();
    }
  }

  Future<void> _refresh() async {
    _loadDashboardData();
  }

  Future<void> _logout() async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: errorColor),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          content: const Text(
            "Are you sure you want to sign out of AidBridge?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: errorColor),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    if (logout == true) {
      await AuthService().logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Officer Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: primaryColor,
                    ),
                  ),
                  title: const Text(
                    "View Profile",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "View your personal information",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textSecondaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.officerProfile);
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.orange),
                  ),
                  title: const Text(
                    "Change Password",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Update your account password",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textSecondaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.changePassword);
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    "Sign out of AidBridge",
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
                const Divider(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<ConnectivityCubit>().state.isOffline;

    return Scaffold(
      body: AppBackground(
        child: MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityState>(
              listener: (context, state) {
                _loadDashboardData();
              },
            ),

            BlocListener<SyncCubit, SyncState>(
              listener: (context, state) {
                if (state is SyncSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: successColor,
                      content: Text(state.message),
                    ),
                  );

                  // Refresh dashboard statistics
                  _loadDashboardData();
                }

                if (state is SyncFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: errorColor,
                      content: Text(state.message),
                    ),
                  );
                }
              },
            ),
          ],

          child: RefreshIndicator(
            onRefresh: _refresh,
            color: primaryColor,
            child: isOffline
                ? BlocBuilder<OfflineCubit, OfflineState>(
                    builder: (context, state) {
                      if (state is OfflineStatisticsLoaded) {
                        final stats = state.stats;

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          children: [
                            const SizedBox(height: 20),
                            _buildWelcomeBanner({}, true),
                            const SizedBox(height: 24),
                            _buildOfflineStatisticsGrid(stats),
                            const SizedBox(height: 24),
                            _buildSessionControlCard({}, true),
                            const SizedBox(height: 24),
                            const Text(
                              "Quick Actions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildInteractiveActions(),
                            const SizedBox(height: 24),
                            _buildOfflineSyncCard(),
                            const SizedBox(height: 30),
                          ],
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    },
                  )
                : BlocConsumer<OfficerCubit, OfficerState>(
                    listener: (context, state) {
                      if (state is OfficerActionFailure) {
                        setState(() {
                          startingSession = false;
                          endingSession = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: errorColor,
                            content: Text(state.message),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }

                      if (state is SessionStarting) {
                        setState(() {
                          startingSession = true;
                        });
                      }

                      if (state is SessionEnding) {
                        setState(() {
                          endingSession = true;
                        });
                      }

                      if (state is OfficerLoaded) {
                        setState(() {
                          startingSession = false;
                          endingSession = false;
                        });
                      }

                      if (state is AidDistributed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: successColor,
                            content: Text("Aid distributed successfully."),
                            behavior: SnackBarBehavior.floating,
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
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

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        children: [
                          const SizedBox(height: 20),
                          _buildWelcomeBanner(officer, false),
                          const SizedBox(height: 24),
                          _buildStatisticsGrid(state),
                          const SizedBox(height: 24),
                          _buildSessionControlCard(officer, false),
                          const SizedBox(height: 24),
                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildInteractiveActions(),
                          const SizedBox(height: 24),
                          _buildSyncCard(state, false),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // WELCOME BANNER
  Widget _buildWelcomeBanner(Map<String, dynamic> officer, bool isOffline) {
    final firstName = officer["first_name"] ?? "Officer";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, containerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Aid Officer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: _showProfileMenu,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "Welcome, $firstName",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text("😊", style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isOffline ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud_done,
                  size: 16,
                  color: isOffline ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isOffline ? "Offline Mode" : "Online",
                  style: TextStyle(
                    color: isOffline ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Distribution Center Active & Secure",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STATISTICS GRID
  Widget _buildStatisticsGrid(OfficerLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Served",
            state.servedToday.toString(),
            Icons.people_outline,
            successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Remaining",
            state.remainingAid.toString(),
            Icons.inventory_2_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Verified",
            state.servedToday.toString(),
            Icons.verified_outlined,
            primaryColor,
          ),
        ),
      ],
    );
  }

  // STATISTICS GRID
  Widget _buildOfflineStatisticsGrid(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Served",
            stats["served"].toString(),
            Icons.people_outline,
            successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Remaining",
            stats["remaining"].toString(),
            Icons.inventory_2_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Total",
            stats["total"].toString(),
            Icons.verified_outlined,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: textSecondaryColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // SESSION MANAGEMENT CARD
  Widget _buildSessionControlCard(
    Map<String, dynamic> officer,
    bool isOffline,
  ) {
    final int? centerId = officer["assigned_center_id"];
    final String centerName = officer["assigned_center_name"] ?? "Not Assigned";

    if (centerId == null && !isOffline) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          "You are not assigned to any distribution center.",
          style: TextStyle(
            color: errorColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Assigned Distribution Center",
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOffline ? "Offline Active Center" : centerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Session Control",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: successColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      onPressed: (isOffline || startingSession)
                          ? null
                          : () {
                              setState(() {
                                startingSession = true;
                              });
                              context.read<OfficerCubit>().startSession(null);
                            },
                      icon: startingSession
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: successColor,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 16),
                      label: const Text(
                        "Start",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: errorColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      onPressed: (isOffline || endingSession)
                          ? null
                          : () {
                              setState(() {
                                endingSession = true;
                              });
                              context.read<OfficerCubit>().endSession();
                            },
                      icon: endingSession
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: errorColor,
                              ),
                            )
                          : const Icon(Icons.stop_rounded, size: 16),
                      label: const Text(
                        "End",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // QUICK ACTIONS
  Widget _buildInteractiveActions() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.qr_code_scanner_rounded,
          title: "Scan QR Code",
          subtitle: "Scan beneficiary token for instant verification",
          color: primaryColor,
          onTap: () => Get.toNamed(AppRoutes.qrScanner),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          icon: Icons.groups_outlined,
          title: "Beneficiaries List",
          subtitle: "Browse offline lists and verify manual codes",
          color: Colors.blue,
          onTap: () => Get.toNamed(AppRoutes.beneficiaryList),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textSecondaryColor, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: textSecondaryColor,
        ),
        onTap: onTap,
      ),
    );
  }

  // SYNC CARD (ONLINE)
  Widget _buildSyncCard(OfficerLoaded state, bool isOffline) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, syncState) {
        bool syncing = syncState is SyncLoading;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_done_rounded,
                  color: successColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Offline Synchronization",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      syncing
                          ? "Synchronizing..."
                          : "Pending: ${state.pendingSync} • Last: ${state.lastSync}",
                      style: const TextStyle(
                        color: textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: (isOffline || syncing)
                    ? null
                    : () {
                        context.read<SyncCubit>().synchronize();
                      },

                child: syncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Sync", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  // SYNC CARD (OFFLINE)
  Widget _buildOfflineSyncCard() {
    return BlocBuilder<OfflineCubit, OfflineState>(
      builder: (context, state) {
        int pendingCount = 0;
        if (state is OfflineStatisticsLoaded) {
          pendingCount = state.stats["pending"] ?? 0;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Offline Synchronization",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Pending records: $pendingCount",
                      style: const TextStyle(
                        color: textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: null, // Disabled in offline mode
                child: const Text("Sync", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
