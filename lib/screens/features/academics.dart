import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

Map<DateTime, List<T>> groupByDay<T>(List<T> items, DateTime Function(T) date) {
  final map = <DateTime, List<T>>{};
  for (final i in items) {
    map.putIfAbsent(DateUtils.dateOnly(date(i)), () => []).add(i);
  }
  return map;
}

class DayHeader extends StatelessWidget {
  const DayHeader(this.date, this.count, this.noun, {super.key});
  final DateTime date;
  final int count;
  final String noun;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        child: Row(children: [
          DateBadge(date),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(relDay(date) == 'Today' || relDay(date) == 'Yesterday' ? relDay(date) : weekday(date),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('${weekdayShort(date)}, ${fmtDate(date)} · $count $noun${count == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ]),
      );
}

// ---------------------------------------------------------------- Homework
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String filter = 'All';
  final shownTranslation = <String>{};

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    var list = s.homeworkFor(s.child.id);
    if (filter == 'Pending') list = list.where((h) => !h.done).toList();
    if (filter == 'Done') list = list.where((h) => h.done).toList();
    final groups = groupByDay(list, (h) => h.assigned);
    final all = s.homeworkFor(s.child.id);
    final done = all.where((h) => h.done).length;

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'homework'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Student diary',
          title: '$done of ${all.length} completed',
          subtitle: '${s.child.name} · ${s.child.classLabel}',
          bottom: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: all.isEmpty ? 0 : done / all.length,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
        gap(12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'All', label: Text('All')),
            ButtonSegment(value: 'Pending', label: Text('Pending')),
            ButtonSegment(value: 'Done', label: Text('Done')),
          ],
          selected: {filter},
          onSelectionChanged: (v) => setState(() => filter = v.first),
        ),
        if (list.isEmpty) const EmptyState(icon: Icons.celebration_outlined, title: 'Nothing here', message: 'No homework in this view.'),
        for (final g in groups.entries) ...[
          DayHeader(g.key, g.value.length, 'subject'),
          for (final h in g.value) ...[_homeworkCard(context, s, h), gap()],
        ],
      ]),
    );
  }

  Widget _homeworkCard(BuildContext context, AppState s, Homework h) {
    final color = AppColors.subject(h.subject);
    final overdue = !h.done && h.due.isBefore(today);
    final dueToday = !h.done && DateUtils.isSameDay(h.due, today);
    final translation = h.translations[s.lang];
    final showTr = shownTranslation.contains(h.id);
    return AppCard(
      accent: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(h.subject, color: color, icon: Icons.circle),
          const Spacer(),
          if (h.done) const Pill('Done', color: AppColors.green, icon: Icons.check)
          else if (overdue) Pill('Overdue · ${fmtShort(h.due)}', color: AppColors.red, icon: Icons.schedule)
          else if (dueToday) const Pill('Due today', color: AppColors.amber)
          else Pill('Due ${fmtShort(h.due)}', color: AppColors.slate),
        ]),
        const SizedBox(height: 10),
        Text(h.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, decoration: h.done ? TextDecoration.lineThrough : null)),
        const SizedBox(height: 4),
        Text(showTr && translation != null ? translation : h.details, style: const TextStyle(height: 1.4)),
        if (h.attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final f in h.attachments) FileChip(f)]),
        ],
        const SizedBox(height: 6),
        Row(children: [
          if (s.lang != 'en')
            TextButton.icon(
              onPressed: () {
                if (translation == null) {
                  toast(context, 'Auto-translation needs internet – queued', icon: Icons.translate);
                  return;
                }
                setState(() => showTr ? shownTranslation.remove(h.id) : shownTranslation.add(h.id));
              },
              icon: const Icon(Icons.translate, size: 18),
              label: Text(showTr ? 'Original' : tr(context, 'translate')),
            ),
          TextButton.icon(
            onPressed: () => toast(context, 'Reading aloud…', icon: Icons.volume_up),
            icon: const Icon(Icons.volume_up_outlined, size: 18),
            label: const Text('Listen'),
          ),
          const Spacer(),
          FilterChip(
            label: Text(h.done ? 'Completed' : 'Mark done'),
            selected: h.done,
            onSelected: (_) => s.toggleHomework(h),
          ),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Class work
class ClassWorkScreen extends StatelessWidget {
  const ClassWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final groups = groupByDay(s.classWorkFor(s.child.id), (c) => c.date);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'classwork'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'What was taught',
          title: tr(context, 'classwork'),
          subtitle: 'Know exactly what ${s.child.firstName} learnt today – and help revise at home.',
        ),
        for (final g in groups.entries) ...[
          DayHeader(g.key, g.value.length, 'subject'),
          for (final c in g.value) ...[
            AppCard(
              accent: AppColors.subject(c.subject),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Pill(c.subject, color: AppColors.subject(c.subject), icon: Icons.circle),
                const SizedBox(height: 8),
                Text(c.text, style: const TextStyle(height: 1.4)),
              ]),
            ),
            gap(),
          ],
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------- Timetable
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late int day = today.weekday == DateTime.sunday ? 1 : today.weekday;
  bool week = false;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = s.timetable[s.child.id]!;
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final teachers = <String, String>{};
    for (final d in tt.values) {
      for (final p in d) {
        if (!p.isBreak) teachers[p.subject] = p.teacher;
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'timetable'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Class schedule',
          title: tr(context, 'timetable'),
          subtitle: '${s.child.classLabel} · Class teacher ${s.child.classTeacher}',
          trailing: SegmentedButton<bool>(
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              selectedBackgroundColor: Colors.white,
              selectedForegroundColor: AppColors.indigo,
              visualDensity: VisualDensity.compact,
            ),
            showSelectedIcon: false,
            segments: const [ButtonSegment(value: false, label: Text('Day')), ButtonSegment(value: true, label: Text('Week'))],
            selected: {week},
            onSelectionChanged: (v) => setState(() => week = v.first),
          ),
        ),
        gap(12),
        if (!week) ...[
          Row(children: [
            for (int d = 1; d <= 6; d++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => day = d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: d == day ? Theme.of(context).colorScheme.primary : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(children: [
                        Text(weekdayShort(monday.add(Duration(days: d - 1))).toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: d == day ? Colors.white : null)),
                        Text('${monday.add(Duration(days: d - 1)).day}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: d == day ? Colors.white : null)),
                      ]),
                    ),
                  ),
                ),
              ),
          ]),
          gap(12),
          for (final (i, p) in tt[day]!.indexed) _periodTile(context, p, tt[day]!.take(i).where((x) => !x.isBreak).length + 1),
        ] else
          _WeekGrid(tt: tt),
        SectionTitle('Subject teachers'),
        AppCard(
          child: Column(children: [
            for (final e in teachers.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  CircleAvatar(radius: 5, backgroundColor: AppColors.subject(e.key)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.key)),
                  Text(e.value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.violet)),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _periodTile(BuildContext context, Period p, int number) {
    if (p.isBreak) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: Pill('${p.subject} · ${p.start} – ${p.end}',
              color: AppColors.amber, icon: p.subject.startsWith('Lunch') ? Icons.restaurant : Icons.local_cafe_outlined),
        ),
      );
    }
    final c = AppColors.subject(p.subject);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        accent: c,
        child: Row(children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Text('$number', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c)),
              Text('PERIOD', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: c)),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.start} – ${p.end} · 40 min', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(p.subject, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Row(children: [
                const Icon(Icons.person_outline, size: 14),
                const SizedBox(width: 4),
                Text(p.teacher, style: const TextStyle(fontSize: 12.5)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.tt});
  final Map<int, List<Period>> tt;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final periods = {for (final d in tt.keys) d: tt[d]!.where((p) => !p.isBreak).toList()};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(92),
        columnWidths: const {0: FixedColumnWidth(44)},
        children: [
          TableRow(children: [
            const SizedBox(),
            for (final d in days)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
          ]),
          for (int i = 0; i < 8; i++)
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text('P${i + 1}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              for (int d = 1; d <= 6; d++)
                Container(
                  margin: const EdgeInsets.all(3),
                  height: 46,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.subject(periods[d]![i].subject).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    periods[d]![i].subject,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.subject(periods[d]![i].subject)),
                  ),
                ),
            ]),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Calendar
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final upcoming = s.events.where((e) => !e.date.isBefore(today)).toList()..sort((a, b) => a.date.compareTo(b.date));
    final past = s.events.where((e) => e.date.isBefore(today)).toList()..sort((a, b) => b.date.compareTo(a.date));
    bool keep(SchoolEvent e) => filter == 'All' || e.type == filter;
    final next = upcoming.isEmpty ? null : upcoming.first;
    final byMonth = <String, List<SchoolEvent>>{};
    for (final e in upcoming.where(keep)) {
      byMonth.putIfAbsent(monthYear(e.date), () => []).add(e);
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'calendar'))),
      body: PageList(children: [
        if (next != null)
          GradientHeader(
            eyebrow: 'Next up · ${relDay(next.date)}',
            title: next.title,
            subtitle: '${weekday(next.date)}, ${fmtDate(next.date)}${next.days > 1 ? ' · ${next.days} days' : ''}',
            trailing: IconButton(
              onPressed: () => toast(context, 'Added to your phone calendar', icon: Icons.event_available),
              icon: const Icon(Icons.event_available, color: Colors.white),
            ),
          ),
        gap(12),
        Wrap(spacing: 8, children: [
          for (final f in ['All', 'Holiday', 'Exam', 'Event', 'PTM'])
            ChoiceChip(label: Text(f), selected: filter == f, onSelected: (_) => setState(() => filter = f)),
        ]),
        for (final m in byMonth.entries) ...[
          SectionTitle(m.key),
          for (final e in m.value) ...[_eventTile(context, e), gap()],
        ],
        if (past.where(keep).isNotEmpty) ...[
          const SectionTitle('Earlier this term'),
          for (final e in past.where(keep)) ...[Opacity(opacity: 0.6, child: _eventTile(context, e)), gap()],
        ],
      ]),
    );
  }

  Widget _eventTile(BuildContext context, SchoolEvent e) {
    final color = switch (e.type) {
      'Holiday' => AppColors.red,
      'Exam' => AppColors.violet,
      'PTM' => AppColors.teal,
      _ => AppColors.sky,
    };
    return AppCard(
      child: Row(children: [
        DateBadge(e.date, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Row(children: [
              Pill(e.type, color: color),
              const SizedBox(width: 6),
              Text('${weekdayShort(e.date)}${e.days > 1 ? ' · ${e.days} days' : ''}', style: const TextStyle(fontSize: 12)),
            ]),
            if (e.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.note, style: const TextStyle(fontSize: 12))),
          ]),
        ),
        Text(relDay(e.date), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ---------------------------------------------------------------- E-Content
class EContentScreen extends StatefulWidget {
  const EContentScreen({super.key});

  @override
  State<EContentScreen> createState() => _EContentScreenState();
}

class _EContentScreenState extends State<EContentScreen> {
  String subject = 'All';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final all = s.econtentFor(s.child.id);
    final subjects = ['All', ...{for (final e in all) e.subject}];
    final list = all
        .where((e) => subject == 'All' || e.subject == subject)
        .where((e) => query.isEmpty || e.title.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'econtent'))),
      body: PageList(children: [
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search notes, worksheets, videos'),
        ),
        gap(10),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final sub in subjects)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(sub), selected: subject == sub, onSelected: (_) => setState(() => subject = sub)),
              ),
          ]),
        ),
        gap(6),
        if (list.isEmpty) const EmptyState(icon: Icons.search_off, title: 'No matching content'),
        for (final e in list) ...[
          AppCard(
            accent: AppColors.subject(e.subject),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 6),
              Row(children: [
                Pill(e.subject, color: AppColors.subject(e.subject)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today_outlined, size: 13),
                const SizedBox(width: 4),
                Text(fmtDate(e.date), style: const TextStyle(fontSize: 12)),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final f in e.files) FileChip(f)]),
            ]),
          ),
          gap(),
        ],
      ]),
    );
  }
}
