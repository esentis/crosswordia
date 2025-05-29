// ignore_for_file: use_build_context_synchronously

import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/providers/is_admin_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  SignupScreen({required this.isLogin, super.key});
  final bool isLogin;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.read(authStateProvider.notifier);

    final isAdminProviderRead = ref.read(isAdmingRegistrationProvider.notifier);
    final isAdminProvider = ref.watch(isAdmingRegistrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Signup'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {},
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                obscureText: true,
                onChanged: (value) {},
              ),
              if (!isLogin)
                Checkbox(
                  value: isAdminProvider.registeringAsAdmin,
                  onChanged: (isAdmin) {
                    kLog.i(isAdmin);
                    isAdminProviderRead.toggleRegisteringAsAdmin();
                  },
                ),
              TextButton(
                onPressed: () async {
                  try {
                    isLogin
                        ? await authProvider.signIn(
                            emailController.text,
                            passwordController.text,
                            context,
                          )
                        : await authProvider.signUp(
                            emailController.text,
                            passwordController.text,
                            context,
                            isAdmin: isAdminProvider.registeringAsAdmin,
                          );
                  } catch (e) {
                    kLog.e('Rethrown\n$e');
                  }
                },
                child: Text(isLogin ? 'Login' : 'Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
