import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

// ---------------------------------------------------------------- AI weekly summary
class AiSummaryScreen extends StatelessWidget {
  const AiSummaryScreen({super.key});

  String _summary(String lang, String name, double att, int done, int total, String best) => switch (lang) {
        'te' =>
          'ఈ వారం $name హాజరు ${att.toStringAsFixed(0)}%. $total హోంవర్క్‌లలో $done పూర్తి చేశారు. $best లో చాలా బాగా చేస్తున్నారు. హిందీ వ్రాతలో కొంచెం సాధన అవసరం – ఇంట్లో రోజుకు 15 నిమిషాలు హిందీ చదవడం సహాయపడుతుంది.',
        'hi' =>
          'इस सप्ताह $name की उपस्थिति ${att.toStringAsFixed(0)}% रही। $total में से $done गृहकार्य पूरे किए। $best में बहुत अच्छा प्रदर्शन है। हिंदी लेखन में थोड़े अभ्यास की ज़रूरत है – घर पर रोज़ 15 मिनट हिंदी पढ़ना मददगार होगा।',
        _ =>
          '$name had ${att.toStringAsFixed(0)}% attendance this week and completed $done of $total homework tasks. $name is doing very well in $best. Hindi writing needs a little practice – 15 minutes of Hindi reading at home each day will help.',
      };

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    final hw = s.homeworkFor(c.id);
    final done = hw.where((h) => h.done).length;
    final st = s.stats(c.id);
    final res = s.resultsFor(c.id);
    String best = 'Mathematics';
    if (res.isNotEmpty) {
      best = res.last.marks.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'aiSummary'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Week of ${fmtShort(daysAgo(6))} – ${fmtShort(today)}',
          title: '${c.firstName}\'s week',
          subtitle: 'Generated from attendance, homework, class work and test data',
          gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFEC4899)]),
          trailing: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.auto_awesome, color: Colors.white)),
        ),
        gap(12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_summary(s.lang, c.firstName, st.percent, done, hw.length, best), style: const TextStyle(fontSize: 15.5, height: 1.5)),
            gap(10),
            Wrap(spacing: 8, children: [
              for (final e in languages.entries)
                ChoiceChip(label: Text(e.value), selected: s.lang == e.key, onSelected: (_) => s.setLang(e.key)),
            ]),
            gap(4),
            Row(children: [
              TextButton.icon(
                onPressed: () => toast(context, 'Playing voice summary…', icon: Icons.volume_up),
                icon: const Icon(Icons.volume_up_outlined),
                label: const Text('Listen'),
              ),
              TextButton.icon(
                onPressed: () => toast(context, 'Summary sent to WhatsApp', icon: Icons.share),
                icon: const Icon(Icons.share_outlined),
                label: const Text('WhatsApp'),
              ),
            ]),
          ]),
        ),
        gap(12),
        Row(children: [
          Expanded(child: StatTile(label: 'Attendance', value: '${st.percent.toStringAsFixed(0)}%', icon: Icons.how_to_reg, color: AppColors.green)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Homework', value: '$done/${hw.length}', icon: Icons.edit_note, color: AppColors.sky)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Strongest', value: best, icon: Icons.trending_up, color: AppColors.violet)),
        ]),
        const SectionTitle('Try this at home'),
        for (final tip in [
          (Icons.calculate_outlined, 'Fractions with rotis', 'Cut a roti into 4 and 8 pieces and ask which is bigger: 2/4 or 3/8?'),
          (Icons.menu_book_outlined, 'Bedtime reading', 'Read one Hindi story together; let ${c.firstName} explain it back in Telugu.'),
          (Icons.park_outlined, 'Plant walk', 'Spot roots, stems and leaves in your neighbourhood – links to this week\'s Science.'),
        ]) ...[
          AppCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(backgroundColor: AppColors.saffron.withValues(alpha: 0.12), child: Icon(tip.$1, color: AppColors.saffron)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tip.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(tip.$3),
                ]),
              ),
            ]),
          ),
          gap(8),
        ],
        gap(6),
        Text('AI-generated summary, reviewed by the class teacher. It never shares data outside the school.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Refer & Earn
class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  final student = TextEditingController();
  final parent = TextEditingController();
  final phone = TextEditingController();
  String grade = 'LKG';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final mine = s.enquiries.where((e) => e.source.contains(s.userName)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'refer'))),
      body: PageList(children: [
        const GradientHeader(
          eyebrow: 'Refer a family',
          title: 'Get ₹5,000 off your next term fee',
          subtitle: 'when a family you refer takes admission. No limit on referrals.',
          gradient: LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFEAB308)]),
          trailing: Icon(Icons.card_giftcard, color: Colors.white, size: 40),
        ),
        gap(16),
        TextField(controller: student, decoration: const InputDecoration(labelText: 'Child\'s name')),
        gap(10),
        TextField(controller: parent, decoration: const InputDecoration(labelText: 'Parent\'s name')),
        gap(10),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Parent\'s mobile', prefixText: '+91 '),
        ),
        gap(10),
        DropdownButtonFormField<String>(
          initialValue: grade,
          decoration: const InputDecoration(labelText: 'Admission sought for'),
          items: [
            for (final g in ['Nursery', 'LKG', 'UKG', for (int i = 1; i <= 10; i++) 'Grade $i']) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (v) => setState(() => grade = v!),
        ),
        gap(12),
        FilledButton(
          onPressed: () {
            if (student.text.trim().isEmpty || parent.text.trim().isEmpty || phone.text.trim().length < 10) {
              toast(context, 'Please fill all fields', icon: Icons.error_outline);
              return;
            }
            s.addEnquiry(student.text.trim(), parent.text.trim(), phone.text.trim(), grade);
            student.clear();
            parent.clear();
            phone.clear();
            toast(context, 'Referral sent to the admissions team. They will call within 24 hours.');
          },
          child: const Text('Submit referral'),
        ),
        gap(8),
        OutlinedButton.icon(
          onPressed: () => toast(context, 'School brochure + your referral link shared on WhatsApp', icon: Icons.share),
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share school brochure on WhatsApp'),
        ),
        SectionTitle('My referrals (${mine.length})'),
        if (mine.isEmpty) const Text('Referrals you submit will appear here with their admission status.'),
        for (final e in mine) ...[
          AppCard(
            child: Row(children: [
              CircleAvatar(child: Text(e.studentName[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.studentName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${e.grade} · ${fmtDate(e.date)}', style: const TextStyle(fontSize: 12)),
                ]),
              ),
              Pill(e.stage, color: e.stage == 'Admitted' ? AppColors.green : AppColors.sky),
            ]),
          ),
          gap(8),
        ],
      ]),
    );
  }
}

