import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? photo;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (x != null) setState(() => photo = File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 48, backgroundImage: photo != null ? FileImage(photo!) : null),
          TextButton(onPressed: _pick, child: const Text('Foto de progreso')),
        ]),
      ),
    );
  }
}
