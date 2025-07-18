import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerStatusService {
  static final PlayerStatusService _instance = PlayerStatusService._();

  PlayerStatusService._();

  static PlayerStatusService get instance => _instance;

  /// Gets the current user ID
  /// Returns null if no user is logged in
  String? getUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// Gets the current user object
  /// Returns null if no user is logged in
  User? getCurrentUser() {
    return Supabase.instance.client.auth.currentUser;
  }

  /// Ensures the user has an initialized player status
  /// Creates a new status if none exists
  /// Returns the player status
  Future<PlayerStatus> ensurePlayerStatus() async {
    final User? currentUser = getCurrentUser();
    if (currentUser == null) {
      throw StateError('No user is logged in');
    }

    final String playerId = currentUser.id;

    // Try to get existing status
    final PlayerStatus? existingStatus = await getPlayerStatus(playerId);

    // If status exists, return it
    if (existingStatus != null) {
      return existingStatus;
    }

    // If no status exists, create a new one
    final PlayerStatus newStatus = PlayerStatus.fromNewUser(currentUser);
    await createPlayerStatus(newStatus);

    return newStatus;
  }

  /// Retrieves the status of a player with the specified ID.
  /// Returns a [PlayerStatus] object representing the current status of the player.
  /// If the player ID is invalid or the player does not exist, returns null.
  Future<PlayerStatus?> getPlayerStatus(String playerId) async {
    try {
      final data = await Supabase.instance.client
          .from('player_status')
          .select()
          .eq('player_id', playerId);

      if (data.isNotEmpty) {
        return PlayerStatus.fromJson(data[0]);
      }
      return null;
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return await getPlayerStatus(playerId);
      }
      return null;
    }
  }

  /// Gets the player status for the current user
  /// If no status exists, creates one
  /// Throws a [StateError] if no user is logged in
  Future<PlayerStatus> getCurrentPlayerStatus() async {
    final String? userId = getUserId();
    if (userId == null) {
      throw StateError('No user is logged in');
    }

    return await ensurePlayerStatus();
  }

  /// Updates the player status.
  ///
  /// [status] The new player status to be updated.
  ///
  /// Throws a [Exception] if the update fails.
  Future<void> updatePlayerStatus(PlayerStatus status) async {
    try {
      await Supabase.instance.client.from('player_status').update({
        'total_words_found': status.totalWordsFound,
        'coins': status.coins,
        'current_level': status.currentLevel,
      }).eq('player_id', status.playerId);
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await updatePlayerStatus(status);
      }
    }
  }

  /// Creates a new player status.
  ///
  /// [status] The player status to be created.
  ///
  /// Throws a [PostgrestException] if the operation fails.
  Future<void> createPlayerStatus(PlayerStatus status) async {
    try {
      await Supabase.instance.client.from('player_status').insert({
        'player_id': status.playerId,
        'total_words_found': status.totalWordsFound,
        'coins': status.coins,
        'current_level': status.currentLevel,
      });
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await createPlayerStatus(status);
      }
    }
  }

  /// Increments the total coins of a player.
  /// Creates player status if it doesn't exist.
  ///
  /// [playerId] is the ID of the player whose coins will be incremented.
  /// [coins] is the amount of coins to increment.
  /// Returns a [Future] that completes when the operation is done.
  Future<void> incrementTotalCoins(String playerId, int coins) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    try {
      await Supabase.instance.client.rpc(
        'incrementplayercoins',
        params: {'coinstoadd': coins, 'playerid': playerId},
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementTotalCoins(playerId, coins);
      }
    }
  }

  /// Ensures a player status exists for the given player ID
  /// Creates a new one if none exists
  Future<void> ensurePlayerStatusExists(String playerId) async {
    final status = await getPlayerStatus(playerId);
    if (status == null) {
      final User? user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.id == playerId) {
        await createPlayerStatus(PlayerStatus.fromNewUser(user));
      } else {
        // If we don't have the user object for this ID, create a basic status
        await createPlayerStatus(PlayerStatus(
          playerId: playerId,
          totalWordsFound: 0,
          coins: 500,
          currentLevel: 1,
        ));
      }
    }
  }

  /// Increments the total number of words found by the player with the given [playerId].
  /// Creates player status if it doesn't exist.
  /// Returns a Future that completes when the operation is done.
  Future<void> incrementTotalWordsFound(String playerId) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    try {
      await Supabase.instance.client.rpc(
        'incrementtotalwordsfound',
        params: {'wordscount': 1, 'playerid': playerId},
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementTotalWordsFound(playerId);
      }
    }
  }

  /// Increments the level of the player with the given [playerId].
  /// Creates player status if it doesn't exist.
  /// Returns a Future that completes when the operation is done.
  Future<void> incrementLevel(String playerId) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    try {
      await Supabase.instance.client
          .rpc('incrementplayerlevel', params: {'playerid': playerId});
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementLevel(playerId);
      }
    }
  }

  /// Checks if the level progress exists for the player
  ///
  /// If it does not exist, it will be initialized
  /// Creates player status if it doesn't exist.
  Future<void> checkIfLevelProgressExists(String playerId, int level) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final levelId = await getLevelId(level);

    if (levelId == null) {
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select()
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      if (data.isEmpty) {
        await initLevelProgress(playerId, level);
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await checkIfLevelProgressExists(playerId, level);
      }
    }
  }

  /// Updates the level progress for the player
  ///
  /// If the level progress does not exist, it will be initialized
  /// Creates player status if it doesn't exist.
  Future<void> updateLevelProgress(
    String playerId,
    int level,
    List<String> words,
  ) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final levelId = await getLevelId(level);

    if (levelId == null) {
      return;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      await Supabase.instance.client
          .from('player_level_status')
          .update({
            'found_words': words,
          })
          .eq('player_id', playerId)
          .eq('level_id', levelId);
    } on PostgrestException catch (e) {
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        await updateLevelProgress(playerId, level, words);
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await updateLevelProgress(playerId, level, words);
      }
    }
  }

  Future<bool> checkIfWordAlreadyFound(
    String playerId,
    int level,
    String word,
  ) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final levelId = await getLevelId(level);

    if (levelId == null) {
      return false;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select('found_words')
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      if (data.isNotEmpty) {
        final foundWords = data[0]['found_words'] as List<dynamic>;
        return foundWords.contains(word);
      }
      return false;
    } on PostgrestException catch (e) {
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        return false;
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return await checkIfWordAlreadyFound(playerId, level, word);
      }
      return false;
    }
  }

  /// Adds a word in the level progress of a player.
  /// Creates player status if it doesn't exist.
  ///
  /// [playerId] is the ID of the player.
  /// [level] is the level number.
  /// [word] is the word to be added in the level progress.
  Future<void> addWordInLevelProgress(
    String playerId,
    int level,
    String word,
  ) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final levelId = await getLevelId(level);

    if (levelId == null) {
      // .e('Level id is null');
      return;
    }

    if (await checkIfWordAlreadyFound(playerId, level, word)) {
      // .w('Word already found');
      return;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      await Supabase.instance.client.rpc(
        'updatewordlevel',
        params: {
          'player': playerId,
          'word': word,
          'level': levelId,
        },
      );

      await incrementTotalWordsFound(playerId);
    } on PostgrestException catch (e) {
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        await updateLevelProgress(playerId, level, [word]);
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await addWordInLevelProgress(playerId, level, word);
      }
    }
  }

  /// Initializes the progress of a player for a specific level.
  /// Creates player status if it doesn't exist.
  ///
  /// [playerId] is the ID of the player.
  /// [level] is the level number.
  ///
  /// Returns a Future that completes when the progress is initialized.
  Future<void> initLevelProgress(String playerId, int level) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final int? levelId = await getLevelId(level);

    if (levelId == null) {
      return;
    }
    try {
      await Supabase.instance.client.from('player_level_status').insert({
        'player_id': playerId,
        'level_id': levelId,
        'found_words': [],
      });
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await initLevelProgress(playerId, level);
      }
    }
  }

  /// Returns the level ID for a given level.
  /// If the level does not exist, returns null.
  Future<int?> getLevelId(int level) async {
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select()
          .eq('level', level);

      if (data.isNotEmpty) {
        return data[0]['id'] as int;
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return await getLevelId(level);
      }
      return null;
    }
    return null;
  }

  /// Retrieves the set of words found by the player for a given level.
  /// Creates player status if it doesn't exist.
  /// Returns null if the player has not found any words for the given level.
  ///
  /// [playerId] is the unique identifier of the player.
  /// [level] is the level for which to retrieve the found words.
  ///
  /// Throws a [StateError] if the player ID is null or empty.
  Future<Set<String>?> getLevelsFoundWords(String playerId, int level) async {
    // Ensure player status exists
    await ensurePlayerStatusExists(playerId);

    final levelId = await getLevelId(level);

    if (levelId == null) {
      return null;
    }
    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select('found_words')
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      if (data.isNotEmpty) {
        final foundWords = data[0]['found_words'] as List<dynamic>;
        return foundWords.cast<String>().toSet();
      }
      return null;
    } on PostgrestException catch (e) {
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        return null;
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return getLevelsFoundWords(playerId, level);
      }
      return null;
    }
  }

  /// Returns the total level counts as an integer.
  ///
  /// The count includes all levels, regardless of their status (completed or not).
  ///
  /// Example usage:
  /// ``` dart
  /// final totalLevels = await getTotalLevelCounts();
  /// print(totalLevels); // prints the total number of levels
  /// ```
  Future<int> getTotalLevelCounts() async {
    try {
      final data = await Supabase.instance.client.from('levels').select();

      return data.length;
    } on PostgrestException catch (e) {
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return getTotalLevelCounts();
      }
      return 0;
    }
  }
}

class PlayerStatus {
  final String playerId;
  final int totalWordsFound;
  final int coins;
  final int currentLevel;
  PlayerStatus({
    required this.playerId,
    required this.totalWordsFound,
    required this.coins,
    required this.currentLevel,
  });

  factory PlayerStatus.fromJson(Map<String, dynamic> json) {
    return PlayerStatus(
      playerId: json['player_id'] as String,
      totalWordsFound: json['total_words_found'] as int,
      coins: json['coins'] as int,
      currentLevel: json['current_level'] as int,
    );
  }

  factory PlayerStatus.fromNewUser(User user) {
    return PlayerStatus(
      playerId: user.id,
      totalWordsFound: 0,
      coins: 500,
      currentLevel: 1,
    );
  }

  PlayerStatus copyWith({
    String? playerId,
    int? totalWordsFound,
    int? coins,
    int? currentLevel,
  }) {
    return PlayerStatus(
      playerId: playerId ?? this.playerId,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'total_words_found': totalWordsFound,
      'coins': coins,
      'current_level': currentLevel,
    };
  }
}
