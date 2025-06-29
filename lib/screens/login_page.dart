import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricsSetting();
  }

  Future<void> _loadBiometricsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final currentContext = context;
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        // For this app, user id is always Ajay2865
        Navigator.pushReplacementNamed(currentContext, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: \\${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueGrey,
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/logo.png',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your User ID' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 30),
                if (_isBiometricsEnabled)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Login with Biometrics'),
                          onPressed: _authenticateWithBiometrics,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final userId = _userIdController.text.trim();
                        final password = _passwordController.text;
                        final isValid = await DatabaseHelper().validateUser(userId, password);
                        if (isValid) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid User ID or Password')),
                          );
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          'App Version: 1.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 