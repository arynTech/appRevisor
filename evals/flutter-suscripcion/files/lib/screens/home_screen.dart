import 'package:flutter/material.dart';
import '../services/api.dart';
import 'paywall_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const plans = ['Fuerza 3 días', 'Running 10K', 'Movilidad diaria', 'HIIT 20 minutos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitPlan'), actions: [
        IconButton(icon: const Icon(Icons.person), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
        IconButton(icon: const Icon(Icons.settings), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ]),
      body: FutureBuilder<bool>(
        future: Api.instance.isPremium(),
        builder: (context, snap) {
          final premium = snap.data ?? false;
          return ListView(children: [
            for (var i = 0; i < plans.length; i++)
              ListTile(
                title: Text(plans[i]),
                trailing: (i > 0 && !premium) ? const Icon(Icons.lock) : null,
                onTap: () {
                  if (i > 0 && !premium) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
                  }
                },
              ),
          ]);
        },
      ),
    );
  }
}
