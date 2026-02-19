import '../../Models/token_model.dart';
import '../help/db_helper.dart';

class TokenController {
  final DBHelper dbHelper = DBHelper();

  Future<List<Token>> getTokens() async {
    return await dbHelper.getTokens();
  }

  Future<bool> validateToken(String tokenValue) async {
    final tokens = await getTokens();
    final t = tokens.firstWhere(
        (t) => t.tokenValue == tokenValue && !t.used,
        orElse: () => Token(id: 0, tokenValue: '',  nationalId: '',  used: true));
    return t.id != 0;
  }

  Future<void> markTokenUsed(String tokenValue) async {
    await dbHelper.markTokenUsed(tokenValue);
  }
}
