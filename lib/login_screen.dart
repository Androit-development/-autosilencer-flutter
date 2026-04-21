import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading       = false;
  bool isGoogleLoading = false;
  bool showPassword    = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ── Email + Password sign in ──────────────────────────────────────
  Future<void> login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields', isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Login successful - navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Login failed. Check your connection.', isError: true);
    }
    if (mounted) setState(() => isLoading = false);
  }

  // ── Google sign in ─────────────────────────────────────────────────
  // FIX: was calling signInWithOAuth but not handling the redirect correctly
  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // After browser redirects back and login is successful, navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Google sign in failed. Try again.', isError: true);
    }
    if (mounted) setState(() => isGoogleLoading = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  // ── UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1a1a2e), Color(0xFF16213e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2979FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2979FF).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.directions_car,
                            size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'AUTO SILENCER',
                        style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold,
                          color: Colors.white, letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Drive Safe. Stay Focused.',
                        style: TextStyle(
                            fontSize: 14, color: Colors.white38, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                const Text('Welcome Back',
                    style: TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                const Text('Sign in to continue',
                    style: TextStyle(fontSize: 14, color: Colors.white38)),
                const SizedBox(height: 30),

                // Email field
                _DarkField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                _DarkField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: !showPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: Color(0xFF2979FF))),
                  ),
                ),

                const SizedBox(height: 16),

                // Login button
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LOGIN',
                            style: TextStyle(fontSize: 16, color: Colors.white,
                                fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: Colors.white12, thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.white12, thickness: 1)),
                ]),

                const SizedBox(height: 20),

                // Google button — FIX: now calls signInWithGoogle()
                SizedBox(
                  width: double.infinity, height: 55,
                  child: OutlinedButton.icon(
                    onPressed: isGoogleLoading ? null : signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: isGoogleLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.g_mobiledata,
                            size: 28, color: Colors.white),
                    label: Text(
                      isGoogleLoading
                          ? 'Opening Google...'
                          : 'Continue with Google',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: Colors.white38)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen())),
                        child: const Text('Sign Up',
                            style: TextStyle(
                                color: Color(0xFF2979FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable dark text field ──────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _DarkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFF2979FF)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF2979FF), width: 2),
        ),
      ),
    );
  }
}