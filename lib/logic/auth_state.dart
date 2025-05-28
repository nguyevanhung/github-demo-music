abstract class AuthState {}

class AuthInitial extends AuthState {
  @override
  String toString() => 'AuthInitial';
}

class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}

class AuthAuthenticated extends AuthState {
  final String uid;
  AuthAuthenticated(this.uid);

  @override
  String toString() => 'AuthAuthenticated(uid: $uid)';
}

class AuthUnauthenticated extends AuthState {
  @override
  String toString() => 'AuthUnauthenticated';
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  String toString() => 'AuthError(message: $message)';
}
