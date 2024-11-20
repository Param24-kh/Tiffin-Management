import 'package:flutter/material.dart';
import 'package:frontend/src/files/main_wrapper.dart';
import 'package:frontend/src/serviceProvider/main_wrapper_service.dart';
import 'dart:io';
import 'auth_service.dart';

// Account interfaces remain the same as in previous implementation
class IAccount {
  String centerId;
  String name;
  String phoneNumber;
  String userName;
  IPasskey auth;
  String address;
  IPaymentMethod paymentMethod;
  List<String> previouslyRegisteredCenters;
  List<String> activeSubscriptions;
  List<String> previousSubscriptions;

  IAccount({
    required this.centerId,
    required this.name,
    required this.phoneNumber,
    required this.userName,
    required this.auth,
    required this.address,
    required this.paymentMethod,
    this.previouslyRegisteredCenters = const [],
    this.activeSubscriptions = const [],
    this.previousSubscriptions = const [],
  });
}

class ICenterAccount {
  String centerId;
  String centerName;
  String phoneNumber;
  String centerUserName;
  IPasskey auth;
  String address;
  String centerFeedback;
  double centerRating;

  ICenterAccount({
    required this.centerId,
    this.centerName = "",
    required this.phoneNumber,
    required this.centerUserName,
    required this.auth,
    required this.address,
    this.centerFeedback = "",
    this.centerRating = 0.0,
  });
}

class IPasskey {
  String email;
  String passkey;

  IPasskey({required this.email, required this.passkey});
}

class IPaymentMethod {
  String cardType;
  String lastFourDigits;

  IPaymentMethod({required this.cardType, required this.lastFourDigits});
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isServiceProviderLogin(String email, String passkey) {
    // Example logic to determine service provider login
    return email.contains('service') || passkey.toLowerCase().startsWith('tms');
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        final isServiceProvider = _isServiceProviderLogin(
            _emailController.text, _passwordController.text);

        if (isServiceProvider) {
          _navigateToServiceProviderDashboard(
            ICenterAccount(
              centerId: response['centerId'] ?? '',
              centerName: response['centerName'] ?? '',
              phoneNumber: response['phoneNumber'] ?? '',
              centerUserName: response['centerUserName'] ?? '',
              auth: IPasskey(
                email: _emailController.text,
                passkey: _passwordController.text,
              ),
              address: response['address'] ?? '',
              centerFeedback: response['centerFeedback'] ?? '',
              centerRating: response['centerRating'] ?? 0.0,
            ),
          );
        } else {
          _navigateToCustomerDashboard(
            IAccount(
              centerId: response['centerId'] ?? '',
              name: response['name'] ?? '',
              phoneNumber: response['phoneNumber'] ?? '',
              userName: response['userName'] ?? '',
              auth: IPasskey(
                email: _emailController.text,
                passkey: _passwordController.text,
              ),
              address: response['address'] ?? '',
              paymentMethod: IPaymentMethod(
                cardType: response['paymentMethod']?['cardType'] ?? '',
                lastFourDigits:
                    response['paymentMethod']?['lastFourDigits'] ?? '',
              ),
              previouslyRegisteredCenters: List<String>.from(
                  response['previouslyRegisteredCenters'] ?? []),
              activeSubscriptions:
                  List<String>.from(response['activeSubscriptions'] ?? []),
              previousSubscriptions:
                  List<String>.from(response['previousSubscriptions'] ?? []),
            ),
          );
        }

        _showSuccessSnackBar('Welcome ${_emailController.text}!');
      } catch (e) {
        _showErrorSnackBar('Login failed: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _navigateToCustomerDashboard(IAccount userProfile) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainWrapper(userProfile: userProfile),
      ),
    );
  }

  void _navigateToServiceProviderDashboard(ICenterAccount userProfile) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainWrapperService(userProfile: userProfile),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Passkey',
                    hintText: 'Enter passkey',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your passkey';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
