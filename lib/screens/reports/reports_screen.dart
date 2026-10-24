import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock moisture data
  final _moistureData = [
    FlSpot(0, 68),
    FlSpot(1, 72),
    FlSpot(2, 55),
    FlSpot(3, 80),
    FlSpot(4, 74),
    FlSpot(5, 70),
    FlSpot(6, 76),
  ];

  // Mock water usage data
  final _waterUsageData = [
    FlSpot(0, 120),
    FlSpot(1, 200),
    FlSpot(2, 150),
    FlSpot(3, 250),
    FlSpot(4, 180),
    FlSpot(5, 210),
    FlSpot(6, 160),
  ];

  // Mock fertigation data
  final _fertigationData = [
    FlSpot(0, 30),
    FlSpot(1, 0),
    FlSpot(2, 0),
    FlSpot(3, 45),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 40),
  ];

  final _statCards = [
    _StatCard(
      label: 'Total Water',
      value: '1,270',
      unit: 'L',
      icon: Icons.water_drop_rounded,
      color: AppColors.accentBlue,
      trend: '+12%',
      trendUp: true,
    ),
    _StatCard(
      label: 'Irrigation Time',
      value: '4.2',
      unit: 'hrs',
      icon: Icons.timer_rounded,
      color: AppColors.primary,
      trend: '-8%',
      trendUp: false,
    ),
    _StatCard(
      label: 'Fertigation Time',
      value: '0.8',
      unit: 'hrs',
      icon: Icons.eco_rounded,
      color: AppColors.primaryLight,
      trend: '+5%',
      trendUp: true,
    ),
    _StatCard(
      label: 'Avg Soil Moisture',
      value: '71.4',
      unit: '%',
      icon: Icons.grass_rounded,
      color: AppColors.accentTeal,
      trend: '+3%',
      trendUp: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports', style: AppTextStyles.headlineLarge),
                      Text(
                        'Farm performance & water usage',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Export button
                  TextButton.icon(
                    onPressed: _export,
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Export',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Period tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.primary),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: AppTextStyles.labelLarge,
                  tabs: const [
                    Tab(text: 'Daily'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ReportContent(
                    statCards: _statCards,
                    moistureData: _moistureData,
                    waterUsageData: _waterUsageData,
                    fertigationData: _fertigationData,
                    xLabels: const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ],
                  ),
                  _ReportContent(
                    statCards: _statCards,
                    moistureData: _moistureData,
                    waterUsageData: _waterUsageData,
                    fertigationData: _fertigationData,
                    xLabels: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
                  ),
                  _ReportContent(
                    statCards: _statCards,
                    moistureData: _moistureData,
                    waterUsageData: _waterUsageData,
                    fertigationData: _fertigationData,
                    xLabels: const [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _export() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Report', style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Export as PDF',
              icon: Icons.picture_as_pdf_rounded,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Export as CSV',
              icon: Icons.table_chart_rounded,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final List<_StatCard> statCards;
  final List<FlSpot> moistureData;
  final List<FlSpot> waterUsageData;
  final List<FlSpot> fertigationData;
  final List<String> xLabels;

  const _ReportContent({
    required this.statCards,
    required this.moistureData,
    required this.waterUsageData,
    required this.fertigationData,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.95,
            ),
            itemCount: statCards.length,
            itemBuilder: (_, i) => _StatCardWidget(card: statCards[i]),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Soil moisture chart
          _ChartCard(
            title: 'Soil Moisture Trend',
            icon: TablerIcons.droplets,
            color: AppColors.accentBlue,
            child: _LineChart(
              data: moistureData,
              color: AppColors.accentBlue,
              xLabels: xLabels,
              yUnit: '%',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Water usage chart
          _ChartCard(
            title: 'Water Usage',
            icon: TablerIcons.fountain_filled,
            color: AppColors.primary,
            child: _BarChart(
              data: waterUsageData,
              color: AppColors.primary,
              xLabels: xLabels,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Fertigation chart
          _ChartCard(
            title: 'Fertigation Usage',
            icon: TablerIcons.relation_many_to_many,
            color: AppColors.primaryLight,
            child: _BarChart(
              data: fertigationData,
              color: AppColors.primaryLight,
              xLabels: xLabels,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _StatCardWidget extends StatelessWidget {
  final _StatCard card;
  const _StatCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              //Icon(card.icon, color: card.color, size: 16),
              Text(
                card.label,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (card.trendUp ? AppColors.success : AppColors.error)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      card.trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color: card.trendUp ? AppColors.success : AppColors.error,
                    ),
                    Text(
                      card.trend,
                      style: AppTextStyles.caption.copyWith(
                        color: card.trendUp
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' ${card.unit}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              /*Text(
                card.label,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),*/
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(height: 180, child: child),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<FlSpot> data;
  final Color color;
  final List<String> xLabels;
  final String yUnit;

  const _LineChart({
    required this.data,
    required this.color,
    required this.xLabels,
    required this.yUnit,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.borderColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= xLabels.length) return const SizedBox();
                return Text(xLabels[i], style: AppTextStyles.bodySmall);
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) =>
                  Text('${v.toInt()}$yUnit', style: AppTextStyles.bodySmall),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: FlDotData(
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeColor: AppColors.black,
                strokeWidth: 1.5,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<FlSpot> data;
  final Color color;
  final List<String> xLabels;

  const _BarChart({
    required this.data,
    required this.color,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.borderColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= xLabels.length) return const SizedBox();
                return Text(xLabels[i], style: AppTextStyles.bodySmall);
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: AppTextStyles.bodySmall),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.map((spot) {
          return BarChartGroupData(
            x: spot.x.toInt(),
            barRods: [
              BarChartRodData(
                toY: spot.y,
                color: color,
                width: 18,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY:
                      data.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 20,
                  color: color.withOpacity(0.06),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard {
  final String label, value, unit, trend;
  final IconData icon;
  final Color color;
  final bool trendUp;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
  });
}
