// edit_profile_screen.dart
import 'package:ecosense/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  // Pass initial user data if needed
  // final Map<String, dynamic> initialUserData;
  // const EditProfileScreen({super.key, required this.initialUserData});

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>(); // u could also use provider.of(context)
    final user = authProvider.userProfile;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context, listen: false)
      final String newName = _nameController.text.trim();

      // Check if anything actually changed
      if (newName == authProvider.userProfile?.name) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
        setState(() {
          _isLoading = false; // Reset saving state
        });
        return;
      }

      try {
        // Call the provider method to update the profile
        final result = await authProvider.updateUserProfile(
          name: newName,
          // Add other updatable fields if needed (photoUrl, bio, etc.)
        );

        setState(() {
          _isLoading = false; // Reset saving state
        });

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'Profile updated successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            String errorMessage =
                result['error'] ?? 'Failed to update profile.';
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
          _isLoading = false; // Reset saving state on error
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: $e'),
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
          'Edit Profile',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      // backgroundImage: NetworkImage(
                      //   'https://picsum.photos/seed/sophia/200', // Placeholder image
                      // ),
                      backgroundColor: Color(0xFFEAF1E9),
                      child: Icon(
                        Icons.person,
                        size: 64,
                        color: Color(0xFF5C8E57),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name Input
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: "Enter your name",
                color: Color(0xFFEAF1E9),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 13),

              //email
              _buildTextField(
                controller: _emailController,
                enabled: false,
                labelText: 'Email (Read-Only)',
                hintText: "Enter your email",
                hintColor: false,
                color: Colors.grey.withValues(alpha: 0.2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Add more fields here if needed (e.g., Bio, Location)
              // _buildTextField(
              //   controller: _bioController,
              //   labelText: 'Bio',
              //   hintText: 'Tell us about yourself',
              //   maxLines: 3,
              // ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
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

              //for error handling
              // if (authProvider.errorMessage != null && !authProvider.errorMessage!.contains('successfully'))
              //   Padding(
              //     padding: const EdgeInsets.only(top: 10.0),
              //     child: Text(
              //       authProvider.errorMessage!,
              //       style: const TextStyle(color: Colors.red),
              //     ),
              //   ),
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
    required Color color,
    bool hintColor = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF5C8E57)),
        filled: true,
        fillColor: color ,
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
            color: const Color(0xFF2E7D32).withValues(alpha:  0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      style: TextStyle(color: hintColor ? const Color(0xFF101910) : const Color.fromARGB(142, 16, 25, 16)),
    );
  }
}

// lib/screens/edit_profile_screen.dart
// import 'package:ecosense/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   // --- Keys for Forms ---
//   final _profileFormKey =
//       GlobalKey<FormState>(); // Key for main profile info form

//   // --- Controllers ---
//   late TextEditingController _nameController;
//   late TextEditingController _emailController; // Read-only

//   // --- Loading States ---
//   bool _isSavingProfile = false;

