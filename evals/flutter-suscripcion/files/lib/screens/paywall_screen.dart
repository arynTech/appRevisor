import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitPlan Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Desbloquea todos los planes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Acceso a todos los planes de entrenamiento, vídeos de cada ejercicio y seguimiento semanal.'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => launchUrl(
              Uri.parse('https://pay.fitplan.example/checkout?plan=premium_monthly'),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('Hazte Premium por 9,99 €'),
          ),
        ]),
      ),
    );
  }
}
