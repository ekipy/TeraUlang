import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tera_model.dart';
import '../../services/firestore_service.dart';
import '../utils/formatters.dart';

class TeraUlangScreen extends StatefulWidget {
  const TeraUlangScreen({super.key});

  @override
  State<TeraUlangScreen> createState() => _TeraUlangScreenState();
}

class _TeraUlangScreenState extends State<TeraUlangScreen> {
  final _form = GlobalKey<FormState>();
  final _svc = FirestoreService();

  // Controllers
  final _nama = TextEditingController();
  final _hp = TextEditingController();
  final _kapasitas = TextEditingController();
  final _anak = TextEditingController();
  final _biaya = TextEditingController();

  String? _pasar;
  String? _kecamatan;
  String? _jenis;
  String? _satuan;
  DateTime? _tanggal;

  // Dropdown Options
  final _pasarOptions = const [
    'Pasar Kanoman',
    'Pasar Kramat',
    'Pasar Pagi',
    'Pasar Drajat',
    'Pasar Kesambi',
    'Pasar Harjamukti',
  ];
  final _kecamatanOptions = const [
    'Harjamukti',
    'Kejaksan',
    'Kesambi',
    'Lemahwungkuk',
    'Pekalipan',
  ];
  final _jenisOptions = const [
    'Timbangan Meja',
    'Timbangan Gantung',
    'Timbangan Duduk',
    'Timbangan Digital',
  ];

  bool get _kapasitasTerisi => _kapasitas.text.trim().isNotEmpty;

  // Format rupiah lokal (kalau sudah ada di utils, bisa pakai itu)
  final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // (Opsional) status online untuk header
  final bool isOnline = true;

  @override
  void initState() {
    super.initState();
    _kapasitas.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nama.dispose();
    _hp.dispose();
    _kapasitas.dispose();
    _anak.dispose();
    _biaya.dispose();
    super.dispose();
  }

  /// Input builder
  Widget _buildInputField({
    TextEditingController? controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF7CD38), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF7CD38), width: 2),
        ),
      ),
    );
  }

  /// Dropdown builder
  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value, // <- perbaikan: gunakan value, bukan initialValue
      isExpanded: true,
      dropdownColor: const Color(0xFF0083B0),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF7CD38), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF7CD38), width: 2),
        ),
      ),
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
    );
  }

  /// Date picker
  Future<void> _pickDate() async {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(DateTime.now().year - 100),
      maxTime: DateTime(DateTime.now().year + 100),
      currentTime: _tanggal ?? DateTime.now(),
      locale: picker.LocaleType.id,
      theme: picker.DatePickerTheme(
        backgroundColor: Colors.white,
        itemStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        doneStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        cancelStyle: const TextStyle(color: Colors.grey),
      ),
      onConfirm: (date) => setState(() => _tanggal = date),
    );
  }

  /// Submit handler
  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _tanggal == null) {
      _showSnack('Lengkapi semua field', Colors.red);
      return;
    }

    final biayaValue =
        int.tryParse(_biaya.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final data = Tera(
      id: 'temp',
      namaPemilik: _nama.text.trim(),
      alamatPasar: _pasar!,
      kecamatan: _kecamatan!,
      noHp: _hp.text.trim(),
      jenisTimbangan: _jenis!,
      kapasitas: _kapasitas.text.trim(),
      satuan: _kapasitasTerisi ? _satuan : null,
      anakTimbangan: int.parse(_anak.text.trim()),
      biaya: biayaValue,
      tanggalTera: _tanggal!,
      createdAt: DateTime.now(),
    );

    try {
      await _svc.create(data);
      if (mounted) {
        _showSnack('Data tersimpan', Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Gagal: $e', Colors.red);
    }
  }

  /// Snackbar utility
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final headerH = size.height * 0.18;

    return Scaffold(
      body: Stack(
        children: [
          /// HEADER
          Container(
            height: headerH,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(247, 205, 56, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 20 : 12,
                ),
                child: Row(
                  children: [
                    // Tombol back
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),

                    // Info User
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? "User",
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: isTablet ? 14 : 10,
                                color: isOnline
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? "Online" : "Offline",
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 14 : 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Avatar
                    CircleAvatar(
                      radius: isTablet ? 30 : 24,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade800,
                        size: isTablet ? 40 : 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),

          /// BODY (form) dengan rounded top & background image
          Container(
            margin: EdgeInsets.only(top: headerH - 16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nama Pemilik
                    _buildInputField(
                      controller: _nama,
                      hint: 'Nama Pemilik UTTP',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),

                    // Pasar
                    _buildDropdownField(
                      hint: 'Pilih Alamat',
                      value: _pasar,
                      items: _pasarOptions,
                      onChanged: (v) => setState(() => _pasar = v),
                    ),
                    const SizedBox(height: 15),

                    // Kecamatan
                    _buildDropdownField(
                      hint: 'Pilih Kecamatan',
                      value: _kecamatan,
                      items: _kecamatanOptions,
                      onChanged: (v) => setState(() => _kecamatan = v),
                    ),
                    const SizedBox(height: 15),

                    // Nomor HP
                    _buildInputField(
                      controller: _hp,
                      hint: 'Nomor HP',
                      keyboardType: TextInputType.number,
                      inputFormatters: [DigitsOnlyFormatter()],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),

                    // Jenis Timbangan
                    _buildDropdownField(
                      hint: 'Pilih Timbangan',
                      value: _jenis,
                      items: _jenisOptions,
                      onChanged: (v) => setState(() => _jenis = v),
                    ),
                    const SizedBox(height: 15),

                    // Kapasitas dan Satuan
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _kapasitas,
                            hint: 'Kapasitas',
                            keyboardType: TextInputType.number,
                            inputFormatters: [DigitsOnlyFormatter()],
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kapasitasTerisi
                              ? _buildDropdownField(
                                  hint: 'Satuan',
                                  value: _satuan,
                                  items: const ['Kilogram', 'Gram'],
                                  onChanged: (v) => setState(() => _satuan = v),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Anak Timbangan
                    _buildInputField(
                      controller: _anak,
                      hint: 'Anak Timbangan',
                      keyboardType: TextInputType.number,
                      inputFormatters: [DigitsOnlyFormatter()],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),

                    // Biaya dengan Rupiah format
                    _buildInputField(
                      controller: _biaya,
                      hint: 'Biaya',
                      keyboardType: TextInputType.number,
                      // Hindari formatter yang hanya digit karena kita menulis "Rp " & titik secara programatik
                      onChanged: (value) {
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        final number = int.tryParse(digits) ?? 0;
                        final formatted = _rupiah.format(number);
                        // Update controller agar caret selalu di akhir
                        _biaya.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      },
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),

                    // Tanggal
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildInputField(
                          hint: _tanggal == null
                              ? 'Pilih Tanggal'
                              : DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(_tanggal!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7CD38),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