//   @override
//   void initState() {
//     super.initState();
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     _nameController = TextEditingController(
//       text: authProvider.userProfile?.name ?? '',
//     );
//     _emailController = TextEditingController(
//       text: authProvider.userProfile?.email ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveProfile() async {
//     // Validate the main profile form
//     if (_profileFormKey.currentState!.validate()) {
//       setState(() {
//         _isSavingProfile = true; // Set saving state
//       });

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final String newName = _nameController.text.trim();

//       // Check if anything actually changed
//       if (newName == authProvider.userProfile?.name) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
//         setState(() {
//           _isSavingProfile = false; // Reset saving state
//         });
//         return;
//       }

//       try {
//         // Call the provider method to update the profile
//         final result = await authProvider.updateUserProfile(
//           name: newName,
//           // Add other updatable fields if needed (photoUrl, bio, etc.)
//         );

//         setState(() {
//           _isSavingProfile = false; // Reset saving state
//         });

//         if (result['success'] == true) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   result['message'] ?? 'Profile updated successfully!',
//                 ),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             Navigator.of(context).pop();
//           }
//         } else {
//           if (mounted) {
//             String errorMessage =
//                 result['error'] ?? 'Failed to update profile.';
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(errorMessage),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         setState(() {
//           _isSavingProfile = false; // Reset saving state on error
//         });
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Update failed: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         // --- Save Profile Action in AppBar ---
//         actions: [
//           IconButton(
//             icon: _isSavingProfile
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Icon(Icons.save),
//             onPressed: _isSavingProfile ? null : _saveProfile,
//           ),
//         ],

//         // --- End of AppBar Actions ---
//       ),
//       body: authProvider.userProfile == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // --- Profile Picture (Placeholder) ---
//                   const Center(
//                     child: CircleAvatar(
//                       radius: 50,
//                       child: Icon(Icons.person, size: 50),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // --- Profile Information Section Title ---
//                   const Text(
//                     'Edit Profile Information',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),

//                   // --- MAIN PROFILE FORM ---
//                   // Use the dedicated _profileFormKey for this section
//                   Form(
//                     key:
//                         _profileFormKey, // <<<--- CORRECT KEY FOR PROFILE FIELDS ---
//                     child: Column(
//                       children: [
//                         // --- Name Field ---
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Name',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.person),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your name';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 20),

//                         // --- Email Field (Read-Only) ---
//                         TextFormField(
//                           controller: _emailController,
//                           enabled: false, // Make it read-only
//                           decoration: const InputDecoration(
//                             labelText: 'Email (Read-only)',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.email),
//                           ),
//                           // No validator needed for read-only field
//                         ),
//                         // Removed the redundant SizedBox and inner Form here
//                       ],
//                     ),
//                   ),
//                   // --- END OF MAIN PROFILE FORM ---
//                   const SizedBox(height: 30),

//                   // // --- PASSWORD CHANGE FORM ---
//                   // // Use the dedicated _passwordFormKey for this section
//                   // Form(
//                   //   key:
//                   //       _passwordFormKey, // <<<--- CORRECT KEY FOR PASSWORD FIELDS ---
//                   //   child: Column(
//                   //     children: [
//                   //       // --- Old Password Field ---
//                   //       TextFormField(
//                   //         controller: _oldPasswordController,
//                   //         decoration: const InputDecoration(
//                   //           labelText: 'Old Password',
//                   //           border: OutlineInputBorder(),
//                   //           prefixIcon: Icon(Icons.lock_outline),
//                   //         ),
//                   //         obscureText: true,
//                   //         validator: (value) {
//                   //           if (value == null || value.isEmpty) {
//                   //             return 'Please enter your old password';
//                   //           }
//                   //           return null;
//                   //         },
//                   //       ),
//                   //       const SizedBox(height: 15),

//                   //       // --- New Password Field ---
//                   //       TextFormField(
//                   //         controller: _newPasswordController,
//                   //         decoration: const InputDecoration(
//                   //           labelText: 'New Password',
//                   //           border: OutlineInputBorder(),
//                   //           prefixIcon: Icon(Icons.lock),
//                   //         ),
//                   //         obscureText: true,
//                   //         validator: (value) {
//                   //           if (value == null || value.isEmpty) {
//                   //             return 'Please enter a new password';
//                   //           }
//                   //           if (value.length < 6) {
//                   //             return 'Password must be at least 6 characters';
//                   //           }
//                   //           // Add more complex validation if needed
//                   //           return null;
//                   //         },
//                   //       ),
//                   //       const SizedBox(height: 15),

//                   //       // --- Confirm New Password Field ---
//                   //       TextFormField(
//                   //         controller: _confirmNewPasswordController,
//                   //         decoration: const InputDecoration(
//                   //           labelText: 'Confirm New Password',
//                   //           border: OutlineInputBorder(),
//                   //           prefixIcon: Icon(Icons.lock_reset),
//                   //         ),
//                   //         obscureText: true,
//                   //         validator: (value) {
//                   //           if (value == null || value.isEmpty) {
//                   //             return 'Please confirm your new password';
//                   //           }
//                   //           if (value != _newPasswordController.text) {
//                   //             return 'Passwords do not match';
//                   //           }
//                   //           return null;
//                   //         },
//                   //       ),
//                   //       const SizedBox(height: 20),

//                   //       // --- Change Password Button ---
//                   //       SizedBox(
//                   //         width: double.infinity,
//                   //         child: ElevatedButton.icon(
//                   //           onPressed: _isChangingPassword
//                   //               ? null
//                   //               : _changePassword,
//                   //           icon: _isChangingPassword
//                   //               ? const CircularProgressIndicator(
//                   //                   color: Colors.white,
//                   //                 )
//                   //               : const Icon(Icons.key),
//                   //           label: _isChangingPassword
//                   //               ? const Text('Changing...')
//                   //               : const Text('Change Password'),
//                   //           style: ElevatedButton.styleFrom(
//                   //             backgroundColor: Colors.orange,
//                   //             foregroundColor: Colors.white,
//                   //             padding: const EdgeInsets.symmetric(vertical: 15),
//                   //             shape: RoundedRectangleBorder(
//                   //               borderRadius: BorderRadius.circular(30),
//                   //             ),
//                   //           ),
//                   //         ),
//                   //       ),
//                   //       // --- End of Change Password Button ---
//                   //     ],
//                   //   ),
//                   // ),
//                   // // --- END OF PASSWORD CHANGE FORM ---
//                   // const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//     );
//   }
// }
