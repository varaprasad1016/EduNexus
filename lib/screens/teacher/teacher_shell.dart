import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../main.dart' show logout;
import '../../theme.dart';
import '../../widgets/common.dart';
import '../features/communication.dart';
import '../features/settings.dart';

/// Teacher app for the class teacher of Grade 5-A. The demo parent's child
/// (Aarav, roll 14) is in this class, so actions here show up in the parent app.
class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final pendingReq = s.leaves.where((l) => l.childId == 'c1' && l.status == LeaveStatus.pending).length +
        s.tickets.where((t) => t.childId == 'c1' && t.status == TicketStatus.open).length;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: [
          _TeacherToday(onGo: (i) => setState(() => index = i)),
          const _RosterTab(),
          const _PostTab(),
          const _RequestsTab(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
          const NavigationDestination(icon: Icon(Icons.how_to_reg_outlined), selectedIcon: Icon(Icons.how_to_reg), label: 'Attendance'),
          const NavigationDestination(icon: Icon(Icons.post_add_outlined), selectedIcon: Icon(Icons.post_add), label: 'Post'),
          NavigationDestination(
            icon: Badge(isLabelVisible: pendingReq > 0, label: Text('$pendingReq'), child: const Icon(Icons.inbox_outlined)),
            selectedIcon: const Icon(Icons.inbox),
            label: 'Requests',
          ),
        ],
      ),
    );
  }
}

class _TeacherToday extends StatelessWidget {
  const _TeacherToday({required this.onGo});
  final ValueChanged<int> onGo;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final day = today.weekday == DateTime.sunday ? 1 : today.weekday;
    final mine = s.timetable['c1']![day]!.where((p) => p.teacher == 'Mrs. Lakshmi Prasanna').toList();
    final present = s.roster.where((r) => r.present).length;
    return PageList(padding: const EdgeInsets.fromLTRB(16, 10, 16, 28), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good day, ${s.userName.split(' ').first} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('Class teacher · Grade 5 · A · ${MockData.schoolName}', style: const TextStyle(fontSize: 12.5)),
          ]),
        ),
        IconButton(onPressed: () => push(context, const SettingsScreen()), icon: const Icon(Icons.settings_outlined)),
        IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout)),
      ]),
      gap(12),
      GradientHeader(
        eyebrow: '${weekday(today)}, ${fmtDate(today)}',
        title: s.rosterSubmittedToday ? 'Attendance submitted ✅' : 'Attendance pending',
        subtitle: s.rosterSubmittedToday
            ? '$present/${s.roster.length} present · absent alerts sent to parents on WhatsApp'
            : 'Mark attendance before 9:30 AM – parents of absentees are alerted automatically',
        trailing: s.rosterSubmittedToday
            ? null
            : FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.indigo, minimumSize: const Size(0, 40)),
                onPressed: () => onGo(1),
                child: const Text('Mark'),
              ),
      ),
      gap(12),
      Row(children: [
        Expanded(child: StatTile(label: 'Students', value: '${s.roster.length}', icon: Icons.groups, color: AppColors.sky)),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            label: 'Leave requests',
            value: '${s.leaves.where((l) => l.childId == 'c1' && l.status == LeaveStatus.pending).length}',
            icon: Icons.event_busy,
            color: AppColors.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(
            label: 'Parent msgs',
            value: '${s.tickets.where((t) => t.childId == 'c1' && t.status == TicketStatus.open).length}',
            icon: Icons.forum,
            color: AppColors.red,
          ),
        ),
      ]),
      const SectionTitle('My classes today'),
      if (mine.isEmpty) const Text('No classes today.'),
      for (final p in mine) ...[
        AppCard(
          accent: AppColors.subject(p.subject),
          child: Row(children: [
            Text('${p.start}\n${p.end}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(width: 14),
            Expanded(child: Text('${p.subject} · Grade 5-A', style: const TextStyle(fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => onGo(2), child: const Text('Post work')),
          ]),
        ),
        gap(8),
      ],
      const SectionTitle('Quick actions'),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _quick(context, Icons.how_to_reg, 'Attendance', AppColors.teal, () => onGo(1)),
          _quick(context, Icons.edit_note, 'Homework', const Color(0xFF2563EB), () => onGo(2)),
          _quick(context, Icons.inbox, 'Requests', AppColors.amber, () => onGo(3)),
          _quick(context, Icons.auto_awesome, 'AI remarks', AppColors.violet, () => _aiRemarks(context)),
          _quick(context, Icons.campaign, 'Announce', AppColors.saffron, () => onGo(2)),
          _quick(context, Icons.photo_camera_outlined, 'Board photo', AppColors.pink,
              () => toast(context, 'Board photo → homework text extracted (OCR demo)', icon: Icons.document_scanner)),
        ],
      ),
    ]);
  }

  Widget _quick(BuildContext context, IconData i, String l, Color c, VoidCallback onTap) => AppCard(
        padding: const EdgeInsets.all(8),
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(i, color: c),
          ),
          const SizedBox(height: 6),
          Text(l, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      );

  void _aiRemarks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI report-card remarks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Drafted from marks, attendance and class-work notes. Edit before publishing.'),
          const SizedBox(height: 14),
          for (final r in [
            ('Aarav Reddy', 'Curious and confident problem-solver; strong in Maths. Encourage daily Hindi reading.'),
            ('Aadhya Sharma', 'Expressive reader with neat work. Needs support with word problems in Maths.'),
            ('Arjun Varma', 'Enthusiastic in sports and Science experiments; should complete homework on time.'),
          ])
            Card(
              child: ListTile(
                title: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(r.$2),
                trailing: const Icon(Icons.edit_outlined),
              ),
            ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              toast(context, 'Remarks saved for 28 students');
            },
            child: const Text('Approve all'),
          ),
        ]),
      ),
    );
  }
}

