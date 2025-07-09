import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lending_provider.dart';
import '../providers/book_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/borrowing.dart'; // Pastikan ini diimpor
import '../models/book.dart';

class UserBorrowedBooksScreen extends StatelessWidget {
  const UserBorrowedBooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('Silakan login untuk melihat buku pinjaman Anda.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buku Pinjaman Anda')),
      body: StreamBuilder<List<Borrowing>>(
        stream: Provider.of<LendingProvider>(
          context,
        ).getUserBorrowings(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Anda belum meminjam buku apa pun.'),
            );
          }

          final borrowings = snapshot.data!;
          return ListView.builder(
            itemCount: borrowings.length,
            itemBuilder: (ctx, i) {
              final borrowing = borrowings[i];
              // Pastikan buku masih ada sebelum mencoba mengambil detailnya
              if (borrowing.bookId.isEmpty) {
                return const ListTile(title: Text('Data buku tidak valid.'));
              }
              return FutureBuilder<Book?>(
                future: Provider.of<BookProvider>(
                  context,
                  listen: false,
                ).getBookById(borrowing.bookId),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Memuat detail buku...'));
                  }
                  if (bookSnapshot.hasError ||
                      !bookSnapshot.hasData ||
                      bookSnapshot.data == null) {
                    return const ListTile(
                      title: Text('Buku tidak tersedia/ditemukan.'),
                    );
                  }
                  final book = bookSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Judul: ${book.title}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Penulis: ${book.author}'),
                          Text(
                            'Tanggal Pinjam: ${borrowing.borrowDate.toLocal().toString().split(' ')[0]}',
                          ),
                          Text(
                            'Status: ${borrowing.status == 'borrowed' ? 'Sedang Dipinjam' : 'Sudah Dikembalikan'}',
                          ),
                          if (borrowing.returnDate != null)
                            Text(
                              'Tanggal Kembali: ${borrowing.returnDate!.toLocal().toString().split(' ')[0]}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
