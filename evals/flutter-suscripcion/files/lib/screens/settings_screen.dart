import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('Se borrarán tu cuenta, tus planes y tu historial. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      await Api.instance.deleteAccount();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(children: [
        ListTile(
          title: const Text('Política de privacidad'),
          onTap: () => launchUrl(Uri.parse('https://fitplan.example/privacidad')),
        ),
        ListTile(
          title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.red)),
          onTap: () => _confirmDelete(context),
        ),
      ]),
    );
  }
}
