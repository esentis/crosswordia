// instance singleton of StatusService
import 'package:crosswordia/helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerStatusService {
  static final PlayerStatusService _instance = PlayerStatusService._();

  PlayerStatusService._();

  static PlayerStatusService get instance => _instance;

  String? getUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// Retrieves the status of a player with the specified ID.
  /// Returns a [PlayerStatus] object representing the current status of the player.
  /// If the player ID is invalid or the player does not exist, returns null.
  Future<PlayerStatus?> getPlayerStatus(String playerId) async {
    kLog.i('Getting status for $playerId');
    try {
      final data = await Supabase.instance.client
          .from('player_status')
          .select()
          .eq('player_id', playerId);

      kLog.f(data);
      if (data.isNotEmpty) {
        return PlayerStatus.fromJson(data[0]);
      }
      return null;
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return await getPlayerStatus(playerId);
      }
      return null;
    }
  }

  /// Updates the player status.
  ///
  /// [status] The new player status to be updated.
  ///
  /// Throws a [Exception] if the update fails.
  Future<void> updatePlayerStatus(PlayerStatus status) async {
    kLog.i('''
Updating status:
${status.toJson()}
''');
    try {
      final data = await Supabase.instance.client.from('player_status').update({
        'total_words_found': status.totalWordsFound,
        'coins': status.coins,
        'current_level': status.currentLevel,
      }).eq('player_id', status.playerId);

      kLog.f(data);
    } on PostgrestException catch (e) {
      kLog.e(e);
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
  /// Throws a [FirebaseException] if the operation fails.
  Future<void> createPlayerStatus(PlayerStatus status) async {
    kLog.i('Creating status for ${status.playerId}');
    try {
      await Supabase.instance.client.from('player_status').insert({
        'player_id': status.playerId,
        'total_words_found': status.totalWordsFound,
        'coins': status.coins,
        'current_level': status.currentLevel,
      });

      kLog.i('Created player status for ${status.playerId}');
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await createPlayerStatus(status);
      }
    }
  }

  /// Increments the total coins of a player.
  ///
  /// [playerId] is the ID of the player whose coins will be incremented.
  /// [coins] is the amount of coins to increment.
  /// Returns a [Future] that completes when the operation is done.
  ///
  /// Example:
  /// ```dart
  /// await incrementTotalCoins('player123', 10);
  /// ```
  Future<void> incrementTotalCoins(String playerId, int coins) async {
    kLog.i('Incrementing total couns for $playerId');
    try {
      final data = await Supabase.instance.client.rpc('incrementplayercoins',
          params: {'coinstoadd': coins, 'playerid': playerId});

      kLog.f(data);
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementTotalCoins(playerId, coins);
      }
    }
  }

  /// Increments the total number of words found by the player with the given [playerId].
  /// Returns a Future that completes when the operation is done.
  Future<void> incrementTotalWordsFound(String playerId) async {
    kLog.i('Incrementing total words found for $playerId');
    try {
      await Supabase.instance.client.rpc('incrementtotalwordsfound',
          params: {'wordscount': 1, 'playerid': playerId});

      kLog.f('Incremented total words found for $playerId');
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementTotalWordsFound(playerId);
      }
    }
  }

  /// Increments the level of the player with the given [playerId].
  ///
  /// Returns a Future that completes when the operation is done.
  Future<void> incrementLevel(String playerId) async {
    kLog.i('Incrementing level for $playerId');
    try {
      await Supabase.instance.client
          .rpc('incrementplayerlevel', params: {'playerid': playerId});

      kLog.f('Incremeted level for $playerId');
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await incrementLevel(playerId);
      }
    }
  }

  /// Checks if the level progress exists for the player
  ///
  /// If it does not exist, it will be initialized
  Future<void> checkIfLevelProgressExists(String playerId, int level) async {
    kLog.i('Checking if level progress exists for $playerId');
    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.w('Level id is null');
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select()
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      kLog.f(data);
      if (data.isEmpty) {
        await initLevelProgress(playerId, level);
      }
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
  Future<void> updateLevelProgress(
      String playerId, int level, List<String> words) async {
    kLog.i('Updating found words for $playerId');

    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .update({
            'found_words': words,
          })
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      kLog.f(data);
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
      String playerId, int level, String word) async {
    kLog.i('Checking if word already found for $playerId');

    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.w('Level id is null');
      return false;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select('found_words')
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      kLog.f(data);
      if (data.isNotEmpty) {
        final foundWords = data[0]['found_words'] as List<dynamic>;
        return foundWords.contains(word);
      }
      return false;
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
  ///
  /// [playerId] is the ID of the player.
  /// [level] is the level number.
  /// [word] is the word to be added in the level progress.
  Future<void> addWordInLevelProgress(
      String playerId, int level, String word) async {
    kLog.i('Adding word in level progress for $playerId');

    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return;
    }

    if (await checkIfWordAlreadyFound(playerId, level, word)) {
      kLog.w('Word already found');
      return;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      await Supabase.instance.client.rpc('updatewordlevel', params: {
        'player': playerId,
        'word': word,
        'level': levelId,
      });

      await incrementTotalWordsFound(playerId);

      kLog.f('Successfully added word in level progress');
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
  ///
  /// [playerId] is the ID of the player.
  /// [level] is the level number.
  ///
  /// Returns a Future that completes when the progress is initialized.
  Future<void> initLevelProgress(String playerId, int level) async {
    kLog.i('Initializing level progress for $playerId');
    final int? levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return;
    }
    try {
      final data =
          await Supabase.instance.client.from('player_level_status').insert({
        'player_id': playerId,
        'level_id': levelId,
        'found_words': [],
      });

      kLog.f(data);
    } on PostgrestException catch (e) {
      kLog.e(e.message);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        await initLevelProgress(playerId, level);
      }
    }
  }

  /// Returns the level ID for a given level.
  /// If the level does not exist, returns null.
  Future<int?> getLevelId(int level) async {
    kLog.i('Getting level id for $level');
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select()
          .eq('level', level);

      kLog.f('Level id is ${data[0]['id']}');
      if (data.isNotEmpty) {
        return data[0]['id'] as int;
      }
    } on PostgrestException catch (e) {
      kLog.e(e);
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return await getLevelId(level);
      }
      return null;
    }
    return null;
  }

  /// Retrieves the set of words found by the player for a given level.
  /// Returns null if the player has not found any words for the given level.
  ///
  /// [playerId] is the unique identifier of the player.
  /// [level] is the level for which to retrieve the found words.
  ///
  /// Throws a [StateError] if the player ID is null or empty.
  Future<Set<String>?> getLevelsFoundWords(String playerId, int level) async {
    kLog.i('Getting found words for $playerId');
    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return null;
    }
    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select('found_words')
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      kLog.f(data);
      if (data.isNotEmpty) {
        final foundWords = data[0]['found_words'] as List<dynamic>;
        return foundWords.cast<String>().toSet();
      }
      return null;
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
  /// ```
  /// final totalLevels = await getTotalLevelCounts();
  /// print(totalLevels); // prints the total number of levels
  /// ```
  Future<int> getTotalLevelCounts() async {
    kLog.i('Getting total level counts');
    try {
      final data = await Supabase.instance.client.from('levels').select();

      kLog.f('Total levels are ${data.length}');
      return data.length;
    } on PostgrestException catch (e) {
      kLog.e(e.message);
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
