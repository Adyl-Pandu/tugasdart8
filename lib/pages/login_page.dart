import 'package:firebase_auth/firebase_auth.dart'; // [BARU] package Firebase Authentication
import 'package:flutter/material.dart';

// import 'home_page.dart';

// Class MyLogin (Stateful) di file login_page.dart sesuai materi
class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  // [BARU] Controller untuk menangkap input email & password dari UI
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // [BARU] state loading (spinner di tombol) & pesan error
  bool _isLoading = false;
  String? _error;

  // [TAMBAH] state untuk tombol lihat/sembunyikan password
  bool _obscure = true;

  // [TAMBAH] bersihkan controller agar tidak memory leak
  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // [BARU] Fungsi private login ke Firebase (sama seperti materi, ditambah validasi)
  Future<void> _login() async {
    // [TAMBAH] validasi sederhana: input tidak boleh kosong
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }

    // Tampilkan loading & reset error lama
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // [BARU] Proses login ke Firebase Auth (Email/Password)
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      final user = credential.user;

      if (!mounted) return;

      // Dialog sukses (sesuai materi), setelah OK pindah ke Home
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login Success'),
          content: Text('UID: ${user?.uid}\nEmail: ${user?.email}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      // [TAMBAH] pindah ke HomePage dan hapus halaman login dari stack
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomePage()),
      // );
    } on FirebaseAuthException catch (e) {
      // [BARU] error dari Firebase (password salah, user tidak ada, dll)
      setState(() {
        _error = _friendlyError(e);
      });
    } catch (e) {
      // [BARU] error lain (misal tidak ada internet)
      setState(() {
        _error = e.toString();
      });
    } finally {
      // [BARU] apapun hasilnya, matikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // [TAMBAH] ubah kode error Firebase jadi pesan yang mudah dibaca
  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return e.message ?? 'Terjadi kesalahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [UBAH] UI login lebih bagus: gradient + card di tengah
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 56, color: Colors.indigo),
                      const SizedBox(height: 8),
                      const Text(
                        'Login Firebase (Flutter)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Input email (terhubung ke emailCtrl)
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input password (terhubung ke passCtrl)
                      TextField(
                        controller: passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: const OutlineInputBorder(),
                          // [TAMBAH] ikon mata untuk toggle password
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _login(), // [TAMBAH] Enter = login
                      ),
                      const SizedBox(height: 16),

                      // [BARU] tampilkan pesan error kalau ada
                      if (_error != null) ...[
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                      ],

                      // [BARU] tombol login: dinonaktifkan saat loading
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}