import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/appwrite_service.dart';

// ─── Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [fullName, email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final Map<String, dynamic> data;
  const AuthProfileUpdateRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

// ─── States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final FarmModel? farm;
  const AuthAuthenticated({required this.user, this.farm});
  @override
  List<Object?> get props => [user, farm];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {}

// ─── BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FarmService _farmService;

  AuthBloc({required AuthService authService, required FarmService farmService})
    : _authService = authService,
      _farmService = farmService,
      super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthProfileUpdateRequested>(_onProfileUpdate);
    on<AuthPasswordResetRequested>(_onPasswordReset);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }
      final profile = await _authService.getUserProfile(user.$id);
      final farm = await _farmService.getFarmByUser(user.$id);
      print(
        'User: ${user.email}, Profile: ${profile?.fullName}, Farm: ${farm?.id}',
      );
      if (profile != null) {
        emit(AuthAuthenticated(user: profile, farm: farm));
      } else {
        final userModel = UserModel(
          id: user.$id,
          fullName: user.name,
          email: user.email,
        );
        emit(AuthAuthenticated(user: userModel, farm: farm));
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.login(email: event.email, password: event.password);
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('Login failed');
      final profile = await _authService.getUserProfile(user.$id);
      final farm = await _farmService.getFarmByUser(user.$id);
      final userModel =
          profile ??
          UserModel(id: user.$id, fullName: user.name, email: user.email);
      emit(AuthAuthenticated(user: userModel, farm: farm));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('Registration failed');
      final userModel = UserModel(
        id: user.$id,
        fullName: event.fullName,
        email: event.email,
      );
      emit(AuthAuthenticated(user: userModel, farm: null));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.createGoogleSession();
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('Google sign-in failed');
      final profile = await _authService.getUserProfile(user.$id);
      final farm = await _farmService.getFarmByUser(user.$id);
      final userModel =
          profile ??
          UserModel(id: user.$id, fullName: user.name, email: user.email);
      emit(AuthAuthenticated(user: userModel, farm: farm));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onProfileUpdate(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    try {
      await _authService.updateProfile(current.user.id, event.data);
      final updated = current.user.copyWith(
        fullName: event.data['fullName'] ?? current.user.fullName,
        phone: event.data['phone'] ?? current.user.phone,
      );
      emit(AuthAuthenticated(user: updated, farm: current.farm));
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordReset(event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(_parseError(e)));
    }
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Invalid credentials')) return 'Invalid email or password';
    if (msg.contains('already exists')) return 'Account already exists';
    if (msg.contains('network')) return 'Network error. Check your connection';
    return 'Something went wrong. Please try again';
  }
}