// ---------------------------------------------------------------- STEAM Lab
class SteamLabScreen extends StatelessWidget {
  const SteamLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'steamLab'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Science · Technology · Engineering · Arts · Maths',
          title: 'STEAM Lab',
          subtitle: 'Projects, robotics and coding – with single sign-on to partner platforms.',
          gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
        ),
        gap(12),
        AppCard(
          child: Row(children: [
            const CircleAvatar(child: Icon(Icons.login)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ICT / coding platform', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('No separate username or password needed', style: TextStyle(fontSize: 12.5)),
              ]),
            ),
            FilledButton.tonal(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  icon: const Icon(Icons.verified_user, color: AppColors.green, size: 40),
                  title: const Text('Signed in with EduNexus'),
                  content: const Text('Single sign-on: the partner platform opens already logged in as your child. (Demo)'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              ),
              child: const Text('Open'),
            ),
          ]),
        ),
        const SectionTitle('Projects'),
        for (final p in MockData.steamProjects) ...[
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p[0] as String, style: const TextStyle(fontWeight: FontWeight.w800))),
                Pill(p[1] as String, color: AppColors.violet),
              ]),
              gap(8),
              LinearProgressIndicator(value: p[3] as double, minHeight: 6, borderRadius: BorderRadius.circular(4)),
              gap(6),
              Text(p[2] as String, style: const TextStyle(fontSize: 12.5)),
            ]),
          ),
          gap(8),
        ],
      ]),
    );
  }
}
