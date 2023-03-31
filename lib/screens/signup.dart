// ignore_for_file: use_build_context_synchronously

import 'package:crosswordia/helper.dart';
import 'package:crosswordia/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await authStatus.signUp(
                    'esentako8@yahoo.gr',
                    '123456',
                  );
                  Navigator.pop(context);
                } catch (e) {
                  kLog.e('Rethrown\n$e');
                }
              },
              child: Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
