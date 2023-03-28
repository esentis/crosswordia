import 'package:crosswordia/helper.dart';
import 'package:crosswordia/services/player_status_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

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
        notifyListeners();
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
        notifyListeners();
      } else {
        kLog.e(response);
      }
    } catch (e) {
      kLog.e(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    notifyListeners();
  }

  User? get user {
    return supabase.auth.currentUser;
  }

  Session? get session {
    return supabase.auth.currentSession;
  }
}
