import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskflow/screens/welcome/welcome_screen.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

 Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _error = e.message;
        });
      }
    } finally {
      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
 }
  void _showForgotPasswordDialog() {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF142238),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.shade700, width: 1),
            ),
            title: Text(
              "Reset Password",
              style: TextStyle(
                color: Colors.blue.shade100,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your email and we'll send you a password reset link",
                  style: TextStyle(
                    color: const Color(0xB3B3D9FF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFF0000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x1AFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: const Color(0x80B3D9FF),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade300,
                ),
                child: const Text("CANCEL"),
              ),
              isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.trim().isEmpty ||
                            !emailController.text.contains('@')) {
                          setState(() {
                            errorMessage = "Please enter a valid email address";
                          });
                          return;
                        }
                        
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: emailController.text.trim());
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password reset link sent to ${emailController.text}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            errorMessage = e.message ?? "Failed to send reset email";
                            isLoading = false;
                          });
                        } catch (e) {
                          setState(() {
                            errorMessage = "An unknown error occurred";
                            isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text("SEND LINK"),
                    ),
            ],
          );
        },
      );
    },
  );
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
                            CupertinoIcons.check_mark_circled_solid,
                            size: 70,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "TaskFlow",
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Sign in to your account",
                            style: TextStyle(
                              color: const Color(0xB3B3D9FF), // ~70% of blue.shade200
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
                                hintStyle: TextStyle(
                                  color: const Color(0x80B3D9FF), // Semitransparent blue shade
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
                                hintStyle: TextStyle(
                                  color: const Color(0x80B3D9FF), // Semitransparent blue shade
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
                          const SizedBox(height: 12),
                          
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade300,
                              ),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          
                          // Login button
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
                                    onPressed: _login,
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
                                          'LOGIN',
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
                          
                          // Sign up section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an Account?",
                                style: TextStyle(
                                  color: Color(0xB3B3D9FF), // ~70% of blue.shade200
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade300,
                                ),
                                child: const Text(
                                  'SIGN UP',
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    );
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