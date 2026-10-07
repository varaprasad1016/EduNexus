import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../main.dart' show logout;
import '../../theme.dart';
import '../../widgets/common.dart';
import '../features/communication.dart';
import '../features/settings.dart';

class PrincipalShell extends StatefulWidget {
  const PrincipalShell({super.key});

  @override
  State<PrincipalShell> createState() => _PrincipalShellState();
}

class _PrincipalShellState extends State<PrincipalShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final esc = s.escalatedTickets.length + s.pendingLeaves.where((l) => l.escalated).length;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: const [
          _Dashboard(),
          _FeesTab(),
          _EscalationsTab(),
          _AdmissionsTab(),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          const NavigationDestination(icon: Icon(Icons.currency_rupee), label: 'Fees'),
          NavigationDestination(
            icon: Badge(isLabelVisible: esc > 0, label: Text('$esc'), child: const Icon(Icons.priority_high)),
            label: 'Escalations',
          ),
          const NavigationDestination(icon: Icon(Icons.person_add_alt_outlined), selectedIcon: Icon(Icons.person_add_alt_1), label: 'Admissions'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
    const collected = [92.0, 41.0, 38.0, 64.0, 51.0];
    const target = [100.0, 45.0, 45.0, 70.0, 70.0];
    const grades = [
      ('Nursery–UKG', 91.2), ('Grade 1–2', 94.8), ('Grade 3–5', 95.6), ('Grade 6–8', 93.1), ('Grade 9–10', 89.4),
    ];
    return PageList(padding: const EdgeInsets.fromLTRB(16, 10, 16, 28), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome, ${s.userName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('${MockData.schoolName} · ${fmtDate(today)}', style: const TextStyle(fontSize: 12.5)),
          ]),
        ),
        IconButton(onPressed: () => push(context, const SettingsScreen()), icon: const Icon(Icons.settings_outlined)),
        IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout)),
      ]),
      gap(12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: [
          const StatTile(label: 'Students', value: '1,248', sub: '+64 this year', icon: Icons.groups, color: AppColors.sky),
          StatTile(label: 'Attendance today', value: '94.2%', sub: '72 absent · alerts sent', icon: Icons.how_to_reg, color: AppColors.green),
          StatTile(label: 'Fees collected', value: '₹2.86 Cr', sub: '84% of ₹3.4 Cr target', icon: Icons.currency_rupee, color: AppColors.violet),
          StatTile(
            label: 'Open escalations',
            value: '${s.escalatedTickets.length + s.pendingLeaves.where((l) => l.escalated).length}',
            sub: 'No reply in 48h',
            icon: Icons.priority_high,
            color: AppColors.red,
          ),
        ],
      ),
      const SectionTitle('Fee collection (₹ lakh) vs target'),
      AppCard(
        child: SizedBox(
          height: 170,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (int i = 0; i < months.length; i++)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(collected[i].toStringAsFixed(0), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Stack(alignment: Alignment.bottomCenter, children: [
                    Container(
                      width: 26,
                      height: 120 * target[i] / 100,
                      decoration: BoxDecoration(color: AppColors.violet.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    ),
                    Container(
                      width: 26,
                      height: 120 * collected[i] / 100,
                      decoration: BoxDecoration(
                        color: collected[i] / target[i] >= 0.9 ? AppColors.violet : AppColors.saffron,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(months[i], style: const TextStyle(fontSize: 12)),
                ]),
              ),
          ]),
        ),
      ),
      const SectionTitle('Attendance by section today'),
      AppCard(
        child: Column(children: [
          for (final g in grades)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                SizedBox(width: 96, child: Text(g.$1, style: const TextStyle(fontSize: 13))),
                Expanded(
                  child: LinearProgressIndicator(
                    value: g.$2 / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: g.$2 >= 92 ? AppColors.green : AppColors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Text('${g.$2}%', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
            ),
        ]),
      ),
      const SectionTitle('Broadcast'),
      FilledButton.icon(
        onPressed: () => _broadcast(context, s),
        icon: const Icon(Icons.campaign),
        label: const Text('Send announcement to all parents'),
      ),
      gap(8),
      Row(children: [
        Expanded(child: StatTile(label: 'Staff present', value: '86/91', icon: Icons.badge_outlined, color: AppColors.teal)),
        const SizedBox(width: 10),
        Expanded(child: StatTile(label: 'Buses on route', value: '14/14', icon: Icons.directions_bus, color: AppColors.amber)),
      ]),
    ]);
  }

  void _broadcast(BuildContext context, AppState s) {
    final title = TextEditingController();
    final body = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('New announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          TextField(controller: body, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Message')),
          const SizedBox(height: 8),
          const Text('Delivered by app + WhatsApp, auto-translated to Telugu & Hindi.', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isEmpty) return;
              s.addAnnouncement(title.text.trim(), body.text.trim(), 'Principal');
              Navigator.pop(ctx);
              toast(context, 'Sent to 1,248 families');
            },
            child: const Text('Send to all'),
          ),
        ]),
      ),
    );
  }
}

