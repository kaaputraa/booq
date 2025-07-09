// lib/pages/admin_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booq/pages/login_page.dart';
import 'package:booq/pages/add_book_page.dart';
import 'package:booq/screens/qr_scanner_admin_return_screen.dart';
import 'package:booq/pages/home_page.dart';
import 'package:booq/utils/app_colors.dart'; // Import AppColors
import 'package:booq/utils/app_styles.dart'; // Import AppStyles

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Added padding
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the start
            children: [
              Text(
                "Selamat datang, Admin!",
                style: AppStyles.h2, // Applied AppStyles.h2
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_box),
                label: const Text(
                  "Tambah Buku",
                  style: AppStyles.button,
                ), // Applied AppStyles.button
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary, // Applied AppColors.primary
                  foregroundColor:
                      AppColors.textWhite, // Applied AppColors.textWhite
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: AppStyles.button, // Applied AppStyles.button
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Make button full width
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text(
                  "Lihat Daftar Buku",
                  style: AppStyles.button,
                ), // Applied AppStyles.button
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary, // Applied AppColors.primary
                  foregroundColor:
                      AppColors.textWhite, // Applied AppColors.textWhite
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: AppStyles.button, // Applied AppStyles.button
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Make button full width
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QrScannerAdminReturnScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Pindai Kode QR untuk Pengembalian',
                  style: AppStyles.button,
                ), // Applied AppStyles.button
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary, // Applied AppColors.primary
                  foregroundColor:
                      AppColors.textWhite, // Applied AppColors.textWhite
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, // Adjusted padding for consistency
                    vertical: 12, // Adjusted padding for consistency
                  ),
                  textStyle: AppStyles.button, // Applied AppStyles.button
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Make button full width
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
