// lib/models/dummy_data.dart

import 'package:booq/models/book.dart';

final List<Book> dummyBooks = [
  Book(
    id: '1',
    title: 'The Midnight Library',
    author: 'Matt Haig',
    publisher: 'Gramedia',
    category: 'Fiction',
    description:
        'Between life and death there is a library, and within that library, the shelves go on forever. Every book provides a chance to try another life you could have lived. To see how things would be if you had made other choices . . . Would you have done anything different, if you had the chance to undo your regrets?',
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1602190253l/52578297.jpg',
    rating: 4.5,
    pages: 304,
    language: 'English',
  ),
  Book(
    id: '2',
    title: 'Atomic Habits',
    author: 'James Clear',
    publisher: 'Penguin Random House',
    category: 'Self-Help',
    description:
        'An easy & proven way to build good habits & break bad ones. Tiny Changes, Remarkable Results.',
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320l/40121378.jpg',
    rating: 4.8,
    pages: 320,
    language: 'English',
  ),
  Book(
    id: '3',
    title: 'Sapiens',
    author: 'Yuval Noah Harari',
    publisher: 'Gramedia',
    category: 'Science',
    description:
        'A brief history of humankind, from the Stone Age to the present.',
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1420585954l/23692271.jpg',
    rating: 4.7,
    pages: 464,
    language: 'English',
  ),
  Book(
    id: '4',
    title: 'Educated: A Memoir',
    author: 'Tara Westover',
    publisher: 'Penguin Random House',
    category: 'Memoir',
    description:
        'A memoir about a young girl who, kept out of school, leaves her survivalist family and goes on to earn a PhD from Cambridge University.',
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1506026634l/35133922.jpg',
    rating: 4.6,
    pages: 352,
    language: 'English',
  ),
];
