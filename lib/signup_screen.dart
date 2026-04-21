import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'supabase_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading            = false;
  bool isGoogleLoading      = false;
  bool showPassword         = false;
  bool showConfirmPassword  = false;
  String passwordStrength   = '';
  Color strengthColor       = Colors.red;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void checkPasswordStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordStrength = '';
      } else if (value.length < 6) {
        passwordStrength = '🔴 Weak password';
        strengthColor = Colors.red;
      } else if (value.length < 10) {
        passwordStrength = '🟡 Medium password';
        strengthColor = Colors.orange;
      } else {
        passwordStrength = '🟢 Strong password';
        strengthColor = Colors.green;
      }
    });
  }

  // ── Email signup ──────────────────────────────────────────────────
  Future<void> signup() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm  = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields', isError: true);
      return;
    }

    if (password != confirm) {
      _showSnack('Passwords do not match!', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (mounted) {
        _showSnack(
          'Account created! Check your email to verify, then log in.',
        );
        // Go back to login — user needs to verify email first
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Signup failed. Check your connection.', isError: true);
    }
    if (mounted) setState(() => isLoading = false);
  }

  // ── Google signup — FIX: was empty onPressed: () {} ───────────────
  Future<void> signUpWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // AuthWrapper stream handles navigation after redirect
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Google sign up failed. Try again.', isError: true);
    }
    if (mounted) setState(() => isGoogleLoading = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 4),
    ));
  }

  // ── UI — dark theme matching login screen ─────────────────────────
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

                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 20),

                // Header
                Center(
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2979FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2979FF).withOpacity(0.4),
                            blurRadius: 24, spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Create Account',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    const Text('Join AutoSilencer today',
                        style: TextStyle(fontSize: 14, color: Colors.white38)),
                  ]),
                ),

                const SizedBox(height: 36),

                // Email
                _DarkField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
                _DarkField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: !showPassword,
                  onChanged: checkPasswordStrength,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),

                // Password strength
                if (passwordStrength.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(passwordStrength,
                        style: TextStyle(
                            color: strengthColor, fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),

                const SizedBox(height: 16),

                // Confirm password
                _DarkField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscure: !showConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () => setState(
                        () => showConfirmPassword = !showConfirmPassword),
                  ),
                ),

                const SizedBox(height: 28),

                // Sign Up button
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CREATE ACCOUNT',
                            style: TextStyle(fontSize: 16, color: Colors.white,
                                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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

                // Google button — FIX: now fully working
                SizedBox(
                  width: double.infinity, height: 55,
                  child: OutlinedButton.icon(
                    onPressed: isGoogleLoading ? null : signUpWithGoogle,
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
                          : 'Sign up with Google',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: Colors.white38)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Login',
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

// ── Reusable dark field ───────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const _DarkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: onChanged,
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