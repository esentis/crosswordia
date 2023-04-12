import 'package:crosswordia/helper.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider =
    StateNotifierProvider<AppAuthStateProvider, AppAuthState>(
        (ref) => AppAuthStateProvider());

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

  Future<void> signIn(String email, String password) async {
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
      } else {
        kLog.e(response);
      }
    } catch (e) {
      kLog.e(e);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session != null) {
        kLog.i(response.session?.toJson());
        PlayerStatusService.instance.createPlayerStatus(
          PlayerStatus.fromNewUser(response.session!.user),
        );
        state = AppAuthState(
          isAuthenticated: true,
        );
      } else {
        kLog.e(response);
      }
    } catch (e) {
      kLog.e(e);
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

  User? get user {
    return supabase.auth.currentUser;
  }

  Session? get session {
    return supabase.auth.currentSession;
  }
}
