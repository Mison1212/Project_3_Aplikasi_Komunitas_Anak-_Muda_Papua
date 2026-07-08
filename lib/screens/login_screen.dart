import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_ui.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final credential = await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = credential.user;
      await user?.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null || !refreshedUser.emailVerified) {
        if (refreshedUser != null) {
          await _auth.sendEmailVerification(refreshedUser);
        }
        await _auth.signOut();
        if (!mounted) return;
        _showMessage(
          'Email belum diverifikasi. Cek inbox email, lalu login kembali.',
        );
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      _showMessage(_loginErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Isi email terlebih dahulu untuk reset kata sandi.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email);
      _showMessage('Link reset kata sandi sudah dikirim ke email.');
    } catch (error) {
      _showMessage(_loginErrorMessage(error));
    }
  }

  String _loginErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'Format email belum valid.',
        'invalid-credential' ||
        'user-not-found' ||
        'wrong-password' =>
          'Login gagal. Periksa email dan kata sandi.',
        'network-request-failed' =>
          'Koneksi ke Firebase gagal. Periksa internet lalu coba lagi.',
        _ => error.message ?? 'Login gagal: ${error.code}.',
      };
    }

    return 'Login gagal. Periksa email dan kata sandi.';
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
                      _LoginHero(),
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: _LoginPanel(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          loading: _loading,
                          onLogin: _login,
                          onResetPassword: _resetPassword,
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

class _LoginHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 22, 30, 76),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFA9D5C8), Color(0xFF86C5B1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppBrandIcon(size: 78, borderRadius: 20),
          const SizedBox(height: 20),
          Text(
            'Hello!',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.onLogin,
    required this.onResetPassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
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
            'Login',
            style: TextStyle(
              color: AppColors.darkTeal,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 24),
          _SoftLoginField(
            controller: emailController,
            hint: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _SoftLoginField(
            controller: passwordController,
            hint: 'Password',
            icon: Icons.lock,
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onResetPassword,
              child: const Text(
                'Forgot Password',
                style: TextStyle(
                  color: AppColors.darkTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5C57),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              child: Text(
                loading ? 'Memproses...' : 'Login',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFF9DB8AF))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Email harus terverifikasi',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFF9DB8AF))),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  "Don't have account? ",
                  style: TextStyle(
                    color: AppColors.titleText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF1986C9),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftLoginField extends StatelessWidget {
  const _SoftLoginField({
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
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9A9A9A)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryTeal, width: 1.3),
        ),
      ),
    );
  }
}
