import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyLogin()),
    );
  }

  String _tanggal(DateTime? d) {
    if (d == null) return '-';
    return d.toLocal().toString().substring(0, 16);
  }

  Widget _item(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photo = user?.photoURL;
    final verified = user?.emailVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.indigo.shade50,
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null
                  ? const Icon(Icons.person, size: 52, color: Colors.indigo)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Tanpa Nama',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _item(
                  verified ? Icons.verified : Icons.warning_amber_rounded,
                  'Status Email',
                  verified ? 'Terverifikasi' : 'Belum terverifikasi',
                ),
                const Divider(height: 1),
                _item(Icons.fingerprint, 'UID', user?.uid ?? '-'),
                const Divider(height: 1),
                _item(Icons.calendar_today, 'Akun dibuat',
                    _tanggal(user?.metadata.creationTime)),
                const Divider(height: 1),
                _item(Icons.access_time, 'Login terakhir',
                    _tanggal(user?.metadata.lastSignInTime)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}