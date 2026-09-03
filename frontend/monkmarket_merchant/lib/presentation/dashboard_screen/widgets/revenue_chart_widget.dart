import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../features/dashboard/models/revenue_data_point.dart';
import '../../../features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_skeleton_widget.dart';

class RevenueChartWidget extends ConsumerStatefulWidget {
  const RevenueChartWidget({super.key});

  @override
  ConsumerState<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends ConsumerState<RevenueChartWidget> {
  int _selectedDays = 14;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final chartHeight = isTablet ? 240.0 : 200.0;
    final analyticsAsync = ref.watch(revenueAnalyticsProvider);

    return Container(
      decoration: AppTheme.elevatedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Trend',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Last $_selectedDays days',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                _buildDayFilter(theme),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Chart
          analyticsAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LoadingSkeletonWidget(
                width: double.infinity,
                height: chartHeight,
                borderRadius: 12,
              ),
            ),
            error: (e, _) => _buildChartError(context, ref, chartHeight),
            data: (points) {
              if (points.isEmpty) {
                return SizedBox(
                  height: chartHeight,
                  child: const EmptyStateWidget(
                    icon: Icons.bar_chart_outlined,
                    title: 'No revenue data',
                    message: 'Revenue data will appear once orders are placed.',
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                child: SizedBox(
                  height: chartHeight,
                  child: _buildLineChart(context, points),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilter(ThemeData theme) {
    return Row(
      children: [7, 14, 30].map((days) {
        final isSelected = _selectedDays == days;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedDays = days);
            ref.read(revenueAnalyticsProvider.notifier).refresh();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${days}d',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartError(BuildContext context, WidgetRef ref, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Couldn\'t load revenue data.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(revenueAnalyticsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<RevenueDataPoint> points) {
    final theme = Theme.of(context);
    final primary = AppTheme.primary;
    final maxRevenue = points.isEmpty
        ? 1.0
        : points.map((p) => p.revenueInRupees).reduce((a, b) => a > b ? a : b);

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenueInRupees);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxRevenue / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.colorScheme.outlineVariant,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: maxRevenue / 4,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                final formatted = value >= 1000
                    ? '₹${(value / 1000).toStringAsFixed(0)}K'
                    : '₹${value.toStringAsFixed(0)}';
                return Text(
                  formatted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (points.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) {
                  return const SizedBox.shrink();
                }
                final date = points[idx].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('d MMM').format(date),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) {
            if (response?.lineBarSpots != null) {
              setState(() {
                _touchedIndex = response!.lineBarSpots!.first.spotIndex;
              });
            }
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.inverseSurface,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.spotIndex;
                if (idx < 0 || idx >= points.length) return null;
                final point = points[idx];
                return LineTooltipItem(
                  '₹${point.revenueInRupees.toStringAsFixed(0)}\n',
                  GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onInverseSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat('d MMM').format(point.date),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onInverseSurface.withAlpha(
                          179,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final isSelected = index == _touchedIndex;
                return FlDotCirclePainter(
                  radius: isSelected ? 5 : 3,
                  color: isSelected ? primary : Colors.white,
                  strokeColor: primary,
                  strokeWidth: 2,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [primary.withAlpha(51), primary.withAlpha(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxRevenue * 1.15,
      ),
    );
  }
}
