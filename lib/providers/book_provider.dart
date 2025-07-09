// lib/providers/book_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance; // Instance Firestore

  // Daftar buku yang disimpan (lokal, masih untuk fitur bookmark)
  final List<Book> _savedBooks = [];
  List<Book> get savedBooks => _savedBooks;

  // Daftar buku yang fetched dari Firestore
  List<Book> _books = [];
  List<Book> get books => _books;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BookProvider() {
    fetchBooks(); // Panggil saat BookProvider diinisialisasi
  }

  // ---- Metode untuk Mengambil Buku dari Firestore ----
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('books')
          .get(); // Ambil semua dokumen dari koleksi 'books'

      _books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching books: $e");
      // Anda bisa menambahkan logika penanganan error yang lebih baik di sini
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW METHOD: Get Book by ID
  Future<Book?> getBookById(String bookId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection('books')
          .doc(bookId)
          .get();
      if (doc.exists) {
        return Book.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error getting book by ID: $e");
      return null;
    }
  }

  // ---- Metode untuk Menambahkan Buku ke Firestore ----
  Future<void> addBookToFirestore(Book book) async {
    try {
      // Menambahkan dokumen baru dengan ID yang otomatis dibuat oleh Firestore
      await _db.collection('books').add(book.toFirestore());
      await fetchBooks(); // Refresh daftar buku setelah menambahkan
    } catch (e) {
      print("Error adding book: $e");
    }
  }

  // ---- Metode untuk Memperbarui Buku di Firestore (opsional) ----
  Future<void> updateBookInFirestore(Book book) async {
    try {
      await _db.collection('books').doc(book.id).update(book.toFirestore());
      await fetchBooks(); // Refresh daftar buku setelah memperbarui
    } catch (e) {
      print("Error updating book: $e");
    }
  }

  // ---- Metode untuk Menghapus Buku dari Firestore (opsional) ----
  Future<void> deleteBookFromFirestore(String bookId) async {
    try {
      await _db.collection('books').doc(bookId).delete();
      await fetchBooks(); // Refresh daftar buku setelah menghapus
    } catch (e) {
      print("Error deleting book: $e");
    }
  }

  // ---- Fungsionalitas Saved Books (bookmark) tetap sama ----
  void addBook(Book book) {
    if (!isBookSaved(book)) {
      _savedBooks.add(book);
      notifyListeners();
    }
  }

  void removeBook(Book book) {
    _savedBooks.removeWhere((item) => item.id == book.id);
    notifyListeners();
  }

  bool isBookSaved(Book book) {
    return _savedBooks.any((item) => item.id == book.id);
  }

  void toggleSaved(Book book) {
    if (isBookSaved(book)) {
      removeBook(book);
    } else {
      addBook(book);
    }
  }
}
