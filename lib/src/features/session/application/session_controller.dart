import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { customer, admin }

class SessionState {
  const SessionState({
    required this.isAuthenticated,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.userId,
    required this.token,
    required this.role,
    required this.points,
    required this.selectedMachineId,
    required this.selectedMachineName,
  });

  final bool isAuthenticated;
  final String? displayName;
  final String? email;
  final String? phone;
  final int? userId;
  final String? token;
  final UserRole role;
  final int points;
  final String? selectedMachineId;
  final String? selectedMachineName;

  SessionState copyWith({
    bool? isAuthenticated,
    String? displayName,
    String? email,
    String? phone,
    int? userId,
    String? token,
    UserRole? role,
    int? points,
    String? selectedMachineId,
    String? selectedMachineName,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      role: role ?? this.role,
      points: points ?? this.points,
      selectedMachineId: selectedMachineId ?? this.selectedMachineId,
      selectedMachineName: selectedMachineName ?? this.selectedMachineName,
    );
  }

  static const initial = SessionState(
    isAuthenticated: false,
    displayName: null,
    email: null,
    phone: null,
    userId: null,
    token: null,
    role: UserRole.customer,
    points: 120,
    selectedMachineId: null,
    selectedMachineName: null,
  );
}

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => SessionState.initial;

  void applyLogin({
    required int userId,
    required String displayName,
    required String email,
    required String phone,
    required String token,
    required UserRole role,
  }) {
    state = state.copyWith(
      isAuthenticated: true,
      userId: userId,
      displayName: displayName,
      email: email,
      phone: phone,
      token: token,
      role: role,
    );
  }

  void logout() {
    state = SessionState.initial;
  }

  void selectMachine({required String id, required String name}) {
    state = state.copyWith(selectedMachineId: id, selectedMachineName: name);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
