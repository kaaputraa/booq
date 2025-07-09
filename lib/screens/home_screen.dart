// lib/screens/home_screen.dart

import 'package:booq/models/book.dart'; // Pastikan path ini benar
// import 'package:booqr/models/dummy_data.dart'; // Hapus atau jadikan komentar ini
import 'package:booq/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:booq/widgets/category_card.dart';
import 'package:booq/widgets/book_card.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:booq/providers/book_provider.dart'; // Import BookProvider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'All Books',
      'Comic',
      'Novel',
      'Manga',
      'Magazine',
    ];

    // Gunakan Consumer untuk mendengarkan perubahan pada BookProvider
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        // Tampilkan loading indicator jika data sedang dimuat
        if (bookProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Gunakan daftar buku dari provider
        final List<Book> booksToDisplay = bookProvider.books;

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, index) {
                        return CategoryCard(
                          title: categories[index],
                          isActive: index == 0,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Newly Added Section
                  const Text(
                    'Newly Added',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2 / 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: booksToDisplay
                        .length, // Gunakan daftar buku dari Firestore
                    itemBuilder: (ctx, index) {
                      return BookCard(book: booksToDisplay[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
