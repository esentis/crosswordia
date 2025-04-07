// ignore_for_file: use_build_context_synchronously

import 'package:crosswordia/providers/auth_state_provider.dart';
import 'package:crosswordia/screens/board/crossword_board_screen.dart';
import 'package:crosswordia/services/levels_service.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseLevelScreen extends StatefulWidget {
  const ChooseLevelScreen({
    required this.levelCount,
    required this.playerStatus,
    super.key,
  });

  final int levelCount;
  final PlayerStatus playerStatus;

  @override
  State<ChooseLevelScreen> createState() => _ChooseLevelScreenState();
}

class _ChooseLevelScreenState extends State<ChooseLevelScreen> {
  // Constants
  static const int _levelsPerPage = 20;
  static const int _levelsPerRow = 4;

  // Controllers
  late PageController _pageController;

  // Current page for button visibility logic
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Calculate which page the current level is on
    _currentPage = (widget.playerStatus.currentLevel - 1) ~/ _levelsPerPage;

    // Initialize the page controller to start at the current level's page
    _pageController = PageController(initialPage: _currentPage)
      ..addListener(_pageChangeListener);
  }

  void _pageChangeListener() {
    if (!_pageController.hasClients) return;

    final double pageValue = _pageController.page ?? 0;
    final int newPage = pageValue.round();

    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageChangeListener);
    _pageController.dispose();
    super.dispose();
  }

  // Calculate total number of pages
  int get _pageCount => (widget.levelCount / _levelsPerPage).ceil();

  // Navigate to next page
  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Get level status
  LevelStatus _getLevelStatus(int level) {
    if (level < widget.playerStatus.currentLevel) {
      return LevelStatus.completed;
    } else if (level == widget.playerStatus.currentLevel) {
      return LevelStatus.current;
    } else {
      return LevelStatus.locked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF1C1), // Cream background color from the image
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          width: 60,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFFFCB500), // Yellow from the image
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: 200,
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFCB500), // Yellow from the image
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Levels', // Chinese characters from the image, meaning "Levels"
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Empty container to balance the layout
                      const SizedBox(width: 60, height: 70),
                    ],
                  ),
                ),

                // Level grid with pagination
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    physics:
                        const BouncingScrollPhysics(), // Add physics to enable swiping
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, pageIndex) {
                      // Calculate level range for this page
                      final int startLevel = pageIndex * _levelsPerPage + 1;
                      final int endLevel = (pageIndex + 1) * _levelsPerPage;
                      final int pageItemCount = endLevel > widget.levelCount
                          ? widget.levelCount - startLevel + 1
                          : _levelsPerPage;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scroll since PageView handles scrolling
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _levelsPerRow,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: pageItemCount,
                          itemBuilder: (context, index) {
                            final int level = startLevel + index;
                            final LevelStatus status = _getLevelStatus(level);

                            return _LevelTile(
                              level: level,
                              status: status,
                              onTap: status != LevelStatus.locked
                                  ? () => _openLevel(level)
                                  : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Page indicator
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, _) {
                          // Calculate current page including decimal part for animation
                          final double currentPage = (_pageController.hasClients
                                  ? _pageController.page
                                  : _pageController.initialPage.toDouble()) ??
                              0;

                          // Calculate how close we are to this dot
                          final double closeness = (currentPage - index).abs();
                          final bool isActive = closeness < 0.5;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 12 : 8,
                            height: isActive ? 12 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFFCB500)
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

                // Extra padding at the bottom for navigation buttons
                const SizedBox(height: 60),
              ],
            ),

            // Navigation buttons (left)
            if (_currentPage > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCB500).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

            // Navigation buttons (right)
            if (_currentPage < _pageCount - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCB500).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),

            // Page number indicator
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_pageCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to the level
  Future<void> _openLevel(int level) async {
    final ref = ProviderScope.containerOf(context);
    final authState = ref.read(authStateProvider.notifier);
    final userId = authState.session?.user.id;

    if (userId == null) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        LevelsService.instance.getLevel(level),
        PlayerStatusService.instance.getLevelsFoundWords(userId, level),
        PlayerStatusService.instance.getPlayerStatus(userId),
      ]);

      // Pop loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final Level? levelData = results[0] as Level?;
      final Set<String> foundWords = results[1] as Set<String>? ?? {};
      final PlayerStatus? playerStatus = results[2] as PlayerStatus?;

      if (levelData != null && playerStatus != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CrosswordBoardScreen(
              words: levelData.words,
              foundWords: foundWords,
              level: level,
              playerStatus: playerStatus,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      // Pop loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load level: $e')),
        );
      }
    }
  }
}

// Level status enum
enum LevelStatus {
  completed,
  current,
  locked,
}

// Level tile widget
class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.status,
    this.onTap,
  });

  final int level;
  final LevelStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Determine colors and style based on status
    Color backgroundColor;
    Color textColor;
    Widget? badge;

    switch (status) {
      case LevelStatus.completed:
        backgroundColor = const Color(0xFF9ABE41); // Green from the image
        textColor = Colors.white;
        badge = Positioned(
          top: 4,
          right: 4,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF9ABE41),
              size: 16,
            ),
          ),
        );

      case LevelStatus.current:
        backgroundColor = const Color(0xFFFCB500); // Yellow from the image
        textColor = Colors.white;

      case LevelStatus.locked:
        backgroundColor = Colors.grey.shade400;
        textColor = Colors.grey.shade700;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: status == LevelStatus.locked
                ? Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey.shade700,
                      size: 32,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '$level',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }
}
