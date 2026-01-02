import 'package:flutter/material.dart';

// Import your page files - Ensure these paths match your folder structure exactly
import 'admin/login/pages/dashboard.dart'; 
import 'admin/login/pages/register.dart'; 
import 'admin/login/pages/forgotpassword.dart';
import 'admin/login/pages/manual_attendance.dart'; 
import 'admin/login/pages/company_setting.dart'; // Verified import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendEase System',
      theme: ThemeData(
        primaryColor: const Color(0xFF0B1D4D),
        scaffoldBackgroundColor: const Color(0xFFF0F4F7),
        fontFamily: 'Inter', // Consistent typography
      ),
      // --- TESTING MODE ---
      // Swap the comments below to switch which page opens first
      home: const LoginPage(), 
      // home: const CompanySettingsPage(), 
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F7),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
              ],
            ),
            child: Column(
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
                const Text('Sign in Your Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 30),
                
                _buildLabel('Email'),
                _buildTextField(),
                const SizedBox(height: 20),
                
                _buildLabel('Password'),
                _buildTextField(obscure: true),
                const SizedBox(height: 10),
                
                // Remember Me & Forgot Password
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: const Color(0xFF0B1D4D),
                      onChanged: (value) => setState(() => rememberMe = value!),
                    ),
                    const Text('Remember my preference', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage())
                        );
                      }, 
                      child: const Text(
                        'Forgot Password?', 
                        style: TextStyle(fontSize: 13, color: Color(0xFF5C6BC0))
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // SIGN IN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B1D4D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      // Navigate to AdminDashboard
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const AdminDashboard())
                      );
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Registration Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue,
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
        padding: const EdgeInsets.only(bottom: 8), 
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))
      )
    );
  }

  Widget _buildTextField({bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        obscureText: obscure, 
        decoration: const InputDecoration(
          border: InputBorder.none, 
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)
        )
      ),
    );
  }
}