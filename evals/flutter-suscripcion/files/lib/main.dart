import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logged = await Api.instance.hasSession();
  runApp(FitPlanApp(logged: logged));
}

class FitPlanApp extends StatelessWidget {
  const FitPlanApp({super.key, required this.logged});
  final bool logged;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPlan',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.deepOrange, brightness: Brightness.dark, useMaterial3: true),
      home: logged ? const HomeScreen() : const LoginScreen(),
    );
  }
}
