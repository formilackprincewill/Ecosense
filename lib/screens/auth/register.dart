import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Example snippet for RegisterScreen's submit function
  // Inside _RegisterScreenState
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = context.read<AuthProvider>(); // u could also use provider.of(context, listen: false)

      final result = await authProvider.registerWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // Registration successful. The user is likely now logged in.
        // The authStateChanges listener in AuthProvider will trigger navigation
        // (handled by a wrapper widget checking isLoggedIn).
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please check your email to confirm or sign in directly.')),
          );
          // Pop out of the registration screen. If auto-login succeeded (email confirm disabled),
          // the AuthWrapper will automatically redirect them to the home dashboard.
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          String errorMessage = result['error'] ?? 'Registration failed.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
  }

  String? nSubmit(value) {
    if (value.isEmpty) {
      return 'Please enter your Name';
    }
    return null;
  }

  String? eSubmit(value) {
    if (value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? pSubmit(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? cPSubmit(value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF101910),
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF101910),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Spacer for alignment
                ],
              ),
            ),

            // Name Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEAF1E9),
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
                onSubmitted: nSubmit,
              ),
            ),

            // Email Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEAF1E9),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
                onSubmitted: eSubmit,
              ),
            ),

            // Password Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEAF1E9),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF5C8E57),
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
                onSubmitted: pSubmit,
              ),
            ),

            // Confirm Password Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEAF1E9),
                  hintText: 'Confirm Password',
                  hintStyle: TextStyle(color: Color(0xFF5C8E57), fontSize: 16),
                  contentPadding: EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xFF5C8E57),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmText = !_obscureConfirmText;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
                onSubmitted: cPSubmit,
              ),
            ),

            // Sign Up Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF298321),
                  foregroundColor: Color(0xFFF9FBF9),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // Sign In Link
            Container(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: Color(0xFF5C8E57),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Spacer (replacing the SVG images)
      bottomNavigationBar: Container(
        height: 0, // No actual content as in the original design
      ),
    );
  }
}
