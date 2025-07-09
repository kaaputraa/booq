import 'package:cloud_firestore/cloud_firestore.dart';

class Borrowing {
  final String id; // ID dokumen peminjaman
  final String bookId;
  final String userId;
  final DateTime borrowDate;
  final DateTime? returnDate; // Tanggal pengembalian aktual
  final String status; // 'borrowed', 'returned', 'overdue'

  Borrowing({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.borrowDate,
    this.returnDate,
    required this.status,
  });

  factory Borrowing.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Borrowing(
      id: doc.id,
      bookId: data['bookId'],
      userId: data['userId'],
      borrowDate: (data['borrowDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
      status: data['status'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status,
    };
  }
}
