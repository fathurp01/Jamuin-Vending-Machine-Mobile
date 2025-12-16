import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { customer, admin }

class SessionState {
  const SessionState({
    required this.role,
    required this.points,
    required this.selectedMachineName,
  });

  final UserRole role;
  final int points;
  final String? selectedMachineName;

  SessionState copyWith({
    UserRole? role,
    int? points,
    String? selectedMachineName,
  }) {
    return SessionState(
      role: role ?? this.role,
      points: points ?? this.points,
      selectedMachineName: selectedMachineName ?? this.selectedMachineName,
    );
  }

  static const initial = SessionState(
    role: UserRole.customer,
    points: 120,
    selectedMachineName: null,
  );
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => SessionState.initial;

  void selectMachine(String name) {
    state = state.copyWith(selectedMachineName: name);
  }

  /// Dev-friendly toggle to view the Admin Dashboard.
  /// (In production this comes from auth/claims.)
  void toggleRole() {
    state = state.copyWith(
      role: state.role == UserRole.admin ? UserRole.customer : UserRole.admin,
    );
  }
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
