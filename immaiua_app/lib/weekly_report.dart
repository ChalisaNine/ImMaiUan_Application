import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'main.dart';
import 'Meal.dart';
import 'Calenda.dart';
import 'profile_screen.dart';
import 'ai_image.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:intl/intl.dart';
import 'services/auth_service.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  int _index = 3; // Diary tab

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _analyticsData;
  final AuthService _authService = AuthService();
  int _touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    _authService.init().then((_) => _fetchAnalytics());
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final response = await _authService.getWeeklyAnalytics(dateStr);

      if (response.statusCode == 200) {
        setState(() {
          _analyticsData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load Analytics: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onTap(int i) {
    setState(() => _index = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MealScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AiImageScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendaScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: _index,
      onTap: _onTap,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final progress = _analyticsData?['progress'] ?? {};
    final bmiProgress = progress['bmi'] ?? {};
    final tdeeProgress = progress['tdee'] ?? {};
    final bmrProgress = progress['bmr'] ?? {};
    final weightProgress = progress['weight_kg'] ?? {};

    final startDateStr = _analyticsData?['start_date'] ?? "";
    final endDateStr = _analyticsData?['end_date'] ?? "";

    // Formatting helper
    String formatVal(dynamic val) => val?.toString() ?? "0";
    String formatDiff(dynamic diff) {
      final val = diff is num
          ? diff.toDouble()
          : double.tryParse(diff?.toString() ?? "0") ?? 0;
      return val > 0 ? "+${val.toStringAsFixed(2)}" : val.toStringAsFixed(2);
    }

    final totalIntake = formatVal(_analyticsData?['total_intake_kcal']);
    final totalDeficit = formatVal(_analyticsData?['total_deficit_kcal']);
    final isDeficitHarmful =
        (_analyticsData?['total_deficit_kcal'] ?? 0) < -7000;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Color(0xFFD68A1A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$startDateStr  -  $endDateStr",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFFD68A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Health Metric",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF2D3142),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // ================= METRIC TABLE =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _metricRowTitle(startDateStr, endDateStr),
                const Divider(),
                _metricRow(
                  "BMI",
                  formatVal(bmiProgress['old']),
                  formatVal(bmiProgress['new']),
                  formatDiff(bmiProgress['diff']),
                ),
                _metricRow(
                  "TDEE",
                  formatVal(tdeeProgress['old']),
                  formatVal(tdeeProgress['new']),
                  formatDiff(tdeeProgress['diff']),
                ),
                _metricRow(
                  "BMR",
                  formatVal(bmrProgress['old']),
                  formatVal(bmrProgress['new']),
                  formatDiff(bmrProgress['diff']),
                ),
                _metricRow(
                  "Weight",
                  formatVal(weightProgress['old']),
                  formatVal(weightProgress['new']),
                  formatDiff(weightProgress['diff']),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= SUMMARY BOX =================
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 85,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD57F), Color(0xFFFFC059)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFC059).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.local_dining_rounded,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalIntake,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        "Intake (kcal)",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 85,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9E5E), Color(0xFFFF7A22)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7A22).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        (double.tryParse(totalDeficit) ?? 0) <= 0
                            ? Icons.trending_down_rounded
                            : Icons.trending_up_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalDeficit,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        "Deficit/Surplus",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ================= WARNING BOX =================
          if (isDeficitHarmful)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                border: Border.all(color: const Color(0xFFFFB3B3), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.red, size: 26),
                      SizedBox(width: 8),
                      Text(
                        "WARNING",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Harmful, big gap of deficit.\n"
                    "Having a weekly deficit of $totalDeficit kcal\n"
                    "is too much and can harm your body.\n"
                    "Please consult a health professional.",
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          const Text(
            "Weight Graph",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF2D3142),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // ================= WEIGHT GRAPH =================
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(
              right: 22,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildWeightChart(),
          ),

          const SizedBox(height: 18),

          const Text(
            "Calorie Intake",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Color(0xFF2D3142),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // ================= CALORIE GRAPH =================
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(
              right: 22,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildCalorieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    final dailyBreakdown = _analyticsData?['daily_breakdown'] as List? ?? [];
    if (dailyBreakdown.isEmpty) {
      return const Center(
        child: Text(
          "No weight data available for this week.",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    // Extract valid weight points
    final List<FlSpot> spots = [];
    double minWeight = double.infinity;
    double maxWeight = 0;

    for (int i = 0; i < dailyBreakdown.length; i++) {
      final dayData = dailyBreakdown[i];
      final weight = (dayData['weight_kg'] as num?)?.toDouble() ?? 0.0;
      if (weight > 0) {
        spots.add(FlSpot(i.toDouble(), weight));
        if (weight < minWeight) minWeight = weight;
        if (weight > maxWeight) maxWeight = weight;
      }
    }

    if (spots.isEmpty) {
      return const Center(
        child: Text(
          "No valid weight data logged.",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    // Add some padding to Y axis min/max so graph line doesn't hug the very edge boundaries
    final minY = (minWeight - 2).floorToDouble();
    final maxY = (maxWeight + 2).ceilToDouble();

    return LineChart(
      LineChartData(
        minY: minY < 0 ? 0 : minY,
        maxY: maxY,
        minX: 0,
        maxX: 6,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFFFA35B),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFFFA35B).withValues(alpha: 0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          // Left Titles (Weight values)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                );
              },
            ),
          ),
          // Bottom Titles (Days)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailyBreakdown.length) {
                  return const SizedBox.shrink();
                }

                final dateStr = dailyBreakdown[index]['date'] as String?;
                if (dateStr == null) {
                  return const SizedBox.shrink();
                }

                // Convert "2025-09-19" safely to just "19" or "Sep 19"
                DateTime? dateObj;
                try {
                  dateObj = DateTime.parse(dateStr);
                } catch (_) {}

                String label = "";
                if (dateObj != null) {
                  final now = DateTime.now();
                  if (dateObj.year == now.year && dateObj.month == now.month && dateObj.day == now.day) {
                    label = "Today";
                  } else {
                    label = DateFormat('E').format(dateObj);
                  }
                } else {
                  label = "D${index + 1}";
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ======================== TABLE TITLE ROW ========================
  Widget _metricRowTitle(String start, String end) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              "Metric",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              start,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              end,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Expanded(child: Text("Progress", textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ======================== TABLE DATA ROW ========================
  Widget _metricRow(String metric, String oldV, String newV, String progress) {
    final isPositive = progress.contains("+");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(oldV, textAlign: TextAlign.center)),
          Expanded(child: Text(newV, textAlign: TextAlign.center)),
          Expanded(
            child: Text(
              progress,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart() {
    final dailyBreakdown = _analyticsData?['daily_breakdown'] as List? ?? [];
    if (dailyBreakdown.isEmpty) {
      return const Center(
        child: Text(
          "No calorie data available for this week.",
          style: TextStyle(color: Colors.black45),
        ),
      );
    }

    final List<BarChartGroupData> barGroups = [];
    double maxCal = 0;

    for (int i = 0; i < dailyBreakdown.length; i++) {
      final dayData = dailyBreakdown[i];
      final cal = (dayData['intake_kcal'] as num?)?.toDouble() ?? 0.0;
      if (cal > maxCal) maxCal = cal;
      
      final isTouched = i == _touchedBarIndex;

      barGroups.add(
        BarChartGroupData(
          x: i,
          showingTooltipIndicators: isTouched ? [0] : [],
          barRods: [
            BarChartRodData(
              toY: cal,
              color: const Color(0xFFFFD57F),
              width: 16,
              borderSide: isTouched 
                  ? const BorderSide(color: Color(0xFFD68A1A), width: 1.5) 
                  : const BorderSide(color: Colors.transparent, width: 0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    final maxY = (maxCal + 500).ceilToDouble();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent) {
              setState(() {
                if (barTouchResponse == null ||
                    barTouchResponse.spot == null) {
                  _touchedBarIndex = -1;
                  return;
                }
                final touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                if (_touchedBarIndex == touchedIndex) {
                  _touchedBarIndex = -1; // Untoggle if clicked again
                } else {
                  _touchedBarIndex = touchedIndex; // Toggle on
                }
              });
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.black87,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} kcal',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dailyBreakdown.length) {
                  return const SizedBox.shrink();
                }
                final dateStr = dailyBreakdown[index]['date'] as String?;
                if (dateStr == null) return const SizedBox.shrink();
                DateTime? dateObj;
                try {
                  dateObj = DateTime.parse(dateStr);
                } catch (_) {}
                
                String label = "";
                if (dateObj != null) {
                  final now = DateTime.now();
                  if (dateObj.year == now.year && dateObj.month == now.month && dateObj.day == now.day) {
                    label = "Today";
                  } else {
                    label = DateFormat('E').format(dateObj);
                  }
                } else {
                  label = "D${index + 1}";
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
