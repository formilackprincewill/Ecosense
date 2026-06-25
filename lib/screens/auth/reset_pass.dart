import 'package:ecosense/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = ''; // For success or info messages
  String _errorMessage = ''; // For error messages

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
        _errorMessage = '';
      });

      final String email = _emailController.text.trim();

      final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context, listen: false)
      final result = await authProvider.sendPasswordResetEmail(email);

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        setState(() {
          _message = result['message'] ?? 'Password reset email sent!';
        });
        // Optionally, show a snackbar and navigate back after a delay
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message), backgroundColor: Colors.green),
          );
        }

        // automatically goes back after a few seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            Navigator.of(context).pop(); // Go back to login screen
          }
        });
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'Failed to send password reset email.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      body: Form(
        key: _formKey,
        child: Column(
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
                        'Reset Password',
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

            // Title
            Container(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your email',
                style: TextStyle(
                  color: Color(0xFF101910),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Email Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                style: TextStyle(color: Color(0xFF101910), fontSize: 16),
              ),
            ),
          ],
        ),
      ),

      // Bottom Section
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reset Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
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
                  ? CircularProgressIndicator(backgroundColor: Colors.white,)
                  : Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Message Display ---
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _message,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Spacer containers (replacing the SVG images)
          Container(
            height: 0, // No actual content as in the original design
          ),
        ],
      ),
    );
  }
}
