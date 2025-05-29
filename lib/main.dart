import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:music_app/logic/auth_bloc.dart';
import 'package:music_app/logic/auth_event.dart';
import 'package:music_app/logic/settings_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut();
  runApp(const EntryPoint());
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested())),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: const AppView(),
    );
  }
}
