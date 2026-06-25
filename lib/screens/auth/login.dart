import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/screens/auth/register.dart';
import 'package:ecosense/screens/auth/reset_pass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

      final result = await authProvider.loginWithEmailAndPassword(
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        }
      } else {
        if (mounted) {
          String errorMessage = result['error'] ?? 'Login failed.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Image Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/login.png'), // NetworkImage(
                      //   'https://picsum.photos/seed/signin/600/400', // Placeholder image
                      // ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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

            // Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF5C8E57),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Create Account',
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

            // Sign In Button
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
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // OR Divider
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'OR',
                  style: TextStyle(color: Color(0xFF5C8E57), fontSize: 14),
                ),
              ),
            ),

            // Social Login Buttons
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: authProvider.signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFEAF1E9),
                        foregroundColor: Color(0xFF101910),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide.none,
                      ),
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle Apple sign in
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFEAF1E9),
                        foregroundColor: Color(0xFF101910),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide.none,
                      ),
                      child: Text(
                        'Continue with Apple',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
