import 'package:flutter/material.dart';

void main() => runApp(const TokoLaptopApp());

// ---------------------------------------------------------------------------
// MODEL DATA
// ---------------------------------------------------------------------------
class Laptop {
  final int id;
  final String nama;
  final int harga;
  final double rating;
  final int ulasan;
  final String deskripsi;
  final String gambar;

  const Laptop({
    required this.id,
    required this.nama,
    required this.harga,
    required this.rating,
    required this.ulasan,
    required this.deskripsi,
    required this.gambar,
  });
}

class Pesanan {
  final String nama;
  final Laptop laptop;
  final int jumlah;
  final String metode;

  const Pesanan({
    required this.nama,
    required this.laptop,
    required this.jumlah,
    required this.metode,
  });

  int get total => laptop.harga * jumlah;
}

const List<Laptop> daftarLaptop = [
  Laptop(
    id: 0,
    nama: 'ASUS Vivobook 14',
    harga: 8500000,
    rating: 4.8,
    ulasan: 120,
    deskripsi: 'Laptop ringan dengan performa andal untuk bekerja dan belajar.',
    gambar: 'assets/images/asus.png',
  ),
  Laptop(
    id: 1,
    nama: 'Lenovo IdeaPad Slim 3',
    harga: 7999000,
    rating: 4.6,
    ulasan: 98,
    deskripsi: 'Desain tipis dan baterai awet, cocok untuk mahasiswa.',
    gambar: 'assets/images/lenovo.png',
  ),
  Laptop(
    id: 2,
    nama: 'Acer Aspire 5',
    harga: 7200000,
    rating: 4.5,
    ulasan: 76,
    deskripsi: 'Harga terjangkau dengan layar jernih dan keyboard nyaman.',
    gambar: 'assets/images/acer.png',
  ),
];

