// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import provider
import 'login_page.dart';
import '../providers/book_provider.dart'; // Import BookProvider
import '../widgets/book_card.dart'; // Import BookCard

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        title: const Text("Daftar Buku"), // Ubah judul AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        // Gunakan Consumer untuk mendengarkan perubahan di BookProvider
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return const Center(child: Text("Tidak ada buku yang tersedia."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom
              childAspectRatio: 0.6, // Rasio aspek item (sesuaikan jika perlu)
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: bookProvider.books.length,
            itemBuilder: (ctx, index) {
              final book = bookProvider.books[index];
              return BookCard(
                book: book,
              ); // Tampilkan BookCard untuk setiap buku
            },
          );
        },
      ),
    );
  }
}
