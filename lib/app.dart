import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_app/logic/auth_bloc.dart';
import 'package:music_app/logic/auth_state.dart';
import 'package:music_app/logic/settings_cubit.dart';
import 'package:music_app/presentation/screens/home/home.dart';
import 'package:music_app/presentation/screens/account/login_page.dart';

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
