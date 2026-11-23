import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../services/api.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final code = TextEditingController();
  final telephony = Telephony.instance;
  bool waitingCode = false;

  Future<void> _register() async {
    await Api.instance.register(email.text, password.text, phone.text);
    setState(() => waitingCode = true);
    // Lee el SMS de verificación automáticamente
    final granted = await telephony.requestSmsPermissions ?? false;
    if (granted) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage msg) {
          final m = RegExp(r'\d{6}').firstMatch(msg.body ?? '');
          if (m != null) { code.text = m.group(0)!; _verify(); }
        },
        listenInBackground: false,
      );
    }
  }

  Future<void> _verify() async {
    await Api.instance.verifyOtp(phone.text, code.text);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Teléfono')),
          if (waitingCode) TextField(controller: code, decoration: const InputDecoration(labelText: 'Código SMS')),
          const SizedBox(height: 16),
          FilledButton(onPressed: waitingCode ? _verify : _register, child: Text(waitingCode ? 'Verificar' : 'Registrarme')),
        ]),
      ),
    );
  }
}
