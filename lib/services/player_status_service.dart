// instance singleton of StatusService
import 'package:crosswordia/helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerStatusService {
  static final PlayerStatusService _instance = PlayerStatusService._();

  PlayerStatusService._();

  static PlayerStatusService get instance => _instance;

  Future<PlayerStatus?> getPlayerStatus(String playerId) async {
    kLog.i('Getting status for $playerId');
    try {
      final data = await Supabase.instance.client
          .from('player_status')
          .select()
          .eq('player_id', playerId);

      kLog.wtf(data);
      if (data.isNotEmpty) {
        return PlayerStatus.fromJson(data[0]);
      }
      return null;
    } catch (e) {
      kLog.e(e);
      return null;
    }
  }

  Future<void> updatePlayerStatus(PlayerStatus status) async {
    kLog.i('Updating status for ${status.playerId}');
    try {
      final data = await Supabase.instance.client.from('player_status').update({
        'total_words_found': status.totalWordsFound,
        'coins': status.coins,
        'current_level': status.currentLevel,
      }).eq('player_id', status.playerId);

      kLog.wtf(data);
    } catch (e) {
      kLog.e(e);
    }
  }

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
    } catch (e) {
      kLog.e(e);
    }
  }

  // Increments the total coins of the player
  Future<void> incrementTotalCoins(String playerId, int coins) async {
    kLog.i('Incrementing total words found for $playerId');
    try {
      final data = await Supabase.instance.client.rpc('incrementplayercoins',
          params: {'coinstoadd': coins, 'playerid': playerId});

      kLog.wtf(data);
    } catch (e) {
      kLog.e(e);
    }
  }

  // Increments the total coins of the player
  Future<void> incrementTotalWordsFound(String playerId, int wordscount) async {
    kLog.i('Incrementing total words found for $playerId');
    try {
      final data = await Supabase.instance.client.rpc(
          'incrementtotalwordsfound',
          params: {'wordscount': wordscount, 'playerid': playerId});

      kLog.wtf(data);
    } catch (e) {
      kLog.e(e);
    }
  }

  // Increments the level of the player
  Future<void> incrementLevel(String playerId) async {
    kLog.i('Incrementing total words found for $playerId');
    try {
      final data = await Supabase.instance.client
          .rpc('incrementplayerlevel', params: {'playerid': playerId});

      kLog.wtf(data);
    } catch (e) {
      kLog.e(e);
    }
  }

  /// Checks if the level progress exists for the player
  ///
  /// If it does not exist, it will be initialized
  Future<void> checkIfLevelProgressExists(String playerId, int level) async {
    kLog.i('Checking if level progress exists for $playerId');
    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('player_level_status')
          .select()
          .eq('player_id', playerId)
          .eq('level_id', levelId);

      kLog.wtf(data);
      if (data.isEmpty) {
        await initLevelProgress(playerId, level);
      }
    } on PostgrestException catch (e) {
      kLog.e(e.message);
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
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

      kLog.wtf(data);
    } on PostgrestException catch (e) {
      kLog.e(e.message);
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        await updateLevelProgress(playerId, level, words);
      }
    }
  }

  /// Adds a word to the level progress for the player
  Future<void> addWordInLevelProgress(
      String playerId, int level, String word) async {
    kLog.i('Adding word in level progress for $playerId');

    final levelId = await getLevelId(level);

    if (levelId == null) {
      kLog.e('Level id is null');
      return;
    }
    await checkIfLevelProgressExists(playerId, level);

    try {
      final data =
          await Supabase.instance.client.rpc('updatewordlevel', params: {
        'player': playerId,
        'word': word,
        'level': levelId,
      });

      kLog.wtf(data);
    } on PostgrestException catch (e) {
      kLog.e(e.message);
      if (e.message.contains('does not exist')) {
        await initLevelProgress(playerId, level);
        await updateLevelProgress(playerId, level, [word]);
      }
    }
  }

  /// Initializes the level progress for the player
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

      kLog.wtf(data);
    } on PostgrestException catch (e) {
      kLog.e(e.message);
    }
  }

  /// Gets the level id from the level table
  Future<int?> getLevelId(int level) async {
    kLog.i('Getting level id for $level');
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select()
          .eq('level', level);

      kLog.wtf('Level id is ${data[0]['id']}');
      if (data.isNotEmpty) {
        return data[0]['id'];
      }
    } catch (e) {
      kLog.e(e);
      return null;
    }
    return null;
  }
}

class PlayerStatus {
  final String playerId;
  final int totalWordsFound;
  final int coins;
  final int currentLevel;
  final List<Map<String, dynamic>> levelsProgress;
  PlayerStatus({
    required this.playerId,
    required this.totalWordsFound,
    required this.coins,
    required this.currentLevel,
    required this.levelsProgress,
  });

  factory PlayerStatus.fromJson(Map<String, dynamic> json) {
    return PlayerStatus(
      playerId: json['player_id'],
      totalWordsFound: json['total_words_found'],
      coins: json['coins'],
      currentLevel: json['current_level'],
      levelsProgress: json['levels_progress'] ?? [],
    );
  }

  factory PlayerStatus.fromNewUser(User user) {
    return PlayerStatus(
      playerId: user.id,
      totalWordsFound: 0,
      coins: 500,
      currentLevel: 1,
      levelsProgress: [],
    );
  }
}
