import '../../Models/beneficiary_model.dart';
import '../../Dio/dio_client.dart';
import '../help/db_helper.dart';

class BeneficiaryController {
  final DBHelper db = DBHelper();

  Future<void> syncBeneficiaries() async {
    try {
      final response = await DioClient.dio.get('/crud/download-beneficiaries');
      if (response.statusCode == 200) {
        List data = response.data; // assumes JSON list
        List<Beneficiary> beneficiaries =
            data.map((e) => Beneficiary.fromJson(e)).toList();

        await db.insertBeneficiaries(beneficiaries);
        //print('Synced ${beneficiaries.length} beneficiaries');
      }
    } catch (e) {
      print('Error syncing beneficiaries: $e');
    }
  }
}
