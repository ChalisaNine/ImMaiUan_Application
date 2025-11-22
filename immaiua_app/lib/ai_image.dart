import 'package:flutter/material.dart';

import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'Calenda.dart';
import 'profile_screen.dart';
import 'camera_log.dart';

class AiImageScreen extends StatefulWidget {
  const AiImageScreen({super.key});

  @override
  State<AiImageScreen> createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  int _index = 2; // Capture tab

  void _onTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainHomeScreen()));
        break;

      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MealScreen()));
        break;

      case 2: // ⭐ ปุ่มกล้องสีน้ำตาล (กลาง NavBar)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraLogScreen()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CalendaScreen()));
        break;

      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: const _CameraBody(),
    );
  }
}

/* ========================================================================= */
/*                                CAMERA BODY                                */
/* ========================================================================= */

class _CameraBody extends StatelessWidget {
  const _CameraBody();

  @override
  Widget build(BuildContext context) {
    const peachDeep = Color(0xFFFFA94D);

    return Stack(
      children: [
        // ---------- พรีวิวภาพ ----------
        Positioned.fill(
          child: Image.asset(
            'assets/sample_food.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // ---------- วงกลมเล็ง ----------
        IgnorePointer(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              height: MediaQuery.of(context).size.width * 0.70,
              child: CustomPaint(painter: _FocusRingPainter()),
            ),
          ),
        ),

        // ---------- Gradient ล่าง ----------
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black45,
                    Colors.black87
                  ],
                ),
              ),
            ),
          ),
        ),

        // ---------- Upload ----------
        Positioned(
          left: 20,
          bottom: 110,
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
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
                "UPLOAD",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),

        // ---------- Refresh ----------
        Positioned(
          right: 20,
          bottom: 118,
          child: Material(
            color: peachDeep,
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 54,
                height: 54,
                child: Icon(Icons.refresh_rounded,
                    size: 28, color: Colors.white),
              ),
            ),
          ),
        ),

        // ⭐ ไม่มีปุ่มกล้องบนอีกแล้ว (ลบออก)
      ],
    );
  }
}

/* ========================================================================= */
/*                            CAMERA FOCUS RING                              */
/* ========================================================================= */

class _FocusRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = Paint()
      ..color = Colors.white24
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final inner = Paint()
      ..color = Colors.white38
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final r = size.width / 2;

    canvas.drawCircle(Offset(r, r), r, outer);
    canvas.drawCircle(Offset(r, r), r * 0.75, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
