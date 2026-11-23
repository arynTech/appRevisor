import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  Api._();
  static final instance = Api._();
  static const base = 'https://api.fitplan.example/v2';

  Future<bool> hasSession() async => (await SharedPreferences.getInstance()).getString('token') != null;

  Future<Map<String, String>> _headers() async {
    final t = (await SharedPreferences.getInstance()).getString('token');
    return {'Content-Type': 'application/json', if (t != null) 'Authorization': 'Bearer $t'};
  }

  Future<void> register(String email, String password, String phone) async {
    await http.post(Uri.parse('$base/auth/register'), headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password, 'phone': phone}));
  }

  Future<void> verifyOtp(String phone, String code) async {
    final r = await http.post(Uri.parse('$base/auth/verify'), headers: await _headers(),
        body: jsonEncode({'phone': phone, 'code': code}));
    (await SharedPreferences.getInstance()).setString('token', jsonDecode(r.body)['token']);
  }

  Future<bool> isPremium() async {
    final r = await http.get(Uri.parse('$base/me'), headers: await _headers());
    return jsonDecode(r.body)['premium'] == true;
  }

  Future<void> deleteAccount() async {
    await http.delete(Uri.parse('$base/me'), headers: await _headers());
    (await SharedPreferences.getInstance()).clear();
  }
}
