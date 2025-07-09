import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/lending_provider.dart';
import '../providers/book_provider.dart';
import '../models/borrowing.dart';
import '../models/book.dart'; // ADDED

class QrScannerAdminReturnScreen extends StatefulWidget {
  const QrScannerAdminReturnScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerAdminReturnScreen> createState() =>
      _QrScannerAdminReturnScreenState();
}

class _QrScannerAdminReturnScreenState
    extends State<QrScannerAdminReturnScreen> {
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
        cameraController.stop();
      });

      _showReturnConfirmationDialog(context, _scannedBookId!);
    }
  }

  void _showReturnConfirmationDialog(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengembalian'),
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
                'Anda akan mengembalikan buku "${book.title}" yang dipinjam oleh ${activeBorrowing.userId}. Lanjutkan?',
              );
            } else {
              return Text('Buku "${book.title}" tidak sedang dipinjam.');
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
            child: const Text('Konfirmasi Pengembalian'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleReturn(_scannedBookId!);
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

  Future<void> _handleReturn(String bookId) async {
    final lendingProvider = Provider.of<LendingProvider>(
      context,
      listen: false,
    );
    try {
      final activeBorrowing = await lendingProvider.getActiveBorrowingForBook(
        bookId,
      );
      if (activeBorrowing != null) {
        await lendingProvider.returnBook(activeBorrowing.id);
        _showSnackBar('Buku berhasil dikembalikan!', Colors.green);
      } else {
        _showSnackBar('Buku ini tidak sedang dipinjam.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Gagal mengembalikan buku: ${e.toString()}', Colors.red);
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
      appBar: AppBar(title: const Text('Pindai Kode QR untuk Pengembalian')),
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
                        const Text('Memproses pengembalian...'),
                      ],
                    )
                  : const Text(
                      'Arahkan kamera ke kode QR buku untuk pengembalian.',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
