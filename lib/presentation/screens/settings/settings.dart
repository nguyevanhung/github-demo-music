import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/presentation/screens/settings/app_localizations.dart';
import 'package:music_app/logic/auth_bloc.dart';
import 'package:music_app/logic/auth_event.dart';
import 'package:music_app/logic/settings_cubit.dart';
import 'package:music_app/core/theme/theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.themeMode == ThemeMode.dark;
        final loc = AppLocalizations(settings.language);

        return Scaffold(
          backgroundColor: isDark ? Colors.black : AppColors.background,
          appBar: AppBar(
            title: Text(loc.get('settings')),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Đổi theme
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: SwitchListTile(
                        title: Text(
                            '${loc.get('theme')} ${isDark ? "(Dark)" : "(Light)"}'),
                        secondary: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: Colors.deepPurple),
                        value: isDark,
                        onChanged: (value) {
                          context
                              .read<SettingsCubit>()
                              .changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${loc.get('theme')} ${value ? "(Dark)" : "(Light)"} đã được áp dụng!',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Đổi ngôn ngữ
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, left: 8, bottom: 4),
                              child: Text(
                                loc.get('language'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            RadioListTile<String>(
                              value: 'vi',
                              groupValue: settings.language,
                              title: const Text('Tiếng Việt'),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().changeLanguage(value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ngôn ngữ đã chuyển sang Tiếng Việt!'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                            RadioListTile<String>(
                              value: 'en',
                              groupValue: settings.language,
                              title: const Text('English'),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().changeLanguage(value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Language switched to English!'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Nút đăng xuất
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: AppColors.white),
                        label: Text(
                          loc.get('logout'),
                          style: const TextStyle(color: AppColors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(loc.get('logout')),
                              content: const Text(
                                  "Bạn có chắc chắn muốn đăng xuất?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text("Hủy"),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  child: Text(loc.get('logout')),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