class _FeesTab extends StatelessWidget {
  const _FeesTab();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final demoDue = s.fees.where((f) => f.overdue).fold<double>(0, (a, f) => a + f.balance);
    final defaulters = [
      ('Aarav Reddy', '5-A', demoDue, 30),
      ('Charan Teja', '5-A', 52300.0, 45),
      ('Lasya Priya', '7-B', 42500.0, 30),
      ('Uday Kiran', '9-A', 96000.0, 75),
      ('Nandini S', '3-C', 18000.0, 12),
    ].where((d) => d.$3 > 0).toList();
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Fee management')),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'This academic year',
          title: '₹2.86 Cr collected',
          subtitle: '₹54 L outstanding · 62% paid via UPI · 118 families on Autopay',
          bottom: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.84,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
        gap(12),
        Row(children: [
          Expanded(child: StatTile(label: 'Today', value: inr(184500), sub: '23 payments', color: AppColors.green, icon: Icons.today)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Overdue', value: '212', sub: 'families', color: AppColors.red, icon: Icons.warning_amber)),
        ]),
        SectionTitle('Top defaulters', action: 'Remind all', onAction: () => toast(context, 'WhatsApp reminders with UPI pay link sent to 212 families', icon: Icons.send)),
        for (final d in defaulters) ...[
          AppCard(
            child: Row(children: [
              CircleAvatar(backgroundColor: AppColors.red.withValues(alpha: 0.12), child: Text(d.$1[0], style: const TextStyle(color: AppColors.red))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${d.$2} · ${d.$4} days overdue', style: const TextStyle(fontSize: 12)),
                ]),
              ),
              Text(inr(d.$3), style: const TextStyle(fontWeight: FontWeight.w800)),
              IconButton(
                onPressed: () => toast(context, 'Reminder sent to ${d.$1}\'s parent', icon: Icons.send),
                icon: const Icon(Icons.send_outlined, size: 20),
              ),
            ]),
          ),
          gap(8),
        ],
        gap(6),
        OutlinedButton.icon(
          onPressed: () => toast(context, 'Day book exported for Tally (XML)', icon: Icons.file_download_done),
          icon: const Icon(Icons.table_view_outlined),
          label: const Text('Export to Tally'),
        ),
      ]),
    );
  }
}

class _EscalationsTab extends StatelessWidget {
  const _EscalationsTab();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final esc = s.escalatedTickets;
    final open = s.tickets.where((t) => t.status != TicketStatus.closed && !t.escalated).toList();
    final leaves = s.pendingLeaves;
    final rated = s.tickets.where((t) => t.rating != null).toList();
    final avg = rated.isEmpty ? 0 : rated.fold<int>(0, (a, t) => a + t.rating!) / rated.length;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Parent requests & SLA')),
      body: PageList(children: [
        Row(children: [
          Expanded(child: StatTile(label: 'Escalated', value: '${esc.length}', icon: Icons.priority_high, color: AppColors.red)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Open', value: '${open.length}', icon: Icons.mark_email_unread_outlined, color: AppColors.amber)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Satisfaction', value: '${avg.toStringAsFixed(1)}★', icon: Icons.star, color: AppColors.green)),
        ]),
        const SectionTitle('Escalated · no reply in 48 hours'),
        if (esc.isEmpty) const Text('Nothing escalated. 🎉'),
        for (final t in esc) ...[TicketCard(t: t, forSchool: true), gap()],
        const SectionTitle('Leave requests awaiting teachers'),
        if (leaves.isEmpty) const Text('All leave requests have been handled.'),
        for (final l in leaves) ...[
          LeaveCard(
            l: l,
            actions: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => toast(context, 'Nudge sent to ${s.children.firstWhere((c) => c.id == l.childId).classTeacher}', icon: Icons.notifications_active),
                  child: const Text('Nudge teacher'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    s.decideLeave(l, true, remark: 'Approved by Principal');
                    toast(context, 'Approved · parent notified');
                  },
                  child: const Text('Approve'),
                ),
              ),
            ]),
          ),
          gap(),
        ],
        const SectionTitle('Other open requests'),
        for (final t in open) ...[TicketCard(t: t, forSchool: true), gap()],
      ]),
    );
  }
}

class _AdmissionsTab extends StatelessWidget {
  const _AdmissionsTab();

  static const stages = ['Enquiry', 'Campus visit', 'Applied', 'Admitted'];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final colors = [AppColors.sky, AppColors.violet, AppColors.amber, AppColors.green];
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Admissions CRM')),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Next academic year',
          title: '${s.enquiries.length} active leads',
          subtitle: '${s.enquiries.where((e) => e.source.contains('referral')).length} came from parent referrals in the app',
          bottom: Row(children: [
            for (int i = 0; i < stages.length; i++)
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.enquiries.where((e) => e.stage == stages[i]).length}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  Text(stages[i], style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                ]),
              ),
          ]),
        ),
        for (int i = 0; i < stages.length; i++) ...[
          SectionTitle(stages[i]),
          for (final e in s.enquiries.where((e) => e.stage == stages[i])) ...[
            AppCard(
              accent: colors[i],
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${e.studentName} · ${e.grade}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${e.parentName} · ${e.phone}', style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Pill(e.source, color: e.source.contains('referral') ? AppColors.saffron : AppColors.slate),
                  ]),
                ),
                if (e.stage != 'Admitted')
                  FilledButton.tonal(
                    onPressed: () {
                      s.advanceEnquiry(e);
                      toast(context, '${e.studentName} moved to ${e.stage}');
                    },
                    child: const Text('Advance'),
                  )
                else
                  const Icon(Icons.verified, color: AppColors.green),
              ]),
            ),
            gap(8),
          ],
        ],
      ]),
    );
  }
}
