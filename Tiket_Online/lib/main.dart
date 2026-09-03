import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const App());

// ===================== OOP =====================

// ABSTRACT CLASS
abstract class Tiket {
  String nama;
  double harga;

  Tiket(this.nama, this.harga);

  String deskripsi();
}

// SUBCLASS 1
class TiketEkonomi extends Tiket {
  TiketEkonomi(super.nama, super.harga);

  @override
  String deskripsi() => 'Ekonomi - Bagasi 20 kg';
}

// MIXIN
mixin BisaDiskon on Tiket {
  double hitungHargaDiskon(double persen) {
    return harga - (harga * persen / 100);
  }
}

// SUBCLASS 2
class TiketVIP extends Tiket with BisaDiskon {
  TiketVIP(super.nama, super.harga);

  @override
  String deskripsi() => 'VIP - Bagasi 30 kg';
}

// CUSTOM EXCEPTION
class TiketHabisException implements Exception {
  final String pesan;

  TiketHabisException(this.pesan);

  @override
  String toString() => pesan;
}

// ===================== DATA =====================

Future<List<Tiket>> ambilDaftarTiket() async {
  await Future.delayed(const Duration(seconds: 2));

  return [
    TiketEkonomi('Jakarta (CGK) → Bali (DPS)', 950000),
    TiketVIP('Jakarta (CGK) → Bali (DPS)', 1700000),
    TiketEkonomi('Surabaya (SUB) → Jakarta (CGK)', 650000),
    TiketEkonomi('Medan (KNO) → Jakarta (CGK)', 700000),
    TiketVIP('Bandung (BDO) → Bali (DPS)', 1800000),
  ];
}

// DATA PESANAN
class DataPesanan {
  static String? kode;
  static String? nama;
  static String? kursi;
  static Tiket? tiket;
  static double? harga;
}

// ===================== APP =====================

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TIKETKU',
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: const Beranda(),
    );
  }
}

// ===================== 1. BERANDA =====================

