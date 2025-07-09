// lib/widgets/book_card.dart

import 'package:booq/models/book.dart';
import 'package:booq/screens/book_detail_screen.dart';
import 'package:booq/utils/app_styles.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: book.id),
          ), // MODIFIED
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'book_cover_${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.h3.copyWith(fontSize: 16),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyTextSecondary,
          ),
        ],
      ),
    );
  }
}
