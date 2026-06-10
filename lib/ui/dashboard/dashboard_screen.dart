import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:jldb/jldb.dart';

import '../../view_model/dashboard/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataValue = ref.watch(dashboardViewModelProvider);
    return dataValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Fehler: $error')),
      data: (data) => _DashboardContent(data: data),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ActiveMemberCountCard(aktivCount: data.aktivCount),
                ),
                const SizedBox(width: 12),
                Expanded(child: LastEintragCard(lastEintrag: data.lastEintrag)),
                if (data.recentBirthdays.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: BirthdayWidget(birthdays: data.recentBirthdays),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: AttendanceChart(points: data.attendanceChart)),
        ],
      ),
    );
  }
}

class ActiveMemberCountCard extends StatelessWidget {
  final int aktivCount;

  const ActiveMemberCountCard({super.key, required this.aktivCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktive Mitglieder', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              '$aktivCount',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LastEintragCard extends StatelessWidget {
  final LastEintragSummary? lastEintrag;

  const LastEintragCard({super.key, this.lastEintrag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Letzter Eintrag', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (lastEintrag == null)
              Text(
                'Noch keine Einträge vorhanden.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                lastEintrag!.formattedDate,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(lastEintrag!.thema, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                lastEintrag!.kategorieName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastEintrag!.anwesenheitDisplay,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BirthdayWidget extends StatelessWidget {
  final List<BirthdayEntry> birthdays;

  const BirthdayWidget({super.key, required this.birthdays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('d.M.');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Geburtstage', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...birthdays.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.cake, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(b.name)),
                    Text(
                      fmt.format(b.birthDate),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceChart extends StatelessWidget {
  final List<AttendancePoint> points;

  const AttendanceChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return Card(
        child: Center(
          child: Text(
            'Noch keine Anwesenheitsdaten vorhanden.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anwesenheit (letzte 20 Einträge)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _AttendanceChartPainter(
                    points: points,
                    lineColor: theme.colorScheme.primary,
                    gridColor: theme.colorScheme.outlineVariant,
                    labelColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceChartPainter extends CustomPainter {
  final List<AttendancePoint> points;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  static const _leftMargin = 40.0;
  static const _bottomMargin = 28.0;
  static const _topMargin = 4.0;
  static const _rightMargin = 8.0;

  _AttendanceChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const chartLeft = _leftMargin;
    final chartRight = size.width - _rightMargin;
    const chartTop = _topMargin;
    final chartBottom = size.height - _bottomMargin;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final labelStyle = TextStyle(color: labelColor, fontSize: 10);

    // Horizontal grid lines at 0%, 25%, 50%, 75%, 100%
    for (final pct in [0, 25, 50, 75, 100]) {
      final y = chartBottom - (pct / 100) * chartHeight;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);
      _drawText(
        canvas,
        '$pct%',
        Offset(0, y - 6),
        labelStyle,
        _leftMargin - 4,
        TextAlign.right,
      );
    }

    // Vertical axis line
    canvas.drawLine(
      const Offset(chartLeft, chartTop),
      Offset(chartLeft, chartBottom),
      gridPaint,
    );

    // Sort points oldest→newest for left-to-right display
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final n = sorted.length;

    Offset toOffset(int i, double rate) {
      final x = n == 1
          ? chartLeft + chartWidth / 2
          : chartLeft + (i / (n - 1)) * chartWidth;
      final y = chartBottom - rate.clamp(0.0, 1.0) * chartHeight;
      return Offset(x, y);
    }

    // Line path
    final path = Path();
    for (var i = 0; i < n; i++) {
      final o = toOffset(i, sorted[i].attendanceRate);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Dots + date labels on every other point to avoid crowding
    for (var i = 0; i < n; i++) {
      final o = toOffset(i, sorted[i].attendanceRate);
      canvas.drawCircle(o, 3.5, dotPaint);
      if (i % math.max(1, n ~/ 5) == 0 || i == n - 1) {
        final dateLabel = DateFormat('d.M.').format(sorted[i].date);
        _drawText(
          canvas,
          dateLabel,
          Offset(o.dx - 16, chartBottom + 6),
          labelStyle,
          32,
          TextAlign.center,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    double maxWidth,
    TextAlign align,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_AttendanceChartPainter old) =>
      old.points != points ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor;
}
