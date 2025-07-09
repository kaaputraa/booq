// lib/pages/add_book_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booq/providers/book_provider.dart';
import 'package:booq/models/book.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for book details
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  Future<void> _addBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newBook = Book(
          id: '', // ID akan diisi oleh Firestore saat ditambahkan
          title: _titleController.text,
          author: _authorController.text,
          publisher: _publisherController.text,
          category: _categoryController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          rating: double.parse(_ratingController.text),
          pages: int.parse(_pagesController.text),
          language: _languageController.text,
        );

        await Provider.of<BookProvider>(
          context,
          listen: false,
        ).addBookToFirestore(newBook);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil ditambahkan!')),
        );

        // Clear input fields after adding and pop the page
        _titleController.clear();
        _authorController.clear();
        _publisherController.clear();
        _categoryController.clear();
        _descriptionController.clear();
        _imageUrlController.clear();
        _ratingController.clear();
        _pagesController.clear();
        _languageController.clear();
        Navigator.pop(context); // Kembali ke halaman admin setelah berhasil
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan buku: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    _pagesController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Semua TextFormField dari AdminPage sebelumnya
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Buku'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penulis tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(labelText: 'Penerbit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penerbit tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar Cover',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL Gambar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (contoh: 4.5)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rating tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Rating harus angka';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pagesController,
                decoration: const InputDecoration(labelText: 'Jumlah Halaman'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah halaman tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Jumlah halaman harus angka bulat';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Bahasa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bahasa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addBook,
                  child: const Text('Tambah Buku'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
