import 'package:crosswordia/constants.dart';
import 'package:crosswordia/helper.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/auth/login_screen.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/screens/levels/level_screen.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:crosswordia/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authProvider = ref.read(authStateProvider.notifier);
    return Stack(
      children: [
        Positioned.fill(
            child: Image.asset(
          'assets/bg.webp',
          fit: BoxFit.cover,
        )),
        Container(
          color: Colors.white.withOpacity(0.7),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: authState.isAuthenticated
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  toolbarHeight: 100,
                  title: BlurContainer(
                    height: 80,
                    width: 230,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Welcome you are logged in as \n${authProvider.user?.email}',
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Column(
                        children: [
                          MenuButton(
                            onTap: () {
                              PlayerStatusService.instance.getPlayerStatus(
                                authProvider.session!.user.id,
                              );
                            },
                            title: 'Get status',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () {
                              PlayerStatusService.instance.incrementTotalCoins(
                                  authProvider.session!.user.id, 100);
                            },
                            title: 'Add coins',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () {
                              PlayerStatusService.instance
                                  .incrementTotalWordsFound(
                                      authProvider.session!.user.id);
                            },
                            title: "Increment plauer's total words found",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () {
                              PlayerStatusService.instance.incrementLevel(
                                  authProvider.session!.user.id);
                            },
                            title: "Increment player's current level",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () {
                              PlayerStatusService.instance.getLevelsFoundWords(
                                  authProvider.session!.user.id, 1);
                            },
                            title: "Get player's found words for level 1",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () async {
                              final res = await Future.wait(
                                [
                                  PlayerStatusService.instance
                                      .getTotalLevelCounts(),
                                  PlayerStatusService.instance.getPlayerStatus(
                                    authProvider.session!.user.id,
                                  )
                                ],
                              );
                              final totalLevelCounts = res[0] as int;
                              final status = res[1] as PlayerStatus?;
                              if (status != null) {
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LevelScreen(
                                        levelCount: totalLevelCounts,
                                        playerStatus: status,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            title: 'Go to levels screen',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MenuButton(
                            onTap: () {
                              scrape();
                            },
                            title: 'Scrape words',
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: TextButton(
                          onPressed: () {
                            authProvider.signOut();
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                )
              : const LoginScreen(),
        ),
      ],
    );
  }
}
