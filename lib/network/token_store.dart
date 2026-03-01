import 'package:shared_preferences/shared_preferences.dart';

class TokenData {
  final String token;
  final DateTime expUtc;
  const TokenData({required this.token, required this.expUtc});
}

class TokenStore {
  static const _kToken = 'ug_jwt_token';
  static const _kExpMs = 'ug_jwt_exp_utc_ms';

  Future<TokenData?> load() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(_kToken);
    final expMs = sp.getInt(_kExpMs);
    if (token == null || expMs == null) return null;
    return TokenData(
      token: token,
      expUtc: DateTime.fromMillisecondsSinceEpoch(expMs, isUtc: true),
    );
  }

  Future<void> save({required String token, required DateTime expUtc}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setInt(_kExpMs, expUtc.millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kExpMs);
  }
}
