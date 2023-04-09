import 'package:crosswordia/board/crossword_board.dart';
import 'package:crosswordia/levels/level_screen.dart';
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
                      PlayerStatusService.instance.updateLevelProgress(
                        status.session!.user.id,
                        1,
                        ['test', 'hello'],
                      );
                    },
                    child: const Text('Update levels progress'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance.addWordInLevelProgress(
                          status.session!.user.id, 1, 'esentis!!');
                    },
                    child: const Text('Add a word to level'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LevelScreen(),
                          ));
                    },
                    child: const Text('Go to levels screen'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CrossWordBoard(),
                          ));
                    },
                    child: const Text('Go to board'),
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
