import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_ui.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  final _api = ApiService();
  List<String> _districts = [];
  List<Map<String, dynamic>> _careerSpecs = [];
  String? _selectedDistrict;
  String? _selectedSkill;
  bool _loading = false;
  bool _loadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      final districts = await _api.getDistricts();
      final careerSpecs = await _api.getCareerSpecs();
      if (!mounted) return;
      setState(() {
        _districts = districts;
        _careerSpecs = careerSpecs;
        _selectedDistrict = districts.isNotEmpty ? districts.first : null;
        _selectedSkill =
            careerSpecs.isNotEmpty ? '${careerSpecs.first['name']}' : null;
      });
    } catch (_) {
      if (mounted) {
        _showMessage('Data kabupaten dan karir belum dapat dimuat.');
      }
    } finally {
      if (mounted) setState(() => _loadingMasterData = false);
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty) {
      _showMessage('Nama lengkap wajib diisi.');
      return;
    }
    if (!email.contains('@')) {
      _showMessage('Email belum valid.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Kata sandi minimal 6 karakter.');
      return;
    }
    if (_selectedDistrict == null || _selectedSkill == null) {
      _showMessage('Pilih kabupaten dan spesifikasi karir terlebih dahulu.');
      return;
    }
    setState(() => _loading = true);
    try {
      final credential = await _auth.register(
        email: email,
        password: password,
      );
      final user = credential.user as User;
      await _auth.sendEmailVerification(user);
      await _api.syncProfile(
        AppUser(
          uid: user.uid,
          email: user.email ?? email,
          name: name,
          district: _selectedDistrict!,
          skill: _selectedSkill!,
        ),
      );
      await _auth.signOut();
      if (!mounted) return;
      _showMessage('Registrasi berhasil. Cek email untuk verifikasi akun.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (error) {
      _showMessage(_registrationErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _registrationErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' =>
          'Email sudah terdaftar. Silakan masuk lewat halaman login.',
        'invalid-email' => 'Format email belum valid.',
        'operation-not-allowed' =>
          'Login Email/Password belum diaktifkan di Firebase.',
        'weak-password' =>
          'Kata sandi terlalu lemah, gunakan minimal 6 karakter.',
        'network-request-failed' =>
          'Koneksi ke Firebase gagal. Periksa internet lalu coba lagi.',
        _ => error.message ?? 'Registrasi Firebase gagal: ${error.code}.',
      };
    }

    return 'Registrasi belum selesai. Pastikan API dan email verifikasi dapat diakses.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F8E67),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                color: const Color(0xFFA9D5C8),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _RegisterHero(onBack: () => Navigator.pop(context)),
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: _RegisterPanel(
                          nameController: _nameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          districts: _districts,
                          careerSpecs: _careerSpecs,
                          selectedDistrict: _selectedDistrict,
                          selectedSkill: _selectedSkill,
                          loading: _loading,
                          loadingMasterData: _loadingMasterData,
                          onDistrictChanged: (value) =>
                              setState(() => _selectedDistrict = value),
                          onSkillChanged: (value) =>
                              setState(() => _selectedSkill = value),
                          onRegister: _register,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHero extends StatelessWidget {
  const _RegisterHero({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 62),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA9D5C8), Color(0xFF86C5B1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const AppBrandIcon(size: 72, borderRadius: 18),
          const SizedBox(height: 16),
          Text(
            'Sign Up',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your career account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.districts,
    required this.careerSpecs,
    required this.selectedDistrict,
    required this.selectedSkill,
    required this.loading,
    required this.loadingMasterData,
    required this.onDistrictChanged,
    required this.onSkillChanged,
    required this.onRegister,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final List<String> districts;
  final List<Map<String, dynamic>> careerSpecs;
  final String? selectedDistrict;
  final String? selectedSkill;
  final bool loading;
  final bool loadingMasterData;
  final ValueChanged<String?> onDistrictChanged;
  final ValueChanged<String?> onSkillChanged;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F2),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buat Akun',
            style: TextStyle(
              color: AppColors.darkTeal,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 22),
          _SoftRegisterField(
            controller: nameController,
            hint: 'Nama lengkap',
            icon: Icons.badge,
          ),
          const SizedBox(height: 14),
          _SoftRegisterField(
            controller: emailController,
            hint: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _SoftRegisterDropdown(
            value: selectedDistrict,
            hint: 'Asal kabupaten',
            icon: Icons.location_city,
            enabled: !loadingMasterData,
            items: districts,
            onChanged: onDistrictChanged,
          ),
          const SizedBox(height: 14),
          _SoftRegisterDropdown(
            value: selectedSkill,
            hint: 'Spesifikasi karir',
            icon: Icons.work,
            enabled: !loadingMasterData,
            items: careerSpecs.map((spec) => '${spec['name']}').toList(),
            onChanged: onSkillChanged,
          ),
          const SizedBox(height: 14),
          _SoftRegisterField(
            controller: passwordController,
            hint: 'Password',
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading || loadingMasterData ? null : onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5C57),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              child: Text(
                loadingMasterData
                    ? 'Memuat data...'
                    : loading
                        ? 'Mengirim verifikasi...'
                        : 'Sign Up',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Link verifikasi akan dikirim ke email kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftRegisterField extends StatelessWidget {
  const _SoftRegisterField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: _registerInputDecoration(hint: hint, icon: icon),
    );
  }
}

class _SoftRegisterDropdown extends StatelessWidget {
  const _SoftRegisterDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.enabled,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final IconData icon;
  final bool enabled;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && items.contains(value);
    return DropdownButtonFormField<String>(
      value: hasValue ? value : null,
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: _registerInputDecoration(hint: hint, icon: icon),
    );
  }
}

InputDecoration _registerInputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xFF9A9A9A)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.3),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}