class Beranda extends StatelessWidget {
  const Beranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0d47a1), Color(0xff42a5f5), Color(0xffe3f2fd)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              const Icon(Icons.flight_takeoff, size: 100, color: Colors.white),

              const SizedBox(height: 20),

              const Text(
                'TIKETKU',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Pesan Tiket, Mudah & Cepat',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(25),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DaftarTiket()),
                      );
                    },
                    child: const Text('Mulai Pesan Tiket'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 2. DAFTAR TIKET =====================

class DaftarTiket extends StatefulWidget {
  const DaftarTiket({super.key});

  @override
  State<DaftarTiket> createState() => _DaftarTiketState();
}

class _DaftarTiketState extends State<DaftarTiket> {
  late Future<List<Tiket>> futureTiket;

  @override
  void initState() {
    super.initState();
    futureTiket = ambilDaftarTiket();
  }

  void ulangi() {
    setState(() {
      futureTiket = ambilDaftarTiket();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        actions: [
          IconButton(onPressed: ulangi, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: FutureBuilder<List<Tiket>>(
        future: futureTiket,
        builder: (context, snapshot) {
          // 7. LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPage();
          }

          // 8. ERROR
          if (snapshot.hasError) {
            return ErrorPage(onRetry: ulangi);
          }

          // DATA
          if (snapshot.hasData) {
            final daftar = snapshot.data!;

            return ListView.builder(
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final tiket = daftar[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Icon(
                      tiket is TiketVIP ? Icons.star : Icons.flight,
                      color: tiket is TiketVIP ? Colors.orange : Colors.blue,
                      size: 35,
                    ),

                    title: Text(
                      tiket.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(tiket.deskripsi()),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rp ${tiket.harga.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(tiket is TiketVIP ? 'VIP' : 'Ekonomi'),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailTiket(tiket: tiket),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Tidak ada tiket'));
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tiket Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],

        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TiketSaya()),
            );
          }
        },
      ),
    );
  }
}

// ===================== 3. DETAIL =====================

class DetailTiket extends StatelessWidget {
  final Tiket tiket;

  const DetailTiket({super.key, required this.tiket});

  @override
  Widget build(BuildContext context) {
    double hargaAkhir = tiket.harga;

    if (tiket is TiketVIP) {
      hargaAkhir = (tiket as TiketVIP).hitungHargaDiskon(20);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tiket.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    '25 Mei 2026 • 08:00',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child: const Text('Ekonomi'),
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    color: tiket is TiketVIP
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                    child: Text(
                      'VIP',
                      style: TextStyle(
                        color: tiket is TiketVIP ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (tiket is TiketVIP)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.shade100,
                child: const Text(
                  'DISKON 20% (Mixin BisaDiskon)',
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 15),

            info('Harga Awal', 'Rp ${tiket.harga.toStringAsFixed(0)}'),

            info('Diskon', tiket is TiketVIP ? '20%' : '-'),

            info('Harga Setelah Diskon', 'Rp ${hargaAkhir.toStringAsFixed(0)}'),

            info('Kelas', tiket is TiketVIP ? 'VIP' : 'Ekonomi'),

            info('Bagasi', tiket is TiketVIP ? '30 kg' : '20 kg'),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FormPemesanan(tiket: tiket, harga: hargaAkhir),
                    ),
                  );
                },
                child: const Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String kiri, String kanan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(kiri),
          Text(kanan, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ===================== 4. FORM PEMESANAN =====================

class FormPemesanan extends StatefulWidget {
  final Tiket tiket;
  final double harga;

  const FormPemesanan({super.key, required this.tiket, required this.harga});

  @override
  State<FormPemesanan> createState() => _FormPemesananState();
}

class _FormPemesananState extends State<FormPemesanan> {
  final nama = TextEditingController();
  final email = TextEditingController();
  final telepon = TextEditingController();

  int jumlah = 1;

  @override
  void dispose() {
    nama.dispose();
    email.dispose();
    telepon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Penumpang')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: telepon,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No Telepon',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jumlah Penumpang'),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (jumlah > 1) {
                          setState(() => jumlah--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),

                    Text('$jumlah'),

                    IconButton(
                      onPressed: () {
                        setState(() => jumlah++);
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(widget.tiket.nama),

                  const SizedBox(height: 5),

                  Text(
                    'Total: Rp ${(widget.harga * jumlah).toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nama.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama harus diisi')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PilihKursi(
                        tiket: widget.tiket,
                        nama: nama.text,
                        harga: widget.harga * jumlah,
                      ),
                    ),
                  );
                },
                child: const Text('Pilih Kursi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== 5. PILIH KURSI =====================

class PilihKursi extends StatefulWidget {
  final Tiket tiket;
  final String nama;
  final double harga;

  const PilihKursi({
    super.key,
    required this.tiket,
    required this.nama,
    required this.harga,
  });

  @override
  State<PilihKursi> createState() => _PilihKursiState();
}

class _PilihKursiState extends State<PilihKursi> {
  String kursi = '4D';

  @override
  Widget build(BuildContext context) {
    List<String> daftar = [];

    for (int i = 1; i <= 8; i++) {
      for (String huruf in ['A', 'B', 'C', 'D', 'E', 'F']) {
        daftar.add('$i$huruf');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kursi')),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('🟩 Tersedia'),
                Text('🟦 Terpilih'),
                Text('⬜ Terisi'),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: daftar.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemBuilder: (context, index) {
                String item = daftar[index];

                bool dipilih = item == kursi;

                bool terisi = item == '6A' || item == '7B' || item == '8C';

                return InkWell(
                  onTap: terisi
                      ? null
                      : () {
                          setState(() {
                            kursi = item;
                          });
                        },

                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: terisi
                          ? Colors.grey.shade300
                          : dipilih
                          ? Colors.blue
                          : Colors.green.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: Text(
                      item,
                      style: TextStyle(
                        color: dipilih ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kursi Terpilih\n$kursi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Pembayaran(
                            tiket: widget.tiket,
                            nama: widget.nama,
                            kursi: kursi,
                            harga: widget.harga,
                          ),
                        ),
                      );
                    },
                    child: const Text('Konfirmasi Kursi'),
                  ),
                ),

                const SizedBox(height: 5),

                const Text('🔒 Transaksi aman & terenkripsi'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 6. PEMBAYARAN =====================

class Pembayaran extends StatefulWidget {
  final Tiket tiket;
  final String nama;
  final String kursi;
  final double harga;

  const Pembayaran({
    super.key,
    required this.tiket,
    required this.nama,
    required this.kursi,
    required this.harga,
  });

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  // FUTURE PESAN TIKET
  Future<String> pesanTiket(Tiket tiket) async {
    await Future.delayed(const Duration(seconds: 2));

    // KEGAGALAN ACAK
    if (Random().nextInt(4) == 0) {
      throw TiketHabisException(
        'Tiket sudah habis atau terjadi kesalahan saat pemesanan.',
      );
    }

    return 'TKX25M${1000 + Random().nextInt(8999)}';
  }

  Future<void> prosesPesanan() async {
    // TRY
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Memproses...'),
              ],
            ),
          ),
        ),
      );

      String kode = await pesanTiket(widget.tiket);

      if (!mounted) return;

      Navigator.pop(context);

      // SIMPAN DATA
      DataPesanan.kode = kode;
      DataPesanan.nama = widget.nama;
      DataPesanan.kursi = widget.kursi;
      DataPesanan.tiket = widget.tiket;
      DataPesanan.harga = widget.harga;

      // SUKSES
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SuksesPage(kode: kode)),
      );

      // CATCH CUSTOM EXCEPTION
    } on TiketHabisException catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ErrorPemesanan(pesan: e.toString())),
      );

      // CATCH ERROR LAIN
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ErrorPemesanan(pesan: 'Terjadi kesalahan.'),
        ),
      );

      // FINALLY
    } finally {
      debugPrint('Proses pemesanan selesai');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.credit_card, size: 100, color: Colors.blue),

            const SizedBox(height: 25),

            Text(
              widget.tiket.nama,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Text('Penumpang: ${widget.nama}'),
            Text('Kursi: ${widget.kursi}'),

            const SizedBox(height: 20),

            Text(
              'Total: Rp ${widget.harga.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: prosesPesanan,
                child: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== 7. LOADING =====================

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight, size: 100, color: Colors.blue),

          SizedBox(height: 25),

          Text(
            'Memuat Data Tiket',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          Text('Mohon tunggu sebentar...'),

          SizedBox(height: 25),

          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

// ===================== 8. ERROR LOADING =====================

class ErrorPage extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 100),

          const SizedBox(height: 20),

          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text('Periksa koneksi internet Anda.'),

          const SizedBox(height: 25),

          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

// ===================== 9. ERROR PEMESANAN =====================

class ErrorPemesanan extends StatelessWidget {
  final String pesan;

  const ErrorPemesanan({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, size: 100, color: Colors.red),

              const SizedBox(height: 20),

              const Text(
                'Pemesanan Gagal!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(pesan, textAlign: TextAlign.center),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 10. SUKSES =====================

class SuksesPage extends StatelessWidget {
  final String kode;

  const SuksesPage({super.key, required this.kode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),

              const SizedBox(height: 20),

              const Text(
                'Pemesanan Berhasil!',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              const Text('Kode Booking Anda'),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text('E-ticket telah dikirim'),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ETicket()),
                    );
                  },
                  child: const Text('Lihat E-Ticket'),
                ),
              ),

              OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 11. TIKET SAYA =====================

class TiketSaya extends StatelessWidget {
  const TiketSaya({super.key});

  @override
  Widget build(BuildContext context) {
    bool ada = DataPesanan.tiket != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Tiket Saya')),

      body: !ada
          ? const Center(child: Text('Belum ada tiket'))
          : ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Text(
                  'Mendatang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    title: Text(DataPesanan.tiket!.nama),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        const Text('25 Mei 2026 • 08:00'),
                        Text('Kode: ${DataPesanan.kode}'),
                        Text('Kursi: ${DataPesanan.kursi}'),
                      ],
                    ),

                    trailing: const Icon(
                      Icons.airplane_ticket,
                      color: Colors.blue,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ETicket()),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ===================== 12. E-TICKET =====================

class ETicket extends StatelessWidget {
  const ETicket({super.key});

  @override
  Widget build(BuildContext context) {
    final tiket = DataPesanan.tiket;

    return Scaffold(
      appBar: AppBar(title: const Text('E-Ticket')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kode Booking',
                        style: TextStyle(color: Colors.white),
                      ),

                      Text(
                        DataPesanan.kode ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  tiket?.nama ?? 'Jakarta → Bali',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                const Text('25 Mei 2026 • 08:00'),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Penumpang'),
                    Text(DataPesanan.nama ?? '-'),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kursi'),
                    Text(DataPesanan.kursi ?? '-'),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kelas'),
                    Text(tiket is TiketVIP ? 'VIP' : 'Ekonomi'),
                  ],
                ),

                const SizedBox(height: 30),

                const Icon(Icons.qr_code_2, size: 150),

                const SizedBox(height: 10),

                const Text(
                  'Tunjukkan kode QR ini saat check-in',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== 13. BONUS PROMO =====================

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  // STREAM
  Stream<int> countdown() async* {
    for (int i = 60; i >= 0; i--) {
      yield i;

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo Spesial')),

      body: StreamBuilder<int>(
        stream: countdown(),

        builder: (context, snapshot) {
          int waktu = snapshot.data ?? 60;

          int menit = waktu ~/ 60;
          int detik = waktu % 60;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer, color: Colors.orange, size: 90),

                const SizedBox(height: 20),

                const Text(
                  'Promo Spesial!',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text('Diskon 20% untuk semua rute VIP'),

                const SizedBox(height: 35),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Text(
                    '${menit.toString().padLeft(2, '0')} : '
                    '${detik.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Waktu tersisa untuk memesan tiket promo',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
