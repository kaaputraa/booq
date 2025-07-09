// lib/pages/admin_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booq/pages/login_page.dart'; // Pastikan import ini mengarah ke login_page.dart yang benar
import 'package:booq/pages/add_book_page.dart'; // Import halaman baru AddBookPage

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selamat datang, Admin!",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke halaman AddBookPage saat tombol ditekan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBookPage()),
                );
              },
              icon: const Icon(Icons.add_box),
              label: const Text("Tambah Buku"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            // Anda bisa menambahkan fitur admin lainnya di sini,
            // seperti melihat daftar buku, mengedit, menghapus, dll.
          ],
        ),
      ),
    );
  }
}
