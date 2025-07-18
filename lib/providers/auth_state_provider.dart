import 'package:crosswordia/core/helpers/scraper.dart';
import 'package:crosswordia/screens/auth/user_created_screen.dart';
import 'package:crosswordia/screens/player_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider =
    StateNotifierProvider<AppAuthStateProvider, AppAuthState>(
  (ref) => AppAuthStateProvider(),
);

class AppAuthState {
  final bool isAuthenticated;
  AppAuthState({
    required this.isAuthenticated,
  });
}

class AppAuthStateProvider extends StateNotifier<AppAuthState> {
  AppAuthStateProvider() : super(AppAuthState(isAuthenticated: false)) {
    _init();
  }

  final supabase = Supabase.instance.client;

  void _init() {
    state = AppAuthState(isAuthenticated: supabase.auth.currentUser != null);
  }

  bool get isAuthenticated {
    return supabase.auth.currentUser != null;
  }

  bool get isAdmin {
    return supabase.auth.currentUser?.userMetadata?['role'] == 'admin';
  }

  User? get currentUser {
    return supabase.auth.currentUser;
  }

  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        kLog.i(response.session?.toJson());
        state = AppAuthState(
          isAuthenticated: true,
        );
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const PlayerStatusScreen()),
            (route) => false, // This removes all previous routes
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.toString()),
            ),
          );
        }
        kLog.e(response);
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }
      kLog.e(e);
    }
  }

  Future<void> signUp(
    String email,
    String password,
    BuildContext context, {
    bool isAdmin = false,
  }) async {
    final options = {'role': isAdmin ? 'admin' : 'user'};
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: options,
      );

      if (response.user != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const UserCreatedScreen(),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.user.toString()),
            ),
          );
        }
        kLog.e(response.session?.toJson());
      }
    } on AuthException catch (e) {
      kLog.e(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      kLog.i('Logged out');
    } catch (e) {
      kLog.e(e);
    }

    state = AppAuthState(
      isAuthenticated: false,
    );
  }

  Session? get session {
    return supabase.auth.currentSession;
  }
}