class _RosterTab extends StatefulWidget {
  const _RosterTab();

  @override
  State<_RosterTab> createState() => _RosterTabState();
}

class _RosterTabState extends State<_RosterTab> {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final absent = s.roster.where((r) => !r.present).length;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Attendance · Grade 5-A'),
        actions: [
          TextButton(
            onPressed: () => s.toggle(() {
              for (final r in s.roster) {
                r.present = true;
              }
            }),
            child: const Text('All present'),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            Pill('${s.roster.length - absent} present', color: AppColors.green),
            const SizedBox(width: 8),
            Pill('$absent absent', color: AppColors.red),
            const Spacer(),
            Text('Tap a student to toggle', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: s.roster.length,
            itemBuilder: (context, i) {
              final r = s.roster[i];
              final c = r.present ? AppColors.green : AppColors.red;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => s.toggle(() => r.present = !r.present),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c, width: 1.5),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: c,
                      child: Text('${r.roll}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    const SizedBox(height: 4),
                    Text(r.name.split(' ').first,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    Text(r.present ? 'P' : 'A', style: TextStyle(color: c, fontWeight: FontWeight.w900)),
                  ]),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                s.submitRoster('c1', '14');
                toast(context, absent == 0 ? 'Attendance submitted · full class present' : 'Submitted · $absent absent alert(s) sent on WhatsApp');
              },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(s.rosterSubmittedToday ? 'Update attendance' : 'Submit attendance'),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PostTab extends StatefulWidget {
  const _PostTab();

  @override
  State<_PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<_PostTab> {
  String kind = 'Homework';
  String subject = 'English';
  int dueIn = 1;
  final title = TextEditingController();
  final body = TextEditingController();
  bool attach = false;

  static const subjects = ['English', 'Mathematics', 'Science', 'Social Studies', 'Telugu', 'Hindi', 'Computers'];

  void _post(AppState s) {
    if (body.text.trim().isEmpty || (kind != 'Class work' && title.text.trim().isEmpty)) {
      toast(context, 'Please fill in the details', icon: Icons.error_outline);
      return;
    }
    switch (kind) {
      case 'Homework':
        s.addHomework(Homework(
          id: 'hw${DateTime.now().millisecondsSinceEpoch}',
          childId: 'c1',
          subject: subject,
          title: title.text.trim(),
          details: body.text.trim(),
          assigned: today,
          due: today.add(Duration(days: dueIn)),
          attachments: attach ? ['worksheet_${subject.toLowerCase().replaceAll(' ', '_')}.pdf'] : const [],
          postedBy: s.userName,
        ));
      case 'Class work':
        s.addClassWork(ClassWork('c1', subject, body.text.trim(), today));
      case 'Announcement':
        s.addAnnouncement(title.text.trim(), body.text.trim(), s.userName);
    }
    title.clear();
    body.clear();
    setState(() => attach = false);
    FocusScope.of(context).unfocus();
    toast(context, '$kind posted to Grade 5-A parents · push + WhatsApp');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Post to Grade 5-A')),
      body: PageList(children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Homework', label: Text('Homework'), icon: Icon(Icons.edit_note)),
            ButtonSegment(value: 'Class work', label: Text('Class work'), icon: Icon(Icons.class_outlined)),
            ButtonSegment(value: 'Announcement', label: Text('Notice'), icon: Icon(Icons.campaign_outlined)),
          ],
          selected: {kind},
          showSelectedIcon: false,
          onSelectionChanged: (v) => setState(() => kind = v.first),
        ),
        gap(14),
        if (kind != 'Announcement') ...[
          DropdownButtonFormField<String>(
            initialValue: subject,
            decoration: const InputDecoration(labelText: 'Subject'),
            items: [for (final x in subjects) DropdownMenuItem(value: x, child: Text(x))],
            onChanged: (v) => setState(() => subject = v!),
          ),
          gap(10),
        ],
        if (kind != 'Class work') ...[
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          gap(10),
        ],
        TextField(
          controller: body,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: kind == 'Class work' ? 'What was covered today' : 'Details',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              tooltip: 'Dictate',
              onPressed: () {
                body.text = kind == 'Homework'
                    ? 'Complete the exercise in your notebook and bring it tomorrow.'
                    : 'Completed the lesson with an activity. Students participated well.';
              },
              icon: const Icon(Icons.mic_none),
            ),
          ),
        ),
        if (kind == 'Homework') ...[
          gap(10),
          Row(children: [
            const Text('Due in', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            for (final d in [1, 2, 3, 7])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(label: Text(d == 7 ? '1 week' : '$d day${d > 1 ? 's' : ''}'), selected: dueIn == d, onSelected: (_) => setState(() => dueIn = d)),
              ),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Attach worksheet / photo of board'),
            value: attach,
            onChanged: (v) => setState(() => attach = v),
          ),
        ],
        gap(10),
        FilledButton.icon(onPressed: () => _post(s), icon: const Icon(Icons.send), label: Text('Post $kind')),
        gap(8),
        Text('Parents get it in their own language (auto-translated to Telugu / Hindi).',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final leaves = s.leaves.where((l) => l.childId == 'c1').toList()..sort((a, b) => b.applied.compareTo(a.applied));
    final tickets = s.tickets.where((t) => t.childId == 'c1').toList()..sort((a, b) => b.created.compareTo(a.created));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Parent requests'),
          bottom: const TabBar(tabs: [Tab(text: 'Leave'), Tab(text: 'Messages')]),
        ),
        body: TabBarView(children: [
          PageList(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
            if (leaves.isEmpty) const EmptyState(icon: Icons.event_available, title: 'No leave requests'),
            for (final l in leaves) ...[
              Text('${s.children.firstWhere((c) => c.id == l.childId).name} · Roll 14', style: const TextStyle(fontWeight: FontWeight.w700)),
              gap(6),
              LeaveCard(
                l: l,
                actions: l.status != LeaveStatus.pending
                    ? null
                    : Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              s.decideLeave(l, false, remark: 'Please meet the class teacher.');
                              toast(context, 'Leave rejected · parent notified', icon: Icons.cancel_outlined);
                            },
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              s.decideLeave(l, true, remark: 'Approved. Take care!');
                              toast(context, 'Leave approved · parent notified');
                            },
                            child: const Text('Approve'),
                          ),
                        ),
                      ]),
              ),
              gap(12),
            ],
          ]),
          PageList(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
            for (final t in tickets) ...[TicketCard(t: t, forSchool: true), gap()],
          ]),
        ]),
      ),
    );
  }
}
