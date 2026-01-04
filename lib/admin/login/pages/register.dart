import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user profile to Firestore using the Auth UID
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'employeeID': "AD${userCredential.user!.uid.substring(0, 3).toUpperCase()}",
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) Navigator.pop(context); // Return to Login Page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF1), // Matches background in picture
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35), // Large curved corners
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOGO SECTION (RichText) ---
                Center(
                  child: Column(
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          children: [
                            TextSpan(text: "Data", style: TextStyle(color: Color.fromARGB(255, 7, 28, 135))),
                            TextSpan(text: "Solutions ", style: TextStyle(color: Colors.black)),
                            TextSpan(text: "(", style: TextStyle(color: Colors.black)),
                            TextSpan(text: "Sa", style: TextStyle(color: Colors.yellow)),
                            TextSpan(text: "ra", style: TextStyle(color: Colors.black)),
                            TextSpan(text: "wak", style: TextStyle(color: Colors.red)),
                            TextSpan(text: ")", style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      const Text("Sdn. Bhd.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 25),
                      const Text("Signup Your Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- USERNAME / FULL NAME FIELD ---
                const Text("Username", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildInputField(_nameController, "Enter your name"),

                const SizedBox(height: 20),

                // --- EMAIL FIELD ---
                const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildInputField(_emailController, "Enter your email"),

                const SizedBox(height: 20),

                // --- PASSWORD FIELD ---
                const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildInputField(_passwordController, "Enter your password", isObscure: true),

                const SizedBox(height: 35),

                // --- SIGN UP BUTTON ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF061A3E), // Dark navy blue
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),

                // --- ALREADY HAVE AN ACCOUNT LINK ---
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build input fields matching the UI picture
  Widget _buildInputField(TextEditingController controller, String hint, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F1F1), // Light grey fill
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}