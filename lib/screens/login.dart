import 'package:crosswordia/providers/auth_provider.dart';
import 'package:crosswordia/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.read<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: TextButton(
                onPressed: () {
                  authStatus.signIn('esentako8@yahoo.gr', '123456');
                },
                child: Text('Please login'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
