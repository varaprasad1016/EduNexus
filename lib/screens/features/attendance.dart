import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

Color attColor(AttStatus? s) => switch (s) {
      AttStatus.present => AppColors.green,
      AttStatus.absent => AppColors.red,
      AttStatus.leave => AppColors.amber,
      AttStatus.holiday => const Color(0xFFCBD5E1),
      null => Colors.transparent,
    };

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime month = DateTime(today.year, today.month);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final map = s.attendance[s.child.id]!;
    final st = s.stats(s.child.id);
    final mStats = st.monthly[month] ?? [0, 0];
    final mPct = mStats[1] == 0 ? 0.0 : mStats[0] * 100 / mStats[1];
    final canPrev = month.isAfter(MockData.academicStart);
    final canNext = month.isBefore(DateTime(today.year, today.month));

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'attendance'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Annual attendance',
          title: '${st.percent.toStringAsFixed(1)}%',
          subtitle: 'Present on ${st.present} of ${st.working} working days',
          trailing: _ring(st.percent / 100),
          bottom: Row(children: [
            _headStat('${st.present}', 'Present'),
            _headStat('${st.absent}', 'Absent'),
            _headStat('${st.leave}', 'Leave'),
            _headStat('${st.working}', 'Working days'),
          ]),
        ),
        gap(12),
        if (st.percent < 75)
          const AppCard(
            accent: AppColors.red,
            child: Text('Attendance is below the 75% required by the board. Please contact the class teacher.'),
          )
        else
          AppCard(
            accent: AppColors.green,
            child: Row(children: [
              const Icon(Icons.verified, color: AppColors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(st.percent >= 90 ? 'Excellent attendance – keep it up!' : 'Good attendance – above the 75% requirement.')),
            ]),
          ),
        gap(12),
        Row(children: [
          Expanded(child: StatTile(label: 'Best month', value: st.bestMonth, icon: Icons.star_outline, color: AppColors.amber)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Longest streak', value: '${st.longestStreak} days', icon: Icons.bolt, color: AppColors.violet)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Most missed', value: st.worstWeekday, icon: Icons.event_busy, color: AppColors.red)),
        ]),
        gap(16),
        AppCard(
          child: Column(children: [
            Row(children: [
              IconButton(
                onPressed: canPrev ? () => setState(() => month = DateTime(month.year, month.month - 1)) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Column(children: [
                  Text(monthYear(month), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('${mStats[0]} present · ${mStats[1]} working days · ${mPct.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ]),
              ),
              IconButton(
                onPressed: canNext ? () => setState(() => month = DateTime(month.year, month.month + 1)) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ]),
            gap(8),
            MonthGrid(month: month, map: map),
            gap(12),
            Wrap(spacing: 14, runSpacing: 6, children: [
              _legend(AppColors.green, 'Present'),
              _legend(AppColors.red, 'Absent'),
              _legend(AppColors.amber, 'Leave'),
              _legend(const Color(0xFFCBD5E1), 'Holiday'),
            ]),
          ]),
        ),
        const SectionTitle('Month by month'),
        for (final e in st.monthly.entries.toList().reversed) ...[
          AppCard(
            onTap: () => setState(() => month = e.key),
            child: Row(children: [
              Expanded(child: Text(monthYear(e.key), style: const TextStyle(fontWeight: FontWeight.w700))),
              SizedBox(
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: e.value[1] == 0 ? 0 : e.value[0] / e.value[1],
                    minHeight: 8,
                    color: e.value[0] / (e.value[1] == 0 ? 1 : e.value[1]) >= 0.9 ? AppColors.green : AppColors.amber,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${e.value[1] == 0 ? 0 : (e.value[0] * 100 / e.value[1]).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
          gap(8),
        ],
      ]),
    );
  }

  Widget _ring(double v) => SizedBox(
        width: 64,
        height: 64,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: v, strokeWidth: 7, backgroundColor: Colors.white24, color: Colors.white),
          const Icon(Icons.how_to_reg, color: Colors.white),
        ]),
      );

  Widget _headStat(String v, String l) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ]),
      );

  Widget _legend(Color c, String l) => Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 5, backgroundColor: c),
        const SizedBox(width: 5),
        Text(l, style: const TextStyle(fontSize: 12)),
      ]);
}

class MonthGrid extends StatelessWidget {
  const MonthGrid({super.key, required this.month, required this.map});
  final DateTime month;
  final Map<DateTime, AttStatus> map;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final lead = first.weekday - 1;
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();
    const heads = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(children: [
      Row(children: [
        for (final h in heads)
          Expanded(child: Center(child: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))),
      ]),
      gap(6),
      for (int r = 0; r < rows; r++)
        Row(children: [
          for (int c = 0; c < 7; c++)
            Expanded(
              child: Builder(builder: (context) {
                final idx = r * 7 + c - lead + 1;
                if (idx < 1 || idx > daysInMonth) return const SizedBox(height: 40);
                final d = DateTime(month.year, month.month, idx);
                final st = map[d];
                final isToday = DateUtils.isSameDay(d, today);
                final filled = st == AttStatus.present || st == AttStatus.absent || st == AttStatus.leave;
                return Container(
                  height: 36,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: filled ? attColor(st) : (st == AttStatus.holiday ? attColor(st).withValues(alpha: 0.4) : null),
                    shape: BoxShape.circle,
                    border: isToday ? Border.all(color: AppColors.saffron, width: 2.5) : null,
                  ),
                  child: Text(
                    '$idx',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: filled ? Colors.white : (d.isAfter(today) ? Theme.of(context).colorScheme.outline : null),
                    ),
                  ),
                );
              }),
            ),
        ]),
    ]);
  }
}
