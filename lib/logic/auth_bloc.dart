import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;

  AuthBloc(this._auth) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        final user = FirebaseAuth.instance.currentUser;
        emit(AuthAuthenticated(user?.uid ?? ""));
      } on FirebaseAuthException catch (e) {
        String message = "Đăng nhập thất bại";
        if (e.code == 'user-not-found') {
          message = "Không tìm thấy tài khoản này";
        } else if (e.code == 'wrong-password') {
          message = "Sai mật khẩu";
        }
        emit(AuthError(message));
      }
    });

    on<AuthCheckRequested>((event, emit) {
      final user = _auth.currentUser;
      print("🔍 Checking user: ${user?.email}");
      if (user != null) {
        emit(AuthAuthenticated(user.uid));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await _auth.signOut();
      print("👋 Logged out");
      emit(AuthUnauthenticated());
    });
  }
}
