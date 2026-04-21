import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading  = false;
  bool emailSent  = false; // show success state after sending

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ── Send reset email ──────────────────────────────────────────────
  // FIX: the original code worked but was missing redirectTo
  // Without redirectTo, Supabase sends a link that opens the web app
  // not the Flutter app. We point it to our app's deep link.
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnack('Please enter your email address', isError: true);
      return;
    }

    // Basic email format check
    if (!email.contains('@') || !email.contains('.')) {
      _showSnack('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        // FIX: added redirectTo so reset link opens the app
        redirectTo:
            'io.supabase.drivingautosilencer://reset-password-callback',
      );

      if (mounted) {
        setState(() {
          isLoading = false;
          emailSent = true; // switch to success view
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showSnack(e.message, isError: true);
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Could not send reset email. Check your connection.',
            isError: true);
        setState(() => isLoading = false);
      }
    }
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
          child: Padding(
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

                Expanded(
                  child: emailSent
                      ? _SuccessView(
                          email: emailController.text.trim(),
                          onBackToLogin: () => Navigator.pop(context),
                        )
                      : _FormView(
                          emailController: emailController,
                          isLoading: isLoading,
                          onSend: resetPassword,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Form view (before sending) ────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  const _FormView({
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  size: 56, color: Color(0xFF2979FF)),
            ),
          ),

          const SizedBox(height: 28),

          const Text('Forgot Password?',
              style: TextStyle(fontSize: 26,
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          const Text(
            "No worries! Enter your email and we'll send you a reset link.",
            style: TextStyle(fontSize: 15, color: Colors.white54, height: 1.5),
          ),

          const SizedBox(height: 36),

          // Email field
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Color(0xFF2979FF)),
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
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SEND RESET LINK',
                      style: TextStyle(fontSize: 16, color: Colors.white,
                          fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('← Back to Login',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success view (after sending) ──────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;

  const _SuccessView({required this.email, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated success icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.12),
            border: Border.all(color: Colors.green.withOpacity(0.4)),
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 64, color: Colors.green),
        ),

        const SizedBox(height: 28),

        const Text('Email Sent!',
            style: TextStyle(fontSize: 26,
                fontWeight: FontWeight.bold, color: Colors.white)),

        const SizedBox(height: 12),

        Text(
          'We sent a password reset link to:\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.white54, height: 1.6),
        ),

        const SizedBox(height: 12),

        const Text(
          'Check your inbox (and spam folder).\nThe link expires in 24 hours.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white38, height: 1.6),
        ),

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('BACK TO LOGIN',
                style: TextStyle(fontSize: 16, color: Colors.white,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }
}