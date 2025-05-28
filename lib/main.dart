import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:music_app/logic/auth_bloc.dart';
import 'package:music_app/logic/auth_event.dart';
import 'package:music_app/logic/auth_state.dart';
import 'package:music_app/logic/settings_cubit.dart'; // Thêm dòng này
import 'package:music_app/presentation/screens/home/home.dart';
import 'package:music_app/presentation/screens/account/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut(); // Đăng xuất user cũ trước khi vào app
  runApp(const EntryPoint());
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested())),
        BlocProvider(create: (_) => SettingsCubit()), // Thêm dòng này
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: settings.themeMode,
          locale: Locale(settings.language),
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              print("📱 Rebuilding UI with state: $state");

              if (state is AuthAuthenticated) {
                return const MusicApp();
              } else if (state is AuthUnauthenticated) {
                return const LoginPage();
              } else if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                return const Scaffold(
                  body: Center(child: Text("🔄 Đang kiểm tra đăng nhập...")),
                );
              }
            },
          ),
        );
      },
    );
  }
}
