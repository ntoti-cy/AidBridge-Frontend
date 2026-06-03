import 'package:aid_bridge/Configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Controllers/help/db_helper.dart';
import '../../../Controllers/sync/sync_cubit.dart';
import '../../../Controllers/sync/sync_state.dart';

class BeneficiaryList extends StatefulWidget {
  final String token; // Crucial: We need the JWT token to hit the API

  const BeneficiaryList({super.key, required this.token});

  @override
  State<BeneficiaryList> createState() => _BeneficiaryListState();
}

class _BeneficiaryListState extends State<BeneficiaryList> {
  final DBHelper db = DBHelper();

  List<dynamic> beneficiaries = [];
  final TextEditingController tokenInputController = TextEditingController();
  String tokenStatus = '';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  /// Load beneficiaries ONLY from local SQLite DB for display
  Future<void> _loadLocalData() async {
    try {
      final bList = await db.getBeneficiaries();
      setState(() {
        beneficiaries = bList;
      });
    } catch (e) {
      debugPrint('Error loading local data: $e');
    }
  }

  /// Check token offline (purely local, so setState is fine here)
  Future<void> checkToken() async {
    final tokenValue = tokenInputController.text.trim();
    if (tokenValue.isEmpty) return;

    String status = await db.getTokenStatus(tokenValue);
    setState(() {
      tokenStatus = status.isNotEmpty ? status : "Token not found locally";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SyncCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Sync & Lookup'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<SyncCubit, SyncState>(
          listener: (context, state) {
            if (state is SyncSuccess) {
              // Reload the local SQLite list now that we've pulled fresh data from Flask
              _loadLocalData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully synced ${state.count} records for ${state.sessionName}'),
                  backgroundColor: successColor,
                ),
              );
              context.read<SyncCubit>().resetState();
            } else if (state is SyncFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: errorColor,
                ),
              );
              context.read<SyncCubit>().resetState();
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Sync Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: state is SyncLoading 
                        ? null 
                        : () {
                            // Trigger the Cubit and pass the JWT Token
                            context.read<SyncCubit>().syncData(widget.token);
                          },
                    icon: state is SyncLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.sync_rounded),
                    label: Text(state is SyncLoading ? 'Syncing with Server...' : 'Download Active Session Data'),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 10),

                  /// Token Offline Lookup
                  const Text('Manual Offline Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tokenInputController,
                          decoration: const InputDecoration(
                            labelText: 'Enter token to check offline',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: checkToken,
                        child: const Text('Check'),
                      ),
                    ],
                  ),
                  if (tokenStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Status: ${tokenStatus.toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: tokenStatus == 'active' ? successColor : errorColor,
                          )),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 10),

                  /// Beneficiaries List (Loaded from Local SQLite)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Locally Saved Beneficiaries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Count: ${beneficiaries.length}', style: const TextStyle(color: textSecondaryColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: beneficiaries.isEmpty
                        ? const Center(child: Text('No offline data available. Sync required.'))
                        : ListView.builder(
                            itemCount: beneficiaries.length,
                            itemBuilder: (context, index) {
                              final b = beneficiaries[index];
                              return Card(
                                child: ListTile(
                                  title: Text(b.name),
                                  subtitle: Text('ID: ${b.nationalId}\nToken: ${b.aidToken}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: b.tokenStatus == 'active' ? successColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      b.tokenStatus.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: b.tokenStatus == 'active' ? successColor : Colors.grey.shade700),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}