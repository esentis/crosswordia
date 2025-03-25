import 'package:crosswordia/constants/constants.dart';
import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/scraper.dart';
import 'package:crosswordia/screens/board/widgets/blur_container.dart';
import 'package:crosswordia/screens/levels/level_screen.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:crosswordia/widgets/menu_button.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({
    super.key,
    required this.authProvider,
  });

  final AppAuthStateProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: 'Admin',
      location: BannerLocation.topStart,
      child: Stack(
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
              toolbarHeight: 100,
              title: BlurContainer(
                height: 80,
                width: 230,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${authProvider.currentUser?.email}\nAdmin panel',
                      textAlign: TextAlign.center,
                      style: kStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Center(
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
                            authProvider.session!.user.id,
                            100,
                          );
                        },
                        title: 'Add coins',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MenuButton(
                        onTap: () {
                          PlayerStatusService.instance.incrementTotalWordsFound(
                            authProvider.session!.user.id,
                          );
                        },
                        title: "Increment plauer's total words found",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MenuButton(
                        onTap: () {
                          PlayerStatusService.instance
                              .incrementLevel(authProvider.session!.user.id);
                        },
                        title: "Increment player's current level",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MenuButton(
                        onTap: () {
                          PlayerStatusService.instance.getLevelsFoundWords(
                            authProvider.session!.user.id,
                            1,
                          );
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
                              ),
                            ],
                          );
                          final totalLevelCounts = res[0]! as int;
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
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
