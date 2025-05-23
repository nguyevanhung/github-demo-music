import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Không có người dùng nào đang đăng nhập."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),

            /// Avatar + Name
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(
                      'assets/avatar.png'), 
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.displayName ?? "User",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified,
                            color: Colors.green, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Listen to music for 396 minutes",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Icons row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _InfoTile(icon: Icons.music_note, label: "Local", count: 0),
                _InfoTile(icon: Icons.favorite, label: "Collect", count: 40),
                _InfoTile(icon: Icons.download, label: "Download", count: 13),
                _InfoTile(icon: Icons.history, label: "Lately", count: 85),
              ],
            ),

            const SizedBox(height: 30),

            /// Circles
            const _OptionTile(
              icon: Icons.music_video,
              label: "Music Circle",
            ),
            const _OptionTile(
              icon: Icons.mic,
              label: "K Song Circle",
              iconColor: Colors.green,
            ),

            const SizedBox(height: 20),

            /// Song list header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Self-built song list",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.add),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30),
        const SizedBox(height: 8),
        Text(label),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _SongListItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
