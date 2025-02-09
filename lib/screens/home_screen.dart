import 'package:crosswordia/constants.dart';
import 'package:crosswordia/helper.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/admin_screen.dart';
import 'package:crosswordia/screens/auth/landing_screen.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/screens/player_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authProvider = ref.read(authStateProvider.notifier);
    kLog.i(authProvider.isAdmin);
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
          appBar: authState.isAuthenticated
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  toolbarHeight: 100,
                  actions: [
                    if (authProvider.isAdmin)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminScreen(
                                authProvider: authProvider,
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                  ],
                  title: BlurContainer(
                    height: 80,
                    width: 230,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Welcome you are logged in as \n${authProvider.currentUser?.email}',
                          textAlign: TextAlign.center,
                          style: kStyle.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: authState.isAuthenticated
              ? const PlayerStatusScreen()
              : const LandingScreen(),
        ),
      ],
    );
  }
}
