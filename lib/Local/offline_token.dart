import '../Controllers/help/db_helper.dart';
import '../Models/token_model.dart';

class OfflineToken {
  final DBHelper _db = DBHelper();

  Future<void> saveToken(Token token) async {
    await _db.insertToken(token);
  }

  Future<List<Token>> getHistory() async {
    return await _db.getTokens();
  }

  Future<Token?> getCurrentToken() async {
    final history = await _db.getTokens();

    if (history.isEmpty) {
      return null;
    }

    return history.first;
  }
}