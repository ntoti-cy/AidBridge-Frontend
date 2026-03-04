import 'package:flutter/material.dart';
import '../../../Controllers/help/db_helper.dart';
import '../../../Controllers/sync/beneficiary_controller.dart';

class BeneficiaryList extends StatefulWidget {
  const BeneficiaryList({Key? key}) : super(key: key);

  @override
  _BeneficiaryListState createState() => _BeneficiaryListState();
}

class _BeneficiaryListState extends State<BeneficiaryList> {
  final DBHelper db = DBHelper();
  final BeneficiaryController syncController = BeneficiaryController();

  List<dynamic> beneficiaries = [];
  final TextEditingController tokenInputController = TextEditingController();
  String tokenStatus = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Load beneficiaries from API and SQLite
  Future<void> loadData() async {
    try {
      // Sync from API
      await syncController.syncBeneficiaries();

      // Load all beneficiaries from DB
      final bList = await db.getBeneficiaries();
      setState(() {
        beneficiaries = bList;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  /// Check token offline
  Future<void> checkToken() async {
    final tokenValue = tokenInputController.text.trim();
    if (tokenValue.isEmpty) return;

    String status = await db.getTokenStatus(tokenValue);
    setState(() {
      tokenStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beneficiaries & Token Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Sync button
            ElevatedButton(
              onPressed: loadData,
              child: const Text('Sync Beneficiaries from API'),
            ),
            const SizedBox(height: 20),

            /// Beneficiaries list
            const Text('Beneficiaries:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: beneficiaries.isEmpty
                  ? const Center(child: Text('No beneficiaries found'))
                  : ListView.builder(
                      itemCount: beneficiaries.length,
                      itemBuilder: (context, index) {
                        final b = beneficiaries[index];
                        return ListTile(
                          title: Text(b.name),
                          subtitle: Text('National ID: ${b.nationalId} | Token: ${b.aidToken}'),
                          trailing: Text(
                            b.tokenStatus,
                            style: TextStyle(
                                color: b.tokenStatus == 'active' ? Colors.green : Colors.red),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(),

            /// Token offline lookup
            const SizedBox(height: 10),
            TextField(
              controller: tokenInputController,
              decoration: const InputDecoration(
                labelText: 'Enter token to check offline',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkToken,
              child: const Text('Check Token'),
            ),
            if (tokenStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Status: $tokenStatus',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
