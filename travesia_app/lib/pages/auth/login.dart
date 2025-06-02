import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
// import 'package:travesia_app/pages/auth/forgot.dart'; // Keep if used, or remove
// import 'package:travesia_app/pages/auth/register.dart'; // Will use named route
// import 'package:travesia_app/pages/home/home.dart'; // Will use named route, and it's in a different location now
import 'package:travesia_app/services/auth_service.dart';
import 'package:travesia_app/utils/alert_utils.dart';
// Removed ApiService import as it's not used directly in this version of login logic
// If your AuthService uses ApiService internally, that's fine.

class LoginPage extends StatefulWidget {
  final AuthService authService;
  const LoginPage({Key? key, required this.authService}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // late final ApiService _apiService; // Removed if not directly used

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  // bool _isAuthInitialized = false; // Removed as authService is passed in

  @override
  void initState() {
    super.initState();
    // _apiService = ApiService(); // Removed if not directly used
    // _initializeAuthService(); // Removed
  }

  // Future<void> _initializeAuthService() async { ... } // Removed

  Future<void> _login() async {
    // if (!_isAuthInitialized) { // Removed
    //   AlertUtils.showWarning(context, 'Please wait while initializing...');
    //   return;
    // }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In a real app, AuthService.login would return a boolean or throw an error
      // For this example, let's assume it's modified to return a simple map or boolean
      // For now, we'll simulate a direct call and expect a boolean or specific structure.
      // This part depends on how your actual AuthService.login is implemented.
      // The provided AuthService doesn't have a return value for login,
      // so we'll simulate a success and navigate.
      
      // await widget.authService.login( // Assuming login method updates some internal state
      final result = await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        AlertUtils.showError(
            context, result['message'] ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        AlertUtils.showError(
            context, 'An unexpected error occurred. Please try again later.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Welcome back,\nSign in to continue.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        // TODO: Implement Forgot Password or remove
                        // child: InkWell(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) =>
                        //               const ForgotPasswordPage()), // Make sure ForgotPasswordPage exists and is imported
                        //     );
                        //   },
                        //   child: const Text(
                        //     'Forgot password?',
                        //     style: TextStyle(
                        //       color: Colors.red,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                        child: TextButton(
                            onPressed: () {
                                // Placeholder for forgot password functionality
                                // For now, let's keep it simple or remove if not a priority for this step
                                child: TextButton(
                                    onPressed: _isLoading ? null : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Forgot Password functionality not implemented yet.')),
                                        );
                                        // Navigator.pushNamed(context, '/forgot-password'); // If you have a forgot password page
                                    },
                                    child: Text(
                                        'Forgot password?',
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                    ),
                                ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
