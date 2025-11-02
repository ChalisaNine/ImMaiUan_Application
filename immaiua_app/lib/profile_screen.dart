import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.calendar_today_rounded),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 36,
          child: Image.asset('assets/immaiuan_logo.jpg', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
        ],
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: peach,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: const AssetImage('assets/avatar.jpg'),
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Monser',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.yellow.shade200,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                            'Edit',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _Metric(icon: Icons.fitness_center_rounded, label: 'Weight', value: '78 kg'),
                        _Metric(icon: Icons.height_rounded, label: 'height', value: '176 cm'),
                        _Metric(icon: Icons.monitor_weight_rounded, label: 'BMI', value: '26.1'),
                        _Metric(icon: Icons.local_fire_department_rounded, label: 'BMR', value: '2561'),
                        _Metric(icon: Icons.bolt_rounded, label: 'TDEE', value: '3564'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Goal (วงแหวนเทา + เสี้ยวส้มปลายมน)
              _Card(
                child: Row(
                  children: const [
                    _GoalProgressRing(
                      progress: 0.45,
                      size: 110,
                      strokeWidth: 10,
                      icon: Icons.directions_run,
                      label: 'progress',
                      percentText: '45%',
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Target weight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(height: 6),
                          _TargetWeightRow(fromText: '78 kg', toText: '65 kg'),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    _DaysColumn(days: '365 Days'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Nutrients received today (แคปซูลสีพีช)
              const Text('Nutrients received today', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              const _NutrientsPill(),

              const SizedBox(height: 16),

              // Allergy: หัวข้อ "อยู่ข้างบนกล่อง"
              const Text('Allergy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),

              // แถว: กล่องขอบน้ำเงิน + ปุ่ม Edit สีเหลืองอยู่นอกกล่อง
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E6BFF), width: 2),
                      ),
                      child: const Text("Cow's milk", style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD21F),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.black87),
                        SizedBox(width: 6),
                        Text('Edit', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),

      // FAB (คงเดิม)
      floatingActionButton: SizedBox(
        width: 68,
        height: 68,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 8,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.photo_camera_rounded, size: 26, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // NAV BAR (อัปเดตให้กด Home -> root, Profile -> หน้านี้)
      bottomNavigationBar: BottomAppBar(
        height: 84,
        color: peach,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _BottomItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: false,
                onTap: () {
                  // กลับไปหน้าแรก (root) โดยไม่ต้อง import main.dart
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              _BottomItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Meal',
                onTap: () {
                  // TODO: กำหนดพฤติกรรมของแท็บ Meal ตามแอปจริง
                },
              ),
              const Expanded(child: SizedBox()), // ช่องเว้น FAB ตรงกลาง
              _BottomItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: true, // อยู่หน้า Profile แล้ว
                onTap: () {
                  // อยู่หน้านี้แล้ว ไม่ต้อง push ซ้ำ
                },
              ),
              _BottomItem(
                icon: Icons.settings_rounded,
                label: 'Setting',
                onTap: () {
                  // TODO: กำหนดพฤติกรรมของแท็บ Setting ตามแอปจริง
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------- Nutrients Pill ---------------------------- */

class _NutrientsPill extends StatelessWidget {
  const _NutrientsPill();

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFE1C7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _NutrientCol(icon: Icons.cookie_rounded, title: 'Sugar',   percent: '40 %', remain: '18g. remain'),
          _NutrientCol(icon: Icons.rice_bowl_rounded, title: 'Carb',  percent: '20 %', remain: '18g. remain'),
          _NutrientCol(icon: Icons.egg_rounded,        title: 'Protein',percent: '33 %', remain: '88g. remain'),
          _NutrientCol(icon: Icons.oil_barrel_rounded, title: 'Fat',  percent: '66 %', remain: '10g. remain'),
          _NutrientCol(icon: Icons.ssid_chart_rounded, title: 'Sodium',percent: '98 %', remain: '200mg. remain', highlight: true),
        ],
      ),
    );
  }
}

class _NutrientCol extends StatelessWidget {
  const _NutrientCol({
    required this.icon,
    required this.title,
    required this.percent,
    required this.remain,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String percent;
  final String remain;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final percentStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: highlight ? const Color(0xFFE53935) : Colors.black87,
    );
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Icon(icon, size: 26, color: Colors.black87),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 2),
          Text(percent, style: percentStyle),
          Text(remain, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

/* ---------------------------- Helpers อื่น ๆ ---------------------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x11000000)),
        ],
      ),
      child: child,
    );
  }
}

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
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

/* ------------------- GOAL: progress ring + texts ------------------- */

class _GoalProgressRing extends StatelessWidget {
  const _GoalProgressRing({
    required this.progress,
    this.size = 110,
    this.strokeWidth = 10,
    this.icon = Icons.directions_run,
    this.label = 'progress',
    required this.percentText,
  });

  final double progress; // 0..1
  final double size;
  final double strokeWidth;
  final IconData icon;
  final String label;
  final String percentText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress.clamp(0, 1),
              strokeWidth: strokeWidth,
              trackColor: Colors.grey.shade300,
              progressColor: const Color(0xFFFF8C2E),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(percentText, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (sweep > 0) {
      canvas.drawArc(rect, startAngle, sweep, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

class _TargetWeightRow extends StatelessWidget {
  const _TargetWeightRow({required this.fromText, required this.toText});
  final String fromText;
  final String toText;

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF8C2E);
    return Row(
      children: [
        Text(fromText, style: const TextStyle(color: orange, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(width: 8),
        const Text('→', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(toText, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ],
    );
  }
}

class _DaysColumn extends StatelessWidget {
  const _DaysColumn({required this.days});
  final String days;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('Days', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 6),
        Text(days, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ],
    );
  }
}

/* --------------------- bottom bar item (interactive) --------------------- */

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    const inactive = Colors.black54;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? active : inactive),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? active : inactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
