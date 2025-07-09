import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/lending_provider.dart';
import '../providers/book_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart'; // ADDED
import '../models/borrowing.dart'; // ADDED

class QrScannerUserBorrowScreen extends StatefulWidget {
  const QrScannerUserBorrowScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerUserBorrowScreen> createState() =>
      _QrScannerUserBorrowScreenState();
}

class _QrScannerUserBorrowScreenState extends State<QrScannerUserBorrowScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  String? _scannedBookId;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    // MODIFIED signature
    final barcode = barcodeCapture.barcodes.first; // Get the first barcode
    if (!_isScanned && barcode.rawValue != null) {
      setState(() {
        _isScanned = true;
        _scannedBookId = barcode.rawValue;
        cameraController.stop(); // Hentikan kamera setelah pemindaian berhasil
      });

      _showBorrowConfirmationDialog(context, _scannedBookId!);
    }
  }

  void _showBorrowConfirmationDialog(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Peminjaman'),
        content: FutureBuilder<Object>(
          future: Future.wait([
            Provider.of<BookProvider>(
              context,
              listen: false,
            ).getBookById(bookId),
            Provider.of<LendingProvider>(
              context,
              listen: false,
            ).getActiveBorrowingForBook(bookId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final book = (snapshot.data as List<Object?>)[0] as Book?;
            final activeBorrowing =
                (snapshot.data as List<Object?>)[1] as Borrowing?;

            if (book == null) {
              return const Text('Buku tidak ditemukan.');
            }

            if (activeBorrowing != null) {
              return Text(
                'Buku "${book.title}" sedang dipinjam oleh ${activeBorrowing.userId}. Tidak bisa dipinjam.',
              );
            } else {
              return Text(
                'Anda akan meminjam buku "${book.title}". Lanjutkan?',
              );
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _isScanned = false;
                cameraController.start();
              });
            },
          ),
          ElevatedButton(
            child: const Text('Konfirmasi Peminjaman'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleBorrow(_scannedBookId!);
            },
          ),
        ],
      ),
    ).then((_) {
      if (_isScanned) {
        setState(() {
          _isScanned = false;
          cameraController.start();
        });
      }
    });
  }

  Future<void> _handleBorrow(String bookId) async {
    final lendingProvider = Provider.of<LendingProvider>(
      context,
      listen: false,
    );
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showSnackBar('Anda harus login untuk meminjam buku.', Colors.red);
      return;
    }

    try {
      await lendingProvider.borrowBook(bookId, currentUser.uid);
      _showSnackBar('Buku berhasil dipinjam!', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal meminjam buku: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isScanned = false;
        cameraController.start();
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pindai Kode QR untuk Pinjam Buku')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (_isScanned && _scannedBookId != null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ID Buku Terdeteksi: $_scannedBookId'),
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(),
                        const Text('Memproses peminjaman...'),
                      ],
                    )
                  : const Text(
                      'Arahkan kamera ke kode QR buku untuk meminjam.',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
