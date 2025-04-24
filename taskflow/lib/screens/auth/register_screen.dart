import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Add this check
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      // Add this check
      if (mounted) {
        setState(() {
          _error = e.message;
        });
      }
    } finally {
      // Add this check
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF081221), // Very dark blue
              Color(0xFF0A1829), // Dark blue
              Color(0xFF142238), // Slightly lighter dark blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo or app name
                          Icon(
                            CupertinoIcons.person_add_solid,
                            size: 70,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Sign up to get started",
                            style: TextStyle(
                              color: Color(0xB3B3D9FF), // ~70% of blue.shade200
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Error message display
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0x1AFF0000), // Light red with alpha
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0x4DFF0000)), // Red with alpha
                              ),
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF), // 10% white
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x1AFFFFFF), // 10% white
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  CupertinoIcons.mail,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                                hintText: 'Email',
                                hintStyle: const TextStyle(
                                  color: Color(0x80B3D9FF), // Semitransparent blue shade
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value == null || !value.contains('@') ? 'Enter a valid email' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF), // 10% white
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0x1AFFFFFF), // 10% white
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  CupertinoIcons.lock,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  color: Color(0x80B3D9FF), // Semitransparent blue shade
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                              obscureText: true,
                              validator: (value) => value == null || value.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Register button
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.blue)
                              : Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x4D0D47A1), // 30% of blue.shade900
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'REGISTER',
                                          style: TextStyle(
                                            color: Colors.blue.shade50,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          CupertinoIcons.arrow_right,
                                          color: Colors.blue.shade50,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 24),
                          
                          // Login section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Color(0xB3B3D9FF), // ~70% of blue.shade200
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade300,
                                ),
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // BACK BUTTON
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(CupertinoIcons.arrow_left, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}