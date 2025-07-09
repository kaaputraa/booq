import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'pages/login_page.dart';
import 'pages/admin_page.dart';
import 'screens/home_screen.dart'; // Import HomeScreen yang sudah ada
import 'screens/saved_list_screen.dart'; // Import SavedListScreen yang sudah ada
import 'providers/book_provider.dart';
import 'providers/lending_provider.dart';
import 'firebase_options.dart'; // Penting: Import firebase_options.dart

// Import screen scanner yang baru dibuat untuk pengguna
import 'screens/qr_scanner_user_borrow_screen.dart'; // Perbaikan path
// Import screen untuk melihat buku yang dipinjam oleh pengguna (opsional)
import 'screens/user_borrowed_books_screen.dart'; // Perbaikan path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Perbaikan di sini
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => LendingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getInitialPage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = snapshot.data();
    if (data == null || !data.containsKey('role')) {
      return const LoginPage();
    }

    if (data['role'] == 'admin') {
      return const AdminPage();
    } else {
      return const MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Terjadi kesalahan saat memuat: ${snapshot.error}"),
            ),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkUserRole().then((_) {
      // Inisialisasi _pages setelah _isAdmin diketahui
      _pages = [
        const HomeScreen(), // Menggunakan HomeScreen yang sudah ada
        const SavedListScreen(), // Menggunakan SavedListScreen (asumsi daftar buku)
        const QrScannerUserBorrowScreen(), // Halaman scanner QR untuk pengguna
        const UserBorrowedBooksScreen(), // Halaman buku pinjaman pengguna
        const Center(
          child: Text('Profil Pengguna'),
        ), // Placeholder untuk Profil
      ];
      setState(() {});
    });
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        _isAdmin = true;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan _pages sudah diinisialisasi sebelum digunakan
    if (_pages == null || _pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan Booq'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Mengarahkan ke halaman login setelah logout
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar:
          !_isAdmin // Hanya tampilkan BottomNavigationBar jika bukan admin
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner), // Ikon scanner
                  label: 'Pinjam',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book), // Ikon buku pinjaman
                  label: 'Pinjaman Saya',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor:
                  Colors.grey, // Tambahkan ini agar ikon tidak aktif terlihat
              onTap: _onItemTapped,
              type: BottomNavigationBarType
                  .fixed, // Penting jika item lebih dari 3
            )
          : null, // Jika admin, tidak tampilkan BottomNavigationBar ini
    );
  }
}