String rupiah(int angka) {
  final s = angka.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// ---------------------------------------------------------------------------
// APLIKASI UTAMA (state root menyimpan pilihan font)
// ---------------------------------------------------------------------------
class TokoLaptopApp extends StatefulWidget {
  const TokoLaptopApp({super.key});

  @override
  State<TokoLaptopApp> createState() => _TokoLaptopAppState();
}

class _TokoLaptopAppState extends State<TokoLaptopApp> {
  String _font = 'Poppins';

  static const Color warnaUtama = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Laptop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: _font,
        colorScheme: ColorScheme.fromSeed(seedColor: warnaUtama),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(
        fontSaatIni: _font,
        onFontChanged: (f) => setState(() => _font = f),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOME PAGE: menyimpan state favorit, produk terpilih, dan riwayat
// ---------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  final String fontSaatIni;
  final ValueChanged<String> onFontChanged;

  const HomePage({
    super.key,
    required this.fontSaatIni,
    required this.onFontChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _produkTerpilih = 0;
  final Set<int> _favorit = {};
  final List<Pesanan> _riwayat = [];

  static const Map<String, String> _pilihanFont = {
    'Poppins': 'Poppins (Sans)',
    'Lora': 'Lora (Serif)',
    'DejaVuMono': 'DejaVu Mono',
  };

  void _toggleFavorit(Laptop l) {
    setState(() {
      if (!_favorit.add(l.id)) _favorit.remove(l.id);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(_favorit.contains(l.id)
            ? '${l.nama} ditambahkan ke favorit'
            : '${l.nama} dihapus dari favorit'),
        duration: const Duration(seconds: 1),
      ));
  }

  void _tampilkanHarga(Laptop l) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${l.nama}: ${rupiah(l.harga)}'),
        duration: const Duration(seconds: 2),
      ));
  }

  // Membuka detail dengan transisi slide; menunggu hasil Navigator.pop.
  Future<void> _bukaDetail(Laptop l) async {
    final hasil = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => DetailPage(
          laptop: l,
          favorit: _favorit.contains(l.id),
          onToggleFavorit: () => _toggleFavorit(l),
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: animation.drive(slide), child: child);
        },
      ),
    );
    if (hasil == true) {
      setState(() {
        _produkTerpilih = l.id;
        _tab = 1;
      });
    }
  }

  void _simpanPesanan(Pesanan p) {
    setState(() => _riwayat.insert(0, p));
  }

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      KatalogPage(
        key: const ValueKey('katalog'),
        favorit: _favorit,
        onTap: _bukaDetail,
        onDoubleTap: _toggleFavorit,
        onLongPress: _tampilkanHarga,
      ),
      PesanPage(
        key: const ValueKey('pesan'),
        produkAwal: _produkTerpilih,
        riwayat: _riwayat,
        onProdukChanged: (id) => _produkTerpilih = id,
        onSimpan: _simpanPesanan,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _TokoLaptopAppState.warnaUtama,
        foregroundColor: Colors.white,
        title: Text(
          _tab == 0 ? 'Toko Laptop' : 'Pesan Laptop',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Pilih font',
            icon: const Icon(Icons.text_fields),
            initialValue: widget.fontSaatIni,
            onSelected: widget.onFontChanged, // event handling
            itemBuilder: (_) => _pilihanFont.entries
                .map((e) => PopupMenuItem<String>(
                      value: e.key,
                      child: Text(e.value,
                          style: TextStyle(fontFamily: e.key, fontSize: 15)),
                    ))
                .toList(),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: halaman[_tab],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.laptop_mac_outlined),
            selectedIcon: Icon(Icons.laptop_mac),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Pesan',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1: KATALOG
// ---------------------------------------------------------------------------
class KatalogPage extends StatefulWidget {
  final Set<int> favorit;
  final ValueChanged<Laptop> onTap;
  final ValueChanged<Laptop> onDoubleTap;
  final ValueChanged<Laptop> onLongPress;

  const KatalogPage({
    super.key,
    required this.favorit,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  String _kata = '';

  @override
  Widget build(BuildContext context) {
    final hasil = daftarLaptop
        .where((l) => l.nama.toLowerCase().contains(_kata.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _kata = v),
            decoration: InputDecoration(
              hintText: 'Cari laptop...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F5FA),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tap: detail  •  Double tap: favorit  •  Tahan: harga',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ),
        Expanded(
          child: hasil.isEmpty
              ? const Center(child: Text('Laptop tidak ditemukan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hasil.length,
                  itemBuilder: (_, i) {
                    final l = hasil[i];
                    final fav = widget.favorit.contains(l.id);
                    return GestureDetector(
                      onTap: () => widget.onTap(l),
                      onDoubleTap: () => widget.onDoubleTap(l),
                      onLongPress: () => widget.onLongPress(l),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fav
                              ? const Color(0xFFEEF0FF)
                              : const Color(0xFFF8F8FC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE6E6F0)),
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'laptop-${l.id}',
                              child: Image.asset(l.gambar,
                                  width: 90, height: 64, fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.nama,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(rupiah(l.harga),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4F46E5))),
                                ],
                              ),
                            ),
                            // AnimatedSwitcher: ikon hati berubah dengan animasi
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (c, a) =>
                                  ScaleTransition(scale: a, child: c),
                              child: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                key: ValueKey(fav),
                                color: fav ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HALAMAN DETAIL
// ---------------------------------------------------------------------------
class DetailPage extends StatefulWidget {
  final Laptop laptop;
  final bool favorit;
  final VoidCallback onToggleFavorit;

  const DetailPage({
    super.key,
    required this.laptop,
    required this.favorit,
    required this.onToggleFavorit,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool _fav = widget.favorit;

  @override
  Widget build(BuildContext context) {
    final l = widget.laptop;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              widget.onToggleFavorit();
              setState(() => _fav = !_fav);
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                _fav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(_fav),
                color: _fav ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'laptop-${l.id}',
                child: Image.asset(l.gambar, height: 220, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.nama,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
            const SizedBox(height: 6),
            Text(rupiah(l.harga),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text('${l.rating} (${l.ulasan} ulasan)',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            Text(l.deskripsi,
                style: TextStyle(
                    fontSize: 14, height: 1.5, color: Colors.grey.shade700)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Pesan Sekarang',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: PESAN
// ---------------------------------------------------------------------------
class PesanPage extends StatefulWidget {
  final int produkAwal;
  final List<Pesanan> riwayat;
  final ValueChanged<int> onProdukChanged;
  final ValueChanged<Pesanan> onSimpan;

  const PesanPage({
    super.key,
    required this.produkAwal,
    required this.riwayat,
    required this.onProdukChanged,
    required this.onSimpan,
  });

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  late int _produk = widget.produkAwal;
  int _jumlah = 1;
  String _metode = 'Transfer';

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  void _buatPesanan() {
    if (!_formKey.currentState!.validate()) return;
    final p = Pesanan(
      nama: _namaCtrl.text.trim(),
      laptop: daftarLaptop[_produk],
      jumlah: _jumlah,
      metode: _metode,
    );
    widget.onSimpan(p);
    setState(() {
      _namaCtrl.clear();
      _jumlah = 1;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Pesanan ${p.laptop.nama} berhasil dibuat'),
      ));
  }

  Widget _label(String t, {bool wajib = false}) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text.rich(TextSpan(
          text: t,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          children: [
            if (wajib)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        )),
      );

  @override
  Widget build(BuildContext context) {
    final laptop = daftarLaptop[_produk];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nama Pemesan', wajib: true),
              TextFormField(
                controller: _namaCtrl,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              _label('Produk'),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _produk,
                    items: daftarLaptop
                        .map((l) => DropdownMenuItem<int>(
                              value: l.id,
                              child: Text(l.nama),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _produk = v);
                      widget.onProdukChanged(v);
                    },
                  ),
                ),
              ),
              _label('Jumlah'),
              Row(children: [
                IconButton.outlined(
                  onPressed:
                      _jumlah > 1 ? () => setState(() => _jumlah--) : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 56,
                  child: Text('$_jumlah',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                IconButton.outlined(
                  onPressed:
                      _jumlah < 10 ? () => setState(() => _jumlah++) : null,
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                Text(rupiah(laptop.harga * _jumlah),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5))),
              ]),
              _label('Metode Pembayaran'),
              Row(children: [
                for (final m in const ['Transfer', 'COD'])
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _metode = m),
                      child: Row(children: [
                        Radio<String>(
                          value: m,
                          groupValue: _metode,
                          onChanged: (v) => setState(() => _metode = v!),
                        ),
                        Text(m),
                      ]),
                    ),
                  ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _buatPesanan,
                  child: const Text('Buat Pesanan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          title: Text('Riwayat Pesanan (${widget.riwayat.length})',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: widget.riwayat.isNotEmpty,
          children: widget.riwayat.isEmpty
              ? const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Belum ada pesanan'),
                  )
                ]
              : widget.riwayat
                  .map((p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.asset(p.laptop.gambar, width: 56),
                        title: Text(p.laptop.nama),
                        subtitle: Text(
                            '${p.nama} • ${p.jumlah} unit • ${p.metode}'),
                        trailing: Text(rupiah(p.total),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ))
                  .toList(),
        ),
      ],
    );
  }
}
