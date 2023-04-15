import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.read(authStateProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: TextButton(
                onPressed: () {
                  authProvider.signIn('esentako8@yahoo.gr', '123456');
                },
                child: const Text('Please login'),
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
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
