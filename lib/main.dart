import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegisterPage(),
  ));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String gender = "Laki-laki";

  Uint8List? _imageBytes;
  XFile? _pickedFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _pickedFile = pickedFile;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
          _imageBytes = null;
        });
      }
    }
  }

  Future<void> _register() async {
    final uri = Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['nama_nasabah'] = namaController.text;
    request.fields['gender'] = gender;
    request.fields['alamat'] = alamatController.text;
    request.fields['telepon'] = teleponController.text;
    request.fields['username'] = usernameController.text;
    request.fields['password'] = passwordController.text;

    if (_pickedFile != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          await _pickedFile!.readAsBytes(),
          filename: _pickedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('foto', _pickedFile!.path));
      }
    }

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var data = jsonDecode(respStr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Berhasil Register')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Register: $respStr')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color.fromARGB(255, 235, 107, 207);
    const Color lightPurple = Color.fromARGB(255, 158, 187, 250);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 247, 150, 223), Color.fromARGB(255, 170, 196, 240)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(Icons.person_add_alt, size: 60, color: Colors.white),
                        const SizedBox(height: 12),
                        const Text(
                          "Buat Akun Baru",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildField(namaController, "Nama", Icons.person),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki',)),
                            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                          ],
                          onChanged: (value) => setState(() => gender = value!),
                          dropdownColor: lightPurple,
                          decoration: _inputDecoration("Gender", Icons.wc),
                        ),
                        const SizedBox(height: 12),
                        _buildField(alamatController, "Alamat", Icons.home),
                        const SizedBox(height: 12),
                        _buildField(teleponController, "Telepon", Icons.phone, keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        _buildField(usernameController, "Username", Icons.account_circle),
                        const SizedBox(height: 12),
                        _buildField(passwordController, "Password", Icons.lock, obscureText: true),
                        const SizedBox(height: 16),
                        if (_imageBytes != null || _pickedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, height: 100)
                                : Image.file(File(_pickedFile!.path), height: 100),
                          ),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_camera, color: Colors.white),
                          label: const Text("Pilih Foto", style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) _register();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}