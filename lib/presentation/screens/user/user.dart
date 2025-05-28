import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  Future<void> _changeDisplayName() async {
    final controller = TextEditingController(text: user.displayName ?? "");
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên hiển thị"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Tên mới"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await user.updateDisplayName(result);
      await user.reload();
      setState(() {
        user = FirebaseAuth.instance.currentUser!;
      });
    }
  }

  Future<void> _changePassword() async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              decoration: const InputDecoration(labelText: "Mật khẩu hiện tại"),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    if (result == true) {
      final oldPassword = oldPassController.text.trim();
      final newPassword = newPassController.text.trim();
      if (oldPassword.isEmpty || newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đủ và mật khẩu mới từ 6 ký tự.")),
        );
        return;
      }
      try {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tài khoản"),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('assets/avatar.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  // Display Name (click để đổi)
                  ListTile(
                    title: Text(
                      user.displayName ?? "User",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    trailing: Icon(Icons.edit, color: theme.primaryColor),
                    onTap: _changeDisplayName,
                  ),
                  // Email (click để xem chi tiết)
                  ListTile(
                    title: Text(
                      user.email ?? "",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(Icons.info_outline, color: theme.primaryColor),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Email"),
                          content: Text(user.email ?? ""),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Đóng"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Đổi mật khẩu
                  ListTile(
                    title: Text(
                      "Đổi mật khẩu",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.lock_reset, color: theme.primaryColor),
                    onTap: _changePassword,
                  ),
                  const SizedBox(height: 32),
                  // Logout button (nếu có)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
