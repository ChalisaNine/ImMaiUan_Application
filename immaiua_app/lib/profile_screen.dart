import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7),

      // ❗ ไม่มี AppBar เพื่อไม่ให้ซ้อนกับ main.dart
      appBar: null,

      body: _ProfileBody(),
    );
  }
}

/* ────────────────────────────────────────────────────────────── */
/*                         PROFILE BODY                           */
/* ────────────────────────────────────────────────────────────── */

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return SafeArea(
      top: false, // ใช้ AppBar จาก main.dart
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            /* -------------------- PROFILE CARD -------------------- */
            Container(
              decoration: BoxDecoration(
                color: peach,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: const CircleAvatar(
                      radius: 41,
                      backgroundImage: AssetImage('assets/avatar.jpg'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Monser",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),

                  const SizedBox(height: 8),

                  FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.yellow.shade300,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.black87),
                        SizedBox(width: 6),
                        Text(
                          "Edit",
                          style: TextStyle(
                              color: Colors.black87, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _Metric(icon: Icons.fitness_center, label: "Weight", value: "78 kg"),
                      _Metric(icon: Icons.height, label: "height", value: "176 cm"),
                      _Metric(icon: Icons.monitor_weight, label: "BMI", value: "26.1"),
                      _Metric(icon: Icons.local_fire_department, label: "BMR", value: "2561"),
                      _Metric(icon: Icons.bolt, label: "TDEE", value: "3564"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /* -------------------- PERSONAL INFO -------------------- */
            _SettingCard(
              items: const [
                _SettingItem(icon: Icons.person, title: "Personal details"),
                _SettingItem(icon: Icons.flag, title: "Adjust goal"),
                _SettingItem(icon: Icons.settings, title: "Setting"),
              ],
            ),

            const SizedBox(height: 16),

            /* -------------------- SUPPORT + VERSION -------------------- */
            _SettingCard(
              items: const [
                _SettingItem(icon: Icons.mail_rounded, title: "Support"),
                _SettingItem(
                    icon: Icons.tag_rounded, title: "Version", trailing: "1.0"),
              ],
            ),

            const SizedBox(height: 22),

            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: peach,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.black87),
                  SizedBox(width: 8),
                  Text("Logout", style: TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ────────────────────────────────────────────────────────────── */
/*                       SMALL WIDGETS                            */
/* ────────────────────────────────────────────────────────────── */

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFA94D);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.items});
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
