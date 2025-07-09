import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/lending_provider.dart';
import '../providers/book_provider.dart'; // Untuk mendapatkan detail buku
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan user admin saat ini

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  String? _scannedBookId;
  String? _actionType; // 'borrow' atau 'return'

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(Barcode barcode, MobileScannerArguments? args) async {
    if (!_isScanned && barcode.rawValue != null) {
      setState(() {
        _isScanned = true;
        _scannedBookId = barcode.rawValue;
        cameraController.stop(); // Hentikan kamera setelah pemindaian berhasil
      });

      // Lanjutkan dengan logika peminjaman/pengembalian
      _showBorrowReturnDialog(context, _scannedBookId!);
    }
  }

  void _showBorrowReturnDialog(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Aksi'),
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

            String actionText;
            if (activeBorrowing != null) {
              _actionType = 'return';
              actionText =
                  'Anda akan mengembalikan buku "${book.title}" (dipinjam oleh ${activeBorrowing.userId}). Lanjutkan?';
            } else {
              _actionType = 'borrow';
              actionText =
                  'Anda akan meminjamkan buku "${book.title}". Lanjutkan?';
            }

            return Text(actionText);
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _isScanned = false; // Reset status untuk scan lagi
                cameraController.start(); // Mulai kamera lagi
              });
            },
          ),
          ElevatedButton(
            child: const Text('Konfirmasi'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (_actionType == 'borrow') {
                await _handleBorrow(bookId);
              } else if (_actionType == 'return') {
                await _handleReturn(bookId);
              }
            },
          ),
        ],
      ),
    ).then((_) {
      // Pastikan kamera dihentikan jika dialog ditutup tanpa aksi
      if (_isScanned) {
        // Hanya reset jika sebelumnya sudah berhasil scan
        setState(() {
          _isScanned = false;
          cameraController.start(); // Mulai kamera lagi setelah dialog ditutup
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
      _showSnackBar('Anda harus login sebagai admin.', Colors.red);
      return;
    }

    try {
      // Di sini Anda mungkin ingin admin memilih user yang meminjam
      // Untuk contoh ini, kita asumsikan ID user admin adalah peminjamnya (ini tidak realistis untuk perpustakaan)
      // Idealnya, admin akan mencari atau memilih user lain.
      // String borrowerUserId = /* Logika untuk mendapatkan ID user peminjam */;
      // Untuk demo, kita pakai ID admin sendiri, ganti dengan logika pemilihan user sebenarnya.
      String borrowerUserId =
          'dummy_borrower_id'; // GANTI INI DENGAN LOGIKA SELEKSI USER

      await lendingProvider.borrowBook(bookId, borrowerUserId);
      _showSnackBar('Buku berhasil dipinjamkan!', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal meminjamkan buku: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isScanned = false;
        cameraController.start();
      });
    }
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
      appBar: AppBar(title: const Text('Scan Kode QR Buku')),
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
                        const CircularProgressIndicator(), // Menunjukkan proses
                        const Text('Memproses...'),
                      ],
                    )
                  : const Text('Arahkan kamera ke kode QR buku.'),
            ),
          ),
        ],
      ),
    );
  }
}
