// screens/login_screen.dart
import 'package:check_list_app/models/user.dart';
import 'package:check_list_app/services/auth_service.dart';
import 'package:check_list_app/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Added for password visibility toggle
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Check if the user role is ship incharge or shift incharge
        final currentUser = AuthService.currentUser;
        if (currentUser != null && currentUser.role == UserRole.shiftIncharge) {
          // Send daily report for ship incharge or shift incharge roles
          await TaskService.sendDailyReport();
        }

        if (!mounted) return;
        // Using go_router instead of Navigator
        context.go('/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid DarwinBox ID or password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final bool isLandscape = ResponsiveUtils.isLandscape(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: isTablet && isLandscape
                      // Landscape tablet layout
                      ? Row(
                          children: [
                            // Logo side
                            Container(
                              color: Colors.grey[50],
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 600,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            ),

                            // Form side
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Login with your DarwinBox ID',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    _buildLoginForm(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      // Portrait or phone layout
                      : Padding(
                          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo and Company Name
                              _buildHeader(),

                              SizedBox(height: isTablet ? 80.0 : 60.0),

                              // Login Form
                              _buildLoginForm(),

                              const Spacer(),
                            ],
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return Column(
      children: [
        // Vishakha Glass Logo from assets
        Image.asset(
          'assets/images/logo.png',
          width: isTablet ? 600 : 600,
          height: 100,
          fit: BoxFit.contain,
        ),
        SizedBox(height: isTablet ? 50.0 : 40.0),
        // Keep only the login instruction text
        Text(
          'Login with your DarwinBox ID',
          style: TextStyle(
            color: Colors.grey,
            fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);

    // Adjust form width based on device and orientation
    final double formWidth = isTablet
        ? isLandscape
            ? 500.0
            : 400.0
        : double.infinity;

    return Container(
      constraints: BoxConstraints(maxWidth: formWidth),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
              ),

            // Username Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'DarwinBox ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 16.0 : 12.0,
                  horizontal: 16.0,
                ),
              ),
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your DarwinBox ID';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password Field with Visibility Toggle
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
                // Adding suffix icon for password visibility toggle
                suffixIcon: IconButton(
                  icon: Icon(
                    // Change the icon based on the password visibility state
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    // Toggle password visibility state
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isTablet ? 16.0 : 12.0,
                  horizontal: 16.0,
                ),
              ),
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
              // Use the _isPasswordVisible state to toggle password visibility
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),

            SizedBox(height: isTablet ? 32.0 : 24.0),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 20.0 : 16.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Login',
                      style: TextStyle(fontSize: isTablet ? 18.0 : 16.0, color: Colors.white),
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
