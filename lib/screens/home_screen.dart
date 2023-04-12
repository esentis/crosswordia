import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/auth/login_screen.dart';
import 'package:crosswordia/screens/board/crossword_board_screen.dart';
import 'package:crosswordia/screens/levels/level_screen.dart';
import 'package:crosswordia/services/grouped_words_service.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authProvider = ref.read(authStateProvider.notifier);
    return Scaffold(
      body: authState.isAuthenticated
          ? SafeArea(
              child: Column(
                children: [
                  const Center(
                    child: Text('Welcome you are logged in'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance
                          .getPlayerStatus(authProvider.session!.user.id);
                    },
                    child: const Text('Get status'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance.incrementTotalCoins(
                          authProvider.session!.user.id, 100);
                    },
                    child: const Text('Add coins'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance.incrementTotalWordsFound(
                          authProvider.session!.user.id, 25);
                    },
                    child: const Text('Increment total words'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance
                          .incrementLevel(authProvider.session!.user.id);
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
                        authProvider.session!.user.id,
                        1,
                        ['test', 'hello'],
                      );
                    },
                    child: const Text('Update levels progress'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlayerStatusService.instance.addWordInLevelProgress(
                          authProvider.session!.user.id, 1, 'esentis!!');
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
                      PlayerStatusService.instance.getLevelsFoundWords(
                          authProvider.session!.user.id, 1);
                    },
                    child: const Text('Get level found words'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CrosswordBoardScreen(),
                          ));
                    },
                    child: const Text('Go to board'),
                  ),
                  TextButton(
                    onPressed: () {
                      authProvider.signOut();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            )
          : const LoginScreen(),
    );
  }
}
