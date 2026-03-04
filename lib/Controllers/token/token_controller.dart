import '../help/db_helper.dart';
import '../../Models/token_model.dart';

class TokenController {
  final DBHelper dbHelper = DBHelper();

  Future<List<Token>> getTokens() async {
    return await dbHelper.getTokens();
  }

  // Offline token check
  Future<String> checkToken(String tokenValue) async {
    return await dbHelper.getTokenStatus(tokenValue);
  }

  Future<void> markTokenUsed(String tokenValue) async {
    await dbHelper.markTokenUsed(tokenValue);
  }
}
