import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const peach = Color(0xFFFFE1C7);
    const accent = Color(0xFFFFC94D); // สีเหลืองวงแหวน

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_rounded),
        ),
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Image.asset(
            'assets/immaiuan_logo.jpg',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // วันที่
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_month_rounded, size: 18),
                SizedBox(width: 6),
                Text(
                  'Monday 21 Feb 2026',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // วงแหวน cal เหลือง
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงแหวนพื้นหลังเทาอ่อน
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 26,
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFFEFEFEF)),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // วงเหลือง (สมมุติว่าใช้ไปบางส่วน)
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 0.45, // เปอร์เซนต์ที่ใช้ไป (ลองปรับได้)
                        strokeWidth: 26,
                        valueColor:
                            const AlwaysStoppedAnimation(accent),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    // ตัวหนังสือกลางวง
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '2181 cal.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'remaining today',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    // Label รอบวง (Breakfast / Lunch / Snack / Dinner)
                    Positioned(
                      top: 18,
                      child: _RingLabel('Lunch'),
                    ),
                    Positioned(
                      bottom: 18,
                      child: _RingLabel('Dinner'),
                    ),
                    Positioned(
                      left: 10,
                      child: _RingLabel('Snack', rotate: -1.2),
                    ),
                    Positioned(
                      right: 10,
                      child: _RingLabel('Breakfast', rotate: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // การ์ดตรงกลาง (น้ำหนัก ส่วนสูง, Cal intake/burn, BMI/TDEE/BMR)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // แถวบน: Weight / Height / Cal intake
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '78 kg.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Height',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '176 cm.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: ไปหน้า edit profile
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC27A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 90,
                          color: const Color(0xFFE5E5E5),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Calorie intake',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.restaurant_rounded,
                                      size: 18, color: Colors.black87),
                                  SizedBox(width: 6),
                                  Text(
                                    '500',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'kcal',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Burned calories',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.local_fire_department_rounded,
                                      size: 18, color: Colors.orange),
                                  SizedBox(width: 6),
                                  Text(
                                    '1450',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'kcal',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // แถบสีส้ม BMI/TDEE/BMR
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    color: const Color(0xFFFFC680),
                    child: Row(
                      children: const [
                        Expanded(
                          child: _BmiBox(
                            title: 'BMI 24.4',
                            subtitle: 'Overweight',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _BmiBox(
                            title: 'TDEE',
                            subtitle: '3582 kcal',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _BmiBox(
                            title: 'BMR',
                            subtitle: '2452 kcal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // การ์ด Macronutrient เหลืองอ่อนด้านล่าง
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: peach,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _MacroItem(
                    icon: Icons.cake_rounded,
                    label: 'Sugar',
                    percent: '40 %',
                    remain: '18g. remain',
                  ),
                  _MacroItem(
                    icon: Icons.rice_bowl_rounded,
                    label: 'Carb',
                    percent: '20 %',
                    remain: '18g. remain',
                  ),
                  _MacroItem(
                    icon: Icons.egg_rounded,
                    label: 'Protein',
                    percent: '33 %',
                    remain: '18g. remain',
                  ),
                  _MacroItem(
                    icon: Icons.local_pizza_rounded,
                    label: 'Fat',
                    percent: '66 %',
                    remain: '10g. remain',
                  ),
                  _MacroItem(
                    icon: Icons.bolt_rounded,
                    label: 'Sodium',
                    percent: '98 %',
                    remain: '200mg. remain',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ====================== Helper widgets ====================== */

class _RingLabel extends StatelessWidget {
  final String text;
  final double rotate; // radians

  const _RingLabel(this.text, {this.rotate = 0, super.key});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
    if (rotate == 0) return child;
    return Transform.rotate(
      angle: rotate,
      child: child,
    );
  }
}

class _BmiBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BmiBox({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String percent;
  final String remain;

  const _MacroItem({
    required this.icon,
    required this.label,
    required this.percent,
    required this.remain,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            remain,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
