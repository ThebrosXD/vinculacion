import 'dart:convert';

DateTime? jwtExpiry(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = json.decode(decoded);

    if (map is Map && map['exp'] != null) {
      final exp = map['exp'];
      final seconds = (exp is int) ? exp : int.tryParse(exp.toString());
      if (seconds == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
    }
    return null;
  } catch (_) {
    return null;
  }
}

bool isExpiringSoon(DateTime? expUtc, {Duration threshold = const Duration(minutes: 3)}) {
  if (expUtc == null) return true;
  final nowUtc = DateTime.now().toUtc();
  return expUtc.isBefore(nowUtc.add(threshold));
}
