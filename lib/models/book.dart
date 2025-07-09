// lib/models/book.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String category;
  final String description;
  final String imageUrl;
  final double rating;
  final int pages;
  final String language;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.pages,
    required this.language,
  });

  // Constructor untuk membuat objek Book dari DocumentSnapshot Firestore
  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // Pastikan data tidak null
    return Book(
      id: doc.id, // Menggunakan ID dokumen Firestore sebagai ID buku
      title: data['title'] as String,
      author: data['author'] as String,
      publisher: data['publisher'] as String,
      category: data['category'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String,
      rating: (data['rating'] as num)
          .toDouble(), // Cast ke num dulu, lalu ke double
      pages: data['pages'] as int,
      language: data['language'] as String,
    );
  }

  // Metode untuk mengubah objek Book menjadi Map agar bisa disimpan di Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'pages': pages,
      'language': language,
    };
  }
}
