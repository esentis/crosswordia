// ignore_for_file: use_build_context_synchronously

import 'package:crosswordia/helper.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  SignupScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {},
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {},
            ),
            TextButton(
              onPressed: () async {
                try {
                  await authProvider.signUp(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  kLog.e('Rethrown\n$e');
                }
              },
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
