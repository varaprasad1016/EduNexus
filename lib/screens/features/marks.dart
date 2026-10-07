import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  String batch = '${MockData.academicStart.year}-${MockData.academicStart.year + 1}';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final results = s.resultsFor(s.child.id);
    final y = MockData.academicStart.year;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'marks'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Admit cards, report cards & tests',
          title: tr(context, 'marks'),
          bottom: DropdownButtonFormField<String>(
            initialValue: batch,
            decoration: const InputDecoration(labelText: 'Academic year', isDense: true),
            items: [
              for (final b in ['$y-${y + 1}', '${y - 1}-$y']) DropdownMenuItem(value: b, child: Text(b)),
            ],
            onChanged: (v) => setState(() => batch = v!),
          ),
        ),
        if (!batch.startsWith('$y'))
          const EmptyState(icon: Icons.history, title: 'Previous year', message: 'Archived report cards are available as PDF downloads.')
        else ...[
          const SectionTitle('Admit card'),
          AppCard(
            child: Row(children: [
              const CircleAvatar(child: Icon(Icons.badge_outlined)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Formative Assessment 2', style: TextStyle(fontWeight: FontWeight.w800)),
                  Text('Hall ticket · seat & room details', style: TextStyle(fontSize: 12)),
                ]),
              ),
              FilledButton.tonalIcon(
                onPressed: () => toast(context, 'Admit card saved to Downloads', icon: Icons.download_done),
                icon: const Icon(Icons.download),
                label: const Text('PDF'),
              ),
            ]),
          ),
          SectionTitle('Results', action: 'Holistic report card', onAction: () => push(context, const ReportCardScreen())),
          if (results.isEmpty)
            const EmptyState(icon: Icons.hourglass_empty, title: 'Results coming soon', message: 'Report cards appear here as soon as they are published.'),
          for (final r in results) ...[_ResultCard(r: r), gap()],
          const SectionTitle('Online tests'),
          AppCard(
            onTap: () => push(context, const OnlineTestsScreen()),
            child: const Row(children: [
              CircleAvatar(child: Icon(Icons.quiz_outlined)),
              SizedBox(width: 12),
              Expanded(child: Text('Online test results\nScores and answers of your online tests')),
              Icon(Icons.chevron_right),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.r});
  final ExamResult r;

  String grade(double pct) => pct >= 91
      ? 'A1'
      : pct >= 81
          ? 'A2'
          : pct >= 71
              ? 'B1'
              : pct >= 61
                  ? 'B2'
                  : pct >= 51
                      ? 'C1'
                      : 'C2';

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.exam, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text('${fmtDate(r.date)} · out of ${r.max} per subject', style: TextStyle(fontSize: 12, color: muted)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${r.percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.violet)),
            Pill('Grade ${grade(r.percent)}', color: AppColors.green),
          ]),
        ]),
        gap(14),
        for (final e in r.marks.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text('${e.value}/${r.max}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 4),
              LayoutBuilder(builder: (context, c) {
                final avg = r.classAvg[e.key];
                return Stack(clipBehavior: Clip.none, children: [
                  Container(height: 10, decoration: BoxDecoration(color: muted.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6))),
                  Container(
                    height: 10,
                    width: c.maxWidth * e.value / r.max,
                    decoration: BoxDecoration(color: AppColors.subject(e.key), borderRadius: BorderRadius.circular(6)),
                  ),
                  if (avg != null)
                    Positioned(
                      left: c.maxWidth * avg / r.max - 1,
                      top: -3,
                      child: Container(width: 2.5, height: 16, color: Theme.of(context).colorScheme.onSurface),
                    ),
                ]);
              }),
            ]),
          ),
        Row(children: [
          Container(width: 2.5, height: 12, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 6),
          Text('Class average', style: TextStyle(fontSize: 12, color: muted)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => toast(context, 'Report card PDF downloaded', icon: Icons.download_done),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Download'),
          ),
        ]),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Holistic Progress Card (NEP 2020)
