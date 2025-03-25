import 'package:crosswordia/scraper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isAdmingRegistrationProvider =
    StateNotifierProvider<IsAdminRegisteringProvider, IsAdminState>(
  (ref) => IsAdminRegisteringProvider(),
);

class IsAdminState {
  final bool registeringAsAdmin;

  IsAdminState({
    required this.registeringAsAdmin,
  });
}

class IsAdminRegisteringProvider extends StateNotifier<IsAdminState> {
  IsAdminRegisteringProvider()
      : super(IsAdminState(registeringAsAdmin: false)) {
    _init();
  }

  void _init() {
    state = IsAdminState(registeringAsAdmin: false);
  }

  void toggleRegisteringAsAdmin() {
    state = IsAdminState(registeringAsAdmin: !state.registeringAsAdmin);
    kLog.f('Toggling registering as admin to ${state.registeringAsAdmin}');
  }

  bool get isRegisteringAsAdmin {
    return state.registeringAsAdmin;
  }
}
