import 'package:crosswordia/core/constants/grouped_words.dart';
import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LevelsService {
  Map<String, dynamic> words;
  static final LevelsService _instance = LevelsService._(words: levels);

  LevelsService._({required this.words});

  static LevelsService get instance => _instance;

  /// Gets all levels from the database, ordered by ID
  /// Returns an empty list if there's an error or no levels found
  Future<List<Level>> getAllLevels() async {
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select()
          .order('id', ascending: true);

      kLog.f('Retrieved ${data.length} levels');
      if (data.isNotEmpty) {
        return data.map((e) => Level.fromJson(e)).toList();
      }
      return [];
    } on PostgrestException catch (e) {
      kLog.e('PostgrestException getting all levels: ${e.message}');
      if (e.code == '404') {
        kLog.e('Table "levels" might not exist. Check your database schema.');
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return getAllLevels();
      }
      return [];
    } catch (e) {
      kLog.e('Unexpected error getting all levels: $e');
      return [];
    }
  }

  /// Gets a specific level by level number
  /// Returns null if the level doesn't exist or there's an error
  Future<Level?> getLevel(int level) async {
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select()
          .eq('level', level)
          .single();

      kLog.f('Retrieved level $level');
      return Level.fromJson(data);
    } on PostgrestException catch (e) {
      kLog.e('PostgrestException getting level $level: ${e.message}');
      if (e.code == '404') {
        kLog.e('Table "levels" might not exist. Check your database schema.');
      } else if (e.code == 'PGRST116') {
        kLog.e('Level $level not found');
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return getLevel(level);
      }
      return null;
    } catch (e) {
      kLog.e('Unexpected error getting level $level: $e');
      return null;
    }
  }

  // Find which level is the latest one in the database and return its id
  Future<int> getLatestLevelNumber() async {
    try {
      final data = await Supabase.instance.client
          .from('levels')
          .select('id')
          .order('id', ascending: false)
          .limit(1);

      if (data.isNotEmpty) {
        final latestLevelId = data.first['id'] as int;
        kLog.f('Latest level in database is $latestLevelId');
        return latestLevelId;
      }
      kLog.i('No levels found in database, starting from level 0');
      return 0;
    } on PostgrestException catch (e) {
      kLog.e('PostgrestException getting latest level: ${e.message}');
      if (e.code == '404') {
        kLog.e('Table "levels" might not exist. Check your database schema.');
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return getLatestLevelNumber();
      }
      return 0;
    } catch (e) {
      kLog.e('Unexpected error getting latest level: $e');
      return 0;
    }
  }

  /// Creates a new level with the provided level data
  /// Returns true if successful, false otherwise
  Future<bool> addLevel(Level levelData) async {
    try {
      kLog.i(
          'Adding level ${levelData.level} with ${levelData.words.length} words');
      await Supabase.instance.client.from('levels').insert({
        'words': levelData.words.toList(), // Convert Set to List for Supabase
        'letters':
            levelData.letters.toList(), // Convert Set to List for Supabase
        'level': levelData.level,
      }).select();

      kLog.f('Successfully added level ${levelData.level}');
      return true;
    } on PostgrestException catch (e) {
      kLog.e(
          'PostgrestException adding level ${levelData.level}: ${e.message}');
      if (e.code == '404') {
        kLog.e('Table "levels" might not exist. Check your database schema.');
      } else if (e.code == '23505') {
        kLog.e(
            'Duplicate key violation: Level ${levelData.level} might already exist.');
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return addLevel(levelData);
      }
      return false;
    } catch (e) {
      kLog.e('Unexpected error adding level ${levelData.level}: $e');
      return false;
    }
  }

  /// Adds all grouped words from the predefined map to the database
  /// Returns the number of levels successfully added
  Future<int> addGroupedWordsFromMap() async {
    int successCount = 0;
    try {
      var level = 1;

      // Get existing levels to avoid duplicates
      final existingLevels = await getAllLevels();
      final existingLevelNumbers = existingLevels.map((l) => l.level).toSet();

      // Sort words by length to create a progression
      final List<String> sortedWords = words.keys.toList()
        ..sort((a, b) => a.length.compareTo(b.length));

      // Create the map with the sorted keys
      final Map<String, dynamic> sortedMap = {
        for (final key in sortedWords) key: words[key],
      };

      // Add each level in sequence
      for (final entry in sortedMap.entries) {
        final String key = entry.key;
        final dynamic value = entry.value;

        // Skip levels that already exist
        if (existingLevelNumbers.contains(level)) {
          kLog.i('Level $level already exists, skipping');
          level++;
          continue;
        }

        kLog.i('Adding level $level with key $key');

        try {
          final newLevel = Level(
            id: 0, // ID will be assigned by the database
            level: level,
            words: Set<String>.from(value as List<dynamic>),
            letters: key.split(''),
          );

          final success = await addLevel(newLevel);
          if (success) {
            successCount++;
          }
        } on PostgrestException catch (e) {
          kLog.e('PostgrestException adding level $level: ${e.message}');
          if (e.message.contains('JWT expired')) {
            await Supabase.instance.client.auth.refreshSession();
            // Don't retry this specific level as it would disrupt our sequence
          }
        } catch (e) {
          kLog.e('Error adding level $level: $e');
        }

        level++;
      }

      kLog.i('Added $successCount new levels to database');
      return successCount;
    } catch (e) {
      kLog.e('Unexpected error in addGroupedWordsFromMap: $e');
      return successCount;
    }
  }

  /// Checks if the "levels" table exists in the database
  /// Returns true if it exists, false otherwise
  Future<bool> checkIfLevelsTableExists() async {
    try {
      // Try to fetch a single record (we don't care about the result)
      // Just checking if the table exists
      await Supabase.instance.client.from('levels').select().limit(1);
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '404') {
        kLog.e('Table "levels" does not exist');
        return false;
      }
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return checkIfLevelsTableExists();
      }
      kLog.e('Error checking if levels table exists: ${e.message}');
      return false;
    } catch (e) {
      kLog.e('Unexpected error checking if levels table exists: $e');
      return false;
    }
  }

  /// Creates the "levels" table in the database if it doesn't exist
  /// Use this method to initialize the database
  /// Returns true if the table was created or already exists, false otherwise
  Future<bool> createLevelsTableIfNotExists() async {
    // This would typically be done via migrations in a production app
    // But for simplicity, we'll create the table directly

    if (await checkIfLevelsTableExists()) {
      kLog.i('Levels table already exists');
      return true;
    }

    try {
      // Note: This requires RLS policies to be configured properly
      // and might require admin privileges depending on your setup
      await Supabase.instance.client.rpc('create_levels_table');
      kLog.i('Created levels table');
      return true;
    } on PostgrestException catch (e) {
      kLog.e('PostgrestException creating levels table: ${e.message}');
      if (e.message.contains('JWT expired')) {
        await Supabase.instance.client.auth.refreshSession();
        return createLevelsTableIfNotExists();
      }
      return false;
    } catch (e) {
      kLog.e('Unexpected error creating levels table: $e');
      return false;
    }
  }

  Future<int> getTotalWordsForLevel(int level) async {
    try {
      final Level? levelData = await getLevel(level);
      if (levelData != null) {
        return levelData.words.length;
      }
      kLog.e('Could not get total words count: Level $level not found');
      return 0;
    } catch (e) {
      kLog.e('Error getting total words for level $level: $e');
      return 0;
    }
  }
}

class Level {
  final int id;
  final int level;
  final Set<String> words;
  final List<String> letters;

  Level({
    required this.id,
    required this.level,
    required this.words,
    required this.letters,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      level: json['level'] as int,
      words: Set<String>.from(json['words'] as List<dynamic>),
      letters: List<String>.from(json['letters'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'words': words.toList(), // Convert Set to List for JSON serialization
      'letters': letters.toList(), // Convert Set to List for JSON serialization
    };
  }

  @override
  String toString() {
    return 'Level{id: $id, level: $level, letters: $letters, words: ${words.length} words}';
  }
}
