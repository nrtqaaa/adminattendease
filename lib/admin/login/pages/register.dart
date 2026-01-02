import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F7), // Light grey background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Section
                Image.asset(
                  'assets/datasolutions_logo.jpg', 
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.business, size: 50, color: Color(0xFF0B1D4D)),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Signup Your Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),

                // Form Fields matching your screenshot
                _buildLabel('Username'),
                _buildTextField(),
                const SizedBox(height: 20),

                _buildLabel('Email'),
                _buildTextField(),
                const SizedBox(height: 20),

                _buildLabel('Password'),
                _buildTextField(obscure: true),
                const SizedBox(height: 30),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D4D), // Dark Blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Logic for signing up goes here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Account Created! Please Sign In."))
                      );
                      Navigator.pop(context); // Go back to login
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // "Already have an account?" Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(fontSize: 14)),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Returns to Login Page
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTextField({bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5), // Light grey input background
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}