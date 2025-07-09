// lib/screens/saved_list_screen.dart

import 'package:booq/providers/book_provider.dart';
import 'package:booq/screens/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedListScreen extends StatelessWidget {
  const SavedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          final savedBooks = bookProvider.savedBooks;

          if (savedBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_remove_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Empty List',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You have no saved book',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: savedBooks.length,
            itemBuilder: (ctx, index) {
              final book = savedBooks[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    book.imageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(book.author),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark, color: Colors.blue),
                  onPressed: () {
                    Provider.of<BookProvider>(
                      context,
                      listen: false,
                    ).removeBook(book);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(book: book),
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
