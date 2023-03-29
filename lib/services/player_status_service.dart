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

  Future<void> updateFoundWords(
      String playerId, List<String> foundWords) async {
    kLog.i('Updating found words for $playerId');
    try {
      final data = await Supabase.instance.client.from('player_status').update({
        'found_words': foundWords,
      }).eq('player_id', playerId);

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
      playerId: json['player_id'],
      totalWordsFound: json['total_words_found'],
      coins: json['coins'],
      currentLevel: json['current_level'],
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
}
