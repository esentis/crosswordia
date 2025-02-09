import 'package:crosswordia/constants.dart';
import 'package:crosswordia/screens/auth/signup_screen.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg.webp',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: Colors.white.withValues(alpha: 0.7),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            toolbarHeight: 150,
            title: BlurContainer(
              color: Colors.red,
              height: 100,
              child: Center(
                child: Text(
                  'CrossWordia',
                  style: kStyle.copyWith(
                    color: Colors.blue,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MenuButton(
                  title: 'Login',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(
                          isLogin: true,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(
                          isLogin: false,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Create account',
                    style: kStyle.copyWith(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
