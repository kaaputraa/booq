import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: FutureBuilder<Book?>(
        future: bookProvider.getBookById(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Buku tidak ditemukan.'));
          }

          final book = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Judul: ${book.title}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Penulis: ${book.author}'),
                Text('Deskripsi: ${book.description}'),
                // Tambahkan kode QR jika admin
                if (_isAdmin) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Kode QR Buku (untuk dicetak):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: QrImageView(
                      data: book.id, // Data yang akan dienkode adalah ID buku
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                      errorStateBuilder: (cxt, err) {
                        return const Center(
                          child: Text(
                            'Oops! Gagal membuat QR Code.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID Buku: ${book.id}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
