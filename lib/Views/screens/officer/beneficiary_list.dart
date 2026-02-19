import 'package:flutter/material.dart';
import '../../../Controllers/help/db_helper.dart';
import '../../../Models/beneficiary_model.dart';
import '../../../Models/token_model.dart';

class BeneficiaryList extends StatefulWidget {
  const BeneficiaryList({Key? key}) : super(key: key);

  @override
  _BeneficiaryList createState() => _BeneficiaryList();
}

class _BeneficiaryList extends State<BeneficiaryList> {
  final DBHelper db = DBHelper();
  List<Beneficiary> beneficiaries = [];
  List<Token> tokens = [];

  @override
  void initState() {
    super.initState();
    testDB();
  }

  Future<void> testDB() async {
    // Add sample beneficiary
    await db.insertBeneficiary(Beneficiary(
        id: 0,
        firstName: 'John',
        secondName: 'Doe',
        nationalId: '12345678',
        contact: '0712345678'));

    // Add sample token
    await db.insertToken(Token(id: 0, tokenValue: 'ABC123',   nationalId: '41410283', used: false));

    // Read all
    final bList = await db.getBeneficiaries();
    final tList = await db.getTokens();

    setState(() {
      beneficiaries = bList;
      tokens = tList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test DB')),
      body: Column(
        children: [
          const Text('Beneficiaries:'),
          ...beneficiaries.map((b) => Text('${b.firstName} ${b.secondName}')),
          const Divider(),
          const Text('Tokens:'),
          ...tokens.map((t) => Text('${t.tokenValue} - used: ${t.used}')),
        ],
      ),
    );
  }
}
