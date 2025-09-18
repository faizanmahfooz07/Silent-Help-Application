import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showDialog(
        title: "Incomplete",
        message: "Please fill all fields",
        icon: Icons.warning,
        iconColor: Colors.orangeAccent,
      );
      return;
    }

    if (password != confirmPassword) {
      _showDialog(
        title: "Mismatch",
        message: "Passwords do not match",
        icon: Icons.error,
        iconColor: Colors.redAccent,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showDialog(
        title: "Success",
        message: "You have successfully registered!",
        icon: Icons.check_circle,
        iconColor: Colors.greenAccent,
        onContinue: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.pop(context); // Back to login screen
        },
      );
    } catch (e) {
      _showDialog(
        title: "Registration Failed",
        message: "Error: ${e.toString()}",
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: onContinue ?? () => Navigator.of(context).pop(),
            child: Text("Continue", style: TextStyle(color: iconColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade900,
              Colors.pink.shade700,
              Colors.redAccent.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 72, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),

                _buildTextField(emailController, 'Email', Icons.email, false),
                const SizedBox(height: 16),
                _buildTextField(passwordController, 'Password', Icons.lock, true),
                const SizedBox(height: 16),
                _buildTextField(confirmPasswordController, 'Confirm Password', Icons.lock_outline, true),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isObscure) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isObscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