class ReportCardScreen extends StatelessWidget {
  const ReportCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    const domains = [
      ['Cognitive', 'Understands concepts and applies them in new situations.', 'Proficient', 0.85],
      ['Socio-emotional', 'Works well in groups; shows empathy towards peers.', 'Advanced', 0.92],
      ['Physical', 'Active in swimming and sports; good coordination.', 'Proficient', 0.8],
      ['Creativity', 'Original ideas in art and Scratch projects.', 'Advanced', 0.9],
      ['Language', 'Reads fluently in English; improving Hindi writing.', 'Developing', 0.68],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Holistic Progress Card')),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'NEP 2020 · PARAKH aligned',
          title: c.name,
          subtitle: '${c.classLabel} · Term 1 · ${MockData.schoolName}',
        ),
        const SectionTitle('Domains of development'),
        for (final d in domains) ...[
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(d[0] as String, style: const TextStyle(fontWeight: FontWeight.w800))),
                Pill(d[2] as String,
                    color: d[2] == 'Advanced'
                        ? AppColors.green
                        : d[2] == 'Proficient'
                            ? AppColors.sky
                            : AppColors.amber),
              ]),
              gap(6),
              LinearProgressIndicator(value: d[3] as double, minHeight: 6, borderRadius: BorderRadius.circular(4)),
              gap(6),
              Text(d[1] as String),
            ]),
          ),
          gap(8),
        ],
        const SectionTitle('Self & peer assessment'),
        const AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('"I enjoyed building the Scratch maze game. I want to get better at Hindi spellings."',
                style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 8),
            Text('Peer: "Aarav helps others when they are stuck in maths."', style: TextStyle(fontSize: 13)),
          ]),
        ),
        const SectionTitle('Teacher\'s remarks'),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${c.firstName} is curious, confident and a keen problem-solver. Encourage 15 minutes of Hindi reading at home daily.'),
            gap(8),
            Row(children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.violet),
              const SizedBox(width: 6),
              Text('Draft by AI · reviewed by ${c.classTeacher}', style: const TextStyle(fontSize: 12)),
            ]),
          ]),
        ),
        gap(16),
        FilledButton.icon(
          onPressed: () => toast(context, 'Holistic Progress Card PDF downloaded', icon: Icons.download_done),
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Online tests
class OnlineTestsScreen extends StatelessWidget {
  const OnlineTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final pending = s.quizzes.where((q) => q.score == null).toList();
    final done = s.quizzes.where((q) => q.score != null).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'onlineTest'))),
      body: PageList(children: [
        const SectionTitle('Available now'),
        if (pending.isEmpty) const EmptyState(icon: Icons.task_alt, title: 'No tests scheduled'),
        for (final q in pending) ...[
          AppCard(
            accent: AppColors.subject(q.subject),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${q.subject} · ${q.questions.length} questions · ${q.minutes} min', style: const TextStyle(fontSize: 12.5)),
                ]),
              ),
              FilledButton(onPressed: () => push(context, QuizScreen(quiz: q)), child: const Text('Start')),
            ]),
          ),
          gap(),
        ],
        const SectionTitle('Completed'),
        for (final q in done) ...[
          AppCard(
            onTap: () => push(context, QuizScreen(quiz: q)),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: AppColors.green.withValues(alpha: 0.15),
                child: Text('${q.score}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${q.subject} · scored ${q.score}/${q.questions.length} · tap to review', style: const TextStyle(fontSize: 12.5)),
                ]),
              ),
              const Icon(Icons.chevron_right),
            ]),
          ),
          gap(),
        ],
      ]),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});
  final Quiz quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<int?> answers = widget.quiz.answers != null
      ? List.of(widget.quiz.answers!)
      : List.filled(widget.quiz.questions.length, null);
  late bool review = widget.quiz.score != null;
  int index = 0;
  late int secondsLeft = widget.quiz.minutes * 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (!review) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (secondsLeft <= 1) {
          _submit();
        } else {
          setState(() => secondsLeft--);
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _submit() {
    timer?.cancel();
    AppScope.read(context).submitQuiz(widget.quiz, answers);
    setState(() {
      review = true;
      index = 0;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.emoji_events, color: AppColors.amber, size: 48),
        title: Text('You scored ${widget.quiz.score}/${widget.quiz.questions.length}'),
        content: const Text('Results are shared with your parents and teacher. Review your answers to learn from mistakes.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Review answers'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz.questions[index];
    final n = widget.quiz.questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          if (!review)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Pill('${secondsLeft ~/ 60}:${two(secondsLeft % 60)}',
                    color: secondsLeft < 60 ? AppColors.red : AppColors.violet, icon: Icons.timer_outlined),
              ),
            ),
        ],
      ),
      body: PageList(children: [
        LinearProgressIndicator(value: (index + 1) / n, minHeight: 6, borderRadius: BorderRadius.circular(4)),
        gap(8),
        Text('Question ${index + 1} of $n${review ? ' · Review' : ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
        gap(14),
        Text(q.q, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        gap(18),
        for (int i = 0; i < q.options.length; i++) ...[
          _option(i, q),
          gap(10),
        ],
        gap(10),
        Row(children: [
          if (index > 0)
            Expanded(child: OutlinedButton(onPressed: () => setState(() => index--), child: const Text('Previous'))),
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: index < n - 1
                ? FilledButton(onPressed: () => setState(() => index++), child: const Text('Next'))
                : review
                    ? FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))
                    : FilledButton(
                        onPressed: answers.contains(null)
                            ? () => toast(context, 'Answer all questions before submitting', icon: Icons.info_outline)
                            : _submit,
                        child: const Text('Submit'),
                      ),
          ),
        ]),
      ]),
    );
  }

  Widget _option(int i, QuizQuestion q) {
    final selected = answers[index] == i;
    Color? border;
    IconData? icon;
    if (review) {
      if (i == q.answer) {
        border = AppColors.green;
        icon = Icons.check_circle;
      } else if (selected) {
        border = AppColors.red;
        icon = Icons.cancel;
      }
    } else if (selected) {
      border = Theme.of(context).colorScheme.primary;
      icon = Icons.radio_button_checked;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: review ? null : () => setState(() => answers[index] = i),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: border?.withValues(alpha: 0.08) ?? Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border ?? Theme.of(context).colorScheme.outlineVariant, width: border == null ? 1 : 2),
        ),
        child: Row(children: [
          CircleAvatar(radius: 14, child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(child: Text(q.options[i], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          if (icon != null) Icon(icon, color: border),
        ]),
      ),
    );
  }
}
