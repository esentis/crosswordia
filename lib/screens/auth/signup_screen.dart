// ignore_for_file: use_build_context_synchronously

import 'package:crosswordia/helper.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

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
            TextButton(
              onPressed: () async {
                try {
                  await authProvider.signUp(
                    'esentako8@yahoo.gr',
                    '123456',
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
