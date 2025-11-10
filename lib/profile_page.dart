import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/nova.jpg'),
            ),
            const SizedBox(height: 16),
            const Text('Firda Nova Safitri',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('TTL: Semarang, 20 November 2005'),
            const SizedBox(height: 6),
            const Text('NIM: 23670106'),
            const SizedBox(height: 6),
            const Text('Email: novamornov@gmail.com'),
            const SizedBox(height: 6),
            const Text('Prodi: Informatika • Semester: 5'),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('No HP'),
                subtitle: const Text('081548453659'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Instagram'),
                subtitle: const Text('@cyitsmorp'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
