import 'package:ecosense/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final _passwordFormKey =
      GlobalKey<FormState>(); // Key for password change form

  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Validate the password change form
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isChangingPassword = true; // Set changing password state
      });

      final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context, listen: false)
      final String oldPassword = _oldPasswordController.text.trim();
      final String newPassword = _newPasswordController.text.trim();

      try {
        // Call the provider method to change the password
        final result = await authProvider.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );

        setState(() {
          _isChangingPassword = false; // Reset changing password state
        });

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Password changed successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Clear password fields after successful change
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        } else {
          if (mounted) {
            String errorMessage =
                result['error'] ?? 'Failed to change password.';
            // Handle specific error requiring re-authentication
            if (result['code'] == 'requires-recent-login') {
              errorMessage =
                  'For security, please log out and log back in before changing your password.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isChangingPassword = false; // Reset changing password state on error
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password change failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _oldPasswordController,
                labelText: "Old Password",
                hintText: "Enter your old password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your old password";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),

              _buildTextField(
                controller: _newPasswordController,
                labelText: "New Password",
                hintText: "Enter your new password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your new password";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),

              _buildTextField(
                controller: _confirmNewPasswordController,
                labelText: "Confirm New Password",
                hintText: "Enter your new password again",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your new password again";
                  } else if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isChangingPassword
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF5C8E57)),
        filled: true,
        fillColor: const Color(0xFFEAF1E9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      style: const TextStyle(color: Color(0xFF101910)),
    );
  }
}
