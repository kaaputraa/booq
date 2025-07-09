import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/borrowing.dart';
import '../models/book.dart'; // Import model Book
import './book_provider.dart'; // Import BookProvider jika perlu akses data buku

class LendingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk meminjam buku
  Future<void> borrowBook(String bookId, String userId) async {
    try {
      final existingBorrowing = await _firestore
          .collection('borrowings')
          .where('bookId', isEqualTo: bookId)
          .where('status', isEqualTo: 'borrowed')
          .get();

      if (existingBorrowing.docs.isNotEmpty) {
        throw Exception('Buku sudah dipinjam!');
      }

      await _firestore
          .collection('borrowings')
          .add(
            Borrowing(
              id: '', // ID akan diisi oleh Firestore
              bookId: bookId,
              userId: userId,
              borrowDate: DateTime.now(),
              status: 'borrowed',
            ).toFirestore(),
          );
      // Optional: Perbarui status buku di koleksi 'books' jika Anda memiliki field status
      await _firestore.collection('books').doc(bookId).update({
        'isBorrowed': true,
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Method untuk mengembalikan buku
  Future<void> returnBook(String borrowingId) async {
    try {
      await _firestore.collection('borrowings').doc(borrowingId).update({
        'returnDate': Timestamp.fromDate(DateTime.now()),
        'status': 'returned',
      });
      // Optional: Perbarui status buku di koleksi 'books'
      final borrowingDoc = await _firestore
          .collection('borrowings')
          .doc(borrowingId)
          .get();
      final bookId = borrowingDoc.data()?['bookId'];
      if (bookId != null) {
        await _firestore.collection('books').doc(bookId).update({
          'isBorrowed': false,
        });
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Method untuk mendapatkan semua peminjaman (untuk admin)
  Stream<List<Borrowing>> getAllBorrowings() {
    return _firestore.collection('borrowings').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Borrowing.fromFirestore(doc)).toList();
    });
  }

  // Method untuk mendapatkan peminjaman berdasarkan pengguna (untuk user)
  Stream<List<Borrowing>> getUserBorrowings(String userId) {
    return _firestore
        .collection('borrowings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Borrowing.fromFirestore(doc))
              .toList();
        });
  }

  // Method untuk mendapatkan peminjaman aktif buku tertentu
  Future<Borrowing?> getActiveBorrowingForBook(String bookId) async {
    final querySnapshot = await _firestore
        .collection('borrowings')
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'borrowed')
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return Borrowing.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }
}
