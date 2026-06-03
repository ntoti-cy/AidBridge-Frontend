import 'package:aid_bridge/Models/beneficiary_model.dart';
import 'package:aid_bridge/Dio/dio_client.dart';
import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:dio/dio.dart';

class BeneficiaryController {
  final DBHelper db = DBHelper();

  Future<Map<String, dynamic>> syncBeneficiaries(String token) async {
    try {
      final response = await DioClient.dio.get(
        '/api/officer/download-beneficiaries', 
        options: Options(
          headers: {'Authorization': 'Bearer $token'}, 
        ),
      );

      if (response.statusCode == 200) {
        // Extract the list from the JSON dictionary
        List<dynamic> data = response.data['beneficiaries'];
        String sessionName = response.data['session_name'] ?? 'Active Session';

        List<Beneficiary> beneficiaries = data.map((e) => Beneficiary.fromJson(e)).toList();

        await db.insertBeneficiaries(beneficiaries);
        
        return {
          "success": true, 
          "count": beneficiaries.length, 
          "session": sessionName
        };
      }
      return {"success": false, "error": "Failed to fetch data."};
      
    } on DioException catch (e) {
      return {
        "success": false, 
        "error": e.response?.data['error'] ?? "Network error during sync."
      };
    } catch (e) {
      return {"success": false, "error": "An unexpected error occurred."};
    }
  }
}