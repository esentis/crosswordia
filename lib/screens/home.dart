import 'package:crosswordia/providers/auth_provider.dart';
import 'package:crosswordia/screens/login.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, status, child) {
          print('Current state is ${status.isAuthenticated}');
          if (status.isAuthenticated) {
            return Column(
              children: [
                Center(
                  child: const Text('Welcome you are logged in'),
                ),
                TextButton(
                  onPressed: () {
                    PlayerStatusService.instance
                        .getPlayerStatus(status.session!.user.id);
                  },
                  child: const Text('Get status'),
                ),
                TextButton(
                  onPressed: () {
                    PlayerStatusService.instance
                        .incrementTotalCoins(status.session!.user.id, 100);
                  },
                  child: const Text('Add coins'),
                ),
                TextButton(
                  onPressed: () {
                    PlayerStatusService.instance
                        .incrementTotalWordsFound(status.session!.user.id, 25);
                  },
                  child: const Text('Add words'),
                ),
                TextButton(
                  onPressed: () {
                    PlayerStatusService.instance
                        .incrementLevel(status.session!.user.id);
                  },
                  child: const Text('Increment level'),
                ),
                TextButton(
                  onPressed: () {
                    status.signOut();
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          }
          return const LoginScreen();
        },
        child: Text('Loading'),
      ),
    );
  }
}
