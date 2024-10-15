import 'dart:async';
import 'package:Kohr_Admin/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isButtonDisabled = false;
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isButtonDisabled = true;
      _startTimer();
    });

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _errorMessage = 'A password reset link has been sent to your email.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else {
          _errorMessage = e.message ?? 'An unknown error occurred';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/kohrlogo.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.white,
                    child: Center(
                      child: SizedBox(
                        width: size.width * .3,
                        child: _buildForgotPasswordForm(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildForgotPasswordForm(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Material(
      elevation: 10.0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Reset Your Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              onSubmitted: (_) {
                if (!_isButtonDisabled) {
                  _resetPassword();
                }
              },
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(
                  color: _errorMessage.contains('link has been sent') ||
                          _errorMessage.contains('No user found')
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      _isButtonDisabled
                          ? 'Resend in $_secondsRemaining seconds'
                          : 'Reset Password',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
