// ai_image.dart
import 'package:flutter/material.dart';
import 'camera_log.dart'; // ✅ เพิ่ม import

class AiImageScreen extends StatelessWidget {
  const AiImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const peachDeep = Color(0xFFFFA94D);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ---------- พรีวิวภาพ ----------
          Positioned.fill(
            child: Image.asset(
              'assets/sample_food.jpg', // TODO: เปลี่ยนเป็นสตรีมจากกล้อง/รูปที่ผู้ใช้เลือก
              fit: BoxFit.cover,
            ),
          ),

          // ---------- แถบบน ----------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _TopIconButton(
                    icon: Icons.calendar_today_rounded,
                    onTap: () {},
                  ),
                  const Spacer(),
                  // โลโก้ทรงกลมกลาง
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/immaiuan_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _TopIconButton(
                    icon: Icons.tune_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // ---------- เฟรมเล็ง + เครื่องหมายบวก ----------
          IgnorePointer(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.width * 0.78,
                child: CustomPaint(painter: _FocusFramePainter()),
              ),
            ),
          ),

          // ---------- สเกิร์ตไล่โทนด้านล่าง ----------
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54, Colors.black87],
                  ),
                ),
              ),
            ),
          ),

          // ---------- ปุ่มอัปโหลด ซ้ายล่าง ----------
          Positioned(
            left: 16,
            bottom: 90,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    // TODO: เปิดแกลเลอรี/กล้องเพื่อเลือกภาพ
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/sample_food.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'UPLOAD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ---------- ปุ่มรีเฟรช ขวาล่าง ----------
          Positioned(
            right: 16,
            bottom: 96,
            child: Material(
              color: peachDeep,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // TODO: รีโหลด/รีเซ็ต/สลับกล้อง
                },
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ),
          ),

          // ---------- ปุ่ม Capture กลมใหญ่กึ่งกลางล่าง ----------
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 78,
                height: 78,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 10,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      // ✅ เมื่อกดแล้วไปหน้า camera_log.dart
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraLogScreen(),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black87,
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Widgets / Painters ===================== */

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

/// วาดกรอบเล็งแบบ "มุมตัว L" + เครื่องหมายบวกกลาง
class _FocusFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLen = size.width * 0.16;
    const r = 14.0;

    // มุมซ้ายบน
    _drawCorner(canvas, cornerPaint, Offset(r, r), cornerLen, Corner.topLeft);
    // มุมขวาบน
    _drawCorner(canvas, cornerPaint, Offset(size.width - r, r), cornerLen, Corner.topRight);
    // มุมซ้ายล่าง
    _drawCorner(canvas, cornerPaint, Offset(r, size.height - r), cornerLen, Corner.bottomLeft);
    // มุมขวาล่าง
    _drawCorner(canvas, cornerPaint, Offset(size.width - r, size.height - r), cornerLen, Corner.bottomRight);

    // เครื่องหมายบวกกลาง
    final plusPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const plusLen = 16.0;
    canvas.drawLine(Offset(cx - plusLen, cy), Offset(cx + plusLen, cy), plusPaint);
    canvas.drawLine(Offset(cx, cy - plusLen), Offset(cx, cy + plusLen), plusPaint);
  }

  void _drawCorner(Canvas canvas, Paint p, Offset o, double len, Corner c) {
    final path = Path();
    switch (c) {
      case Corner.topLeft:
        path.moveTo(o.dx, o.dy + len);
        path.lineTo(o.dx, o.dy);
        path.lineTo(o.dx + len, o.dy);
        break;
      case Corner.topRight:
        path.moveTo(o.dx - len, o.dy);
        path.lineTo(o.dx, o.dy);
        path.lineTo(o.dx, o.dy + len);
        break;
      case Corner.bottomLeft:
        path.moveTo(o.dx, o.dy - len);
        path.lineTo(o.dx, o.dy);
        path.lineTo(o.dx + len, o.dy);
        break;
      case Corner.bottomRight:
        path.moveTo(o.dx - len, o.dy);
        path.lineTo(o.dx, o.dy);
        path.lineTo(o.dx, o.dy - len);
        break;
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum Corner { topLeft, topRight, bottomLeft, bottomRight }
