import 'package:crosswordia/providers/auth_provider.dart';
import 'package:crosswordia/screens/login.dart';
import 'package:crosswordia/services/grouped_words_service.dart';
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
            return SafeArea(
              child: Column(
                children: [
                  const Center(
                    child: Text('Welcome you are logged in'),
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
                      PlayerStatusService.instance.incrementTotalWordsFound(
                          status.session!.user.id, 25);
                    },
                    child: const Text('Increment total words'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance.updateFoundWords(
                          status.session!.user.id, ['hello', 'world', 'test']);
                    },
                    child: const Text('Update current level words'),
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
                      GroupedWordsService.instance.addGroupedWordsFromMap();
                    },
                    child: const Text('Add grouped words in DB'),
                  ),
                  TextButton(
                    onPressed: () {
                      status.signOut();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
          return const LoginScreen();
        },
        child: Text('Loading'),
      ),
    );
  }
}
