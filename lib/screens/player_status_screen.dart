import 'package:crosswordia/scraper.dart';
import 'package:crosswordia/screens/levels/choose_level_screen.dart';
import 'package:crosswordia/services/levels_service.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PlayerStatusScreen extends StatefulWidget {
  const PlayerStatusScreen({super.key});

  @override
  State<PlayerStatusScreen> createState() => _PlayerStatusScreenState();
}

class _PlayerStatusScreenState extends State<PlayerStatusScreen> {
  final PlayerStatusService _statusService = PlayerStatusService.instance;
  final LevelsService _levelsService = LevelsService.instance;
  bool _isLoading = true;
  PlayerStatus? _playerStatus;
  Set<String>? _foundWords;
  int _totalLevels = 0;
  int _totalWordsOfCurrentLevel = 0;
  List<String> _recentWords = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    setState(() {
      _isLoading = true;
    });

    final String? userId = _statusService.getUserId();
    if (userId == null) {
      // Handle case where user is not logged in
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Load player status
      final PlayerStatus? status = await _statusService.getPlayerStatus(userId);
      // Load total level count
      final int totalLevels = await _statusService.getTotalLevelCounts();
      // Load found words for current level
      final Set<String>? foundWords = await _statusService.getLevelsFoundWords(
        userId,
        status?.currentLevel ?? 1,
      );
      // Get the total words of the current level
      final int totalWordsOfCurrentLevel =
          await _levelsService.getTotalWordsForLevel(
        status?.currentLevel ?? 1,
      );

      setState(() {
        _playerStatus = status;
        _totalLevels = totalLevels;
        _foundWords = foundWords;
        _isLoading = false;
        _totalWordsOfCurrentLevel = totalWordsOfCurrentLevel;

        // Get the most recent words (up to 5)
        if (foundWords != null && foundWords.isNotEmpty) {
          _recentWords = foundWords.toList().sublist(
                0,
                foundWords.length > 5 ? 5 : foundWords.length,
              );
        }
      });
    } catch (e) {
      kLog.e('Error loading player data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playerStatus == null
              ? const Center(
                  child: Text('You need to log in to view your status'),
                )
              : _buildStatusContent(),
    );
  }

  Widget _buildStatusContent() {
    final currentLevel = _playerStatus!.currentLevel;
    final levelProgress = (_foundWords?.length ?? 0) /
        _totalWordsOfCurrentLevel; // Assuming 20 words per level

    return RefreshIndicator(
      onRefresh: _loadPlayerData,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: kToolbarHeight),
        children: [
          _buildPlayerSummaryCard(),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseLevelScreen(
                    levelCount: _totalLevels,
                    playerStatus: _playerStatus!,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PLAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLevelProgressCard(currentLevel, levelProgress),
          const SizedBox(height: 24),
          _buildRecentWordsCard(),
        ],
      ),
    );
  }

  Widget _buildPlayerSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _playerStatus!.playerId.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${_playerStatus!.currentLevel}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Word Master',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Words',
                  _playerStatus!.totalWordsFound.toString(),
                  Icons.text_fields,
                ),
                _buildStatColumn(
                  'Coins',
                  _playerStatus!.coins.toString(),
                  Icons.monetization_on,
                ),
                _buildStatColumn(
                  'Level',
                  '${_playerStatus!.currentLevel}/$_totalLevels',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgressCard(int currentLevel, double progress) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $currentLevel Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${_foundWords?.length ?? 0}/$_totalWordsOfCurrentLevel words found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 20.0,
              animationDuration: 1000,
              percent: progress.clamp(0.0, 1.0),
              center: Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              barRadius: const Radius.circular(10),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? 'Level completed!'
                  : 'Keep going to complete this level!',
              style: TextStyle(
                color: progress >= 1.0 ? Colors.green : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWordsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Words Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _recentWords.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No words found yet in this level.'),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentWords.map((word) {
                      return Chip(
                        label: Text(
                          word,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.blue[100],
                      );
                    }).toList(),
                  ),
            if (_foundWords != null && _foundWords!.length > 5) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Show all words in a dialog or navigate to a new screen
                    _showAllFoundWords();
                  },
                  child: const Text('See all words'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllFoundWords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Found Words'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_foundWords?.toList() ?? []).map((word) {
              return Chip(
                label: Text(word),
                backgroundColor: Colors.blue[100],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
