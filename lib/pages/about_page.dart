import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50], // Background global
      appBar: AppBar(
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN HEADER (Desain Lengkungan) ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Gradient Curve
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.teal, Color(0xFF004D40)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Logo Aplikasi (Floating)
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: Image.asset(
                        'lib/assets/icons.png',
                        width: 50,
                        height: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 60), // Jarak agar tulisan tidak tertutup logo

            // --- JUDUL APLIKASI ---
            const Text(
              "Saku Cerdas",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Text(
              "Versi 1.0.0",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            // --- INFO TUGAS & KELAS ---
            const Text(
              'Tugas 4',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // Menggunakan styling konsisten tanpa kotak
            _buildInfoText('Fakultas: Teknologi Informasi'),
            _buildInfoText('Prodi: Sistem Informasi'),
            _buildInfoText('Kelas: 5P51'),
            _buildInfoText('Mata Kuliah: Pemrograman Mobile'),

            const SizedBox(height: 30),

            // --- ANGGOTA KELOMPOK ---
            const Text(
              'Anggota Kelompok:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 15),

            // Daftar Nama dan NIM
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Nama
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMemberName('Pradika Satia Putra'),
                    _buildMemberName('Chairul Iman'),
                    _buildMemberName('Muh Faris Khabibi'),
                    _buildMemberName('Al-Muchalif Arnama'),
                  ],
                ),
                const SizedBox(width: 25), // Jarak antara Nama dan NIM
                // Kolom NIM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMemberNim('23.230.0067'),
                    _buildMemberNim('23.230.0091'),
                    _buildMemberNim('23.230.0089'),
                    _buildMemberNim('23.230.0025'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40), // Spasi bawah agar tidak mentok
          ],
        ),
      ),
    );
  }

  // Helper kecil agar text info rapi dan seragam
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper untuk Nama
  Widget _buildMemberName(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper untuk NIM
  Widget _buildMemberNim(String nim) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        nim,
        style: const TextStyle(fontSize: 15, color: Colors.teal),
      ),
    );
  }
}
