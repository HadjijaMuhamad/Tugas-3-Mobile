import 'dart:async';

//Custom Exception 
class StokHabisException implements Exception {
  final String message;
  StokHabisException(this.message);
  String toString() => "StokHabisException: $message";
}

class ProdukTidakAda implements Exception {
  final String message;
  ProdukTidakAda(this.message);
  String toString() =>  "ProdukTidakAda: $message";
}

//Mixin
mixin BisaDiskon {
  double get harga;

  bool validasiDiskon(double p) {
    if (p < 0 || p > 100) throw ArgumentError("Diskon 0-100%");
    return true;
  }

  double hitungHargaDiskon(double p) {
    validasiDiskon(p);
    return harga - harga * p / 100;
  }
}

// Abstract Class
abstract class Produk {
  String id, nama;
  double harga;
  int stok;

  Produk(this.id, this.nama, this.harga, this.stok);
  void  deskripsi();
}

// Produk Digital
class ProdukDigital extends Produk with BisaDiskon {
  double ukuranMB;
  String formatFile;

  ProdukDigital(super.id, super.nama, super.harga, super.stok,
      this.ukuranMB, this.formatFile);

    @override
    void deskripsi() =>
      print("[Digital] $nama | Rp$harga |Stok:$stok |${ukuranMB}MB | $formatFile");
}

//Produk Fisik
class ProdukFisik extends Produk with BisaDiskon {
  double beratGram;
  String dimensi;

  ProdukFisik(super.id, super.nama, super.harga, super.stok,
      this.beratGram, this.dimensi);

  @override
  void deskripsi() =>
      print("[fisik] $nama | Rp$harga | Stok:$stok | ${beratGram}g |$dimensi");
}

//Keranjang 
class Keranjang {
  final List<Produk> items = [];

  void tambah(Produk p) {
    if (p.stok <= 0) throw StokHabisException("Stok '${p.nama}' habis!");
    items.add(p);
    p.stok--;
    print ("✔ ${p.nama} ditambahkan.");
  }

  void hapus(Produk p) {
    if (!items.remove(p)) {
      throw ProdukTidakAda("${p.nama} tidak ada di keranjang!");
    }
    p.stok++;
    print ("✔ ${p.nama} dihapus.");
  }

  double totalHarga()  => items.fold(0, (t,p) => t + p.harga);
}

//Toko Service
class TokoService {
  final List<Produk> inventaris;
  TokoService(this.inventaris);

  Future<Produk> cariProduk(String nama) async {
    print("Mencari  '$nama'...");
    await Future.delayed(const Duration(seconds : 1));

    for (var p in inventaris) {
      if (p.nama.toLowerCase() == nama.toLowerCase()) return p;
    }
    throw ProdukTidakAda("Produk '$nama' tidak ditemukan!");
  }
  
  Future<void> ProsesCheckout(Keranjang k) async {
    print("\nMemproses checkout...");
    await Future.delayed(const Duration(seconds: 1));

    if (k.items.isEmpty) throw Exception ("Keranjang kosong!");

   print("\n === CHECKOUT ===");
   for (var p in k.items) {
    print("- ${p.nama}: Rp${p.harga}");
   }
   print("Total Bayar: Rp${k.totalHarga()}");
   print("✔ checkout berhasil!");
   k.items.clear();
  }
}

// Main
void main() async {
  var ebook =
     ProdukDigital("D01","Modul Dart Expert", 50000, 2, 15.5, "PDF");
  var kaos =
     ProdukFisik("F01", "kaos flutter", 120000, 0, 250, "30x20 cm");
  
  var toko = TokoService([ebook, kaos]);
  var keranjang = Keranjang();

  print("=== DAFTAR PRODUK ===");
  ebook.deskripsi();
  kaos.deskripsi();
  
  try{
    print("\nDiskon 10%: Rp${ebook.hitungHargaDiskon(10)}");
  } catch (e) {
    print("Error: $e");
  }

  try {
    keranjang.tambah(kaos);
  } catch (e) {
    print("Error: $e");
  }

  try {
    await toko.cariProduk("Kamera");
  } catch (e) {
    print("Error: $e");
  }

  try {
    keranjang.hapus(kaos);
  } catch (e) {
    print("Error: $e");
  }

  try {
    var p = await toko.cariProduk("Modul Dart Expert");
    keranjang.tambah(p);
    await toko.ProsesCheckout(keranjang);
  } catch (e) {
    print("Error: $e");
  }
}