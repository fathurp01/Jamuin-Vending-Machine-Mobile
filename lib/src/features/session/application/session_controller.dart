import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { customer, admin }

class SessionState {
  const SessionState({
    required this.isAuthenticated,
    required this.displayName,
    required this.email,
    required this.role,
    required this.points,
    required this.selectedMachineName,
  });

  final bool isAuthenticated;
  final String? displayName;
  final String? email;
  final UserRole role;
  final int points;
  final String? selectedMachineName;

  SessionState copyWith({
    bool? isAuthenticated,
    String? displayName,
    String? email,
    UserRole? role,
    int? points,
    String? selectedMachineName,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      selectedMachineName: selectedMachineName ?? this.selectedMachineName,
    );
  }

  static const initial = SessionState(
    isAuthenticated: false,
    displayName: null,
    email: null,
    role: UserRole.customer,
    points: 120,
    selectedMachineName: null,
  );
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => SessionState.initial;

  void applyLogin({
    required String displayName,
    required String email,
    required UserRole role,
  }) {
    state = state.copyWith(
      isAuthenticated: true,
      displayName: displayName,
      email: email,
      role: role,
    );
  }

  void logout() {
    state = SessionState.initial;
  }

  void selectMachine(String name) {
    state = state.copyWith(selectedMachineName: name);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
