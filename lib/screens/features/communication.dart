import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

// ---------------------------------------------------------------- Inbox
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !embedded,
          title: Text(tr(context, 'inbox')),
          actions: [
            TextButton(onPressed: s.markAnnouncementsRead, child: const Text('Mark all read')),
          ],
          bottom: TabBar(tabs: [
            Tab(text: tr(context, 'announcements')),
            Tab(text: tr(context, 'noticeBoard')),
            const Tab(text: 'My requests'),
          ]),
        ),
        body: const TabBarView(children: [
          _AnnouncementList(),
          _NoticeList(),
          _TicketList(),
        ]),
      ),
    );
  }
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(context, 'announcements'))),
        body: const _AnnouncementList(),
      );
}

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tr(context, 'noticeBoard'))),
        body: const _NoticeList(),
      );
}

(IconData, Color) _kind(String kind) => switch (kind) {
      'fee' => (Icons.currency_rupee, AppColors.red),
      'event' => (Icons.celebration_outlined, AppColors.violet),
      'alert' => (Icons.warning_amber_rounded, AppColors.amber),
      'complaint' => (Icons.task_alt, AppColors.green),
      _ => (Icons.campaign_outlined, AppColors.sky),
    };

class _AnnouncementList extends StatelessWidget {
  const _AnnouncementList();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (s.announcements.isEmpty) {
      return const EmptyState(icon: Icons.campaign_outlined, title: 'No announcements yet');
    }
    return PageList(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      for (final a in s.announcements) ...[
        _MessageCard(a: a),
        gap(),
      ],
    ]);
  }
}

class _NoticeList extends StatelessWidget {
  const _NoticeList();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageList(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      for (final n in s.notices) ...[
        AppCard(
          accent: AppColors.indigo,
          onTap: () => _openMessage(context, n),
          child: Row(children: [
            DateBadge(n.date),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${n.from} · ${weekday(n.date)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
        gap(),
      ],
    ]);
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.a});
  final Announcement a;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _kind(a.kind);
    return AppCard(
      onTap: () => _openMessage(context, a),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(a.title, style: TextStyle(fontWeight: a.read ? FontWeight.w600 : FontWeight.w800))),
              if (!a.read) const CircleAvatar(radius: 4, backgroundColor: AppColors.saffron),
            ]),
            const SizedBox(height: 4),
            Text(a.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text('${a.from} · ${relDay(a.date)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      ]),
    );
  }
}

void _openMessage(BuildContext context, Announcement a) {
  AppScope.read(context).toggle(() => a.read = true);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('${a.from} · ${fmtDate(a.date)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const Divider(height: 26),
        Text(a.body, style: const TextStyle(fontSize: 15, height: 1.45)),
        const SizedBox(height: 18),
        Row(children: [
          OutlinedButton.icon(
            onPressed: () => toast(context, 'Reading aloud (text-to-speech in the parent\'s language)', icon: Icons.volume_up),
            icon: const Icon(Icons.volume_up_outlined),
            label: const Text('Listen'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () => toast(context, 'Shared to WhatsApp', icon: Icons.share),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share'),
          ),
        ]),
      ]),
    ),
  );
}

class _TicketList extends StatelessWidget {
  const _TicketList();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.ticketsFor(s.child.id);
    return PageList(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      FilledButton.icon(
        onPressed: () => push(context, const WriteToSchoolScreen()),
        icon: const Icon(Icons.edit_outlined),
        label: Text(tr(context, 'writeToSchool')),
      ),
      gap(14),
      if (list.isEmpty) const EmptyState(icon: Icons.forum_outlined, title: 'No requests yet'),
      for (final t in list) ...[TicketCard(t: t), gap()],
    ]);
  }
}

// ---------------------------------------------------------------- Write to school
class WriteToSchoolScreen extends StatefulWidget {
  const WriteToSchoolScreen({super.key});

  @override
  State<WriteToSchoolScreen> createState() => _WriteToSchoolScreenState();
}

class _WriteToSchoolScreenState extends State<WriteToSchoolScreen> {
  String to = 'Class Teacher';
  final subject = TextEditingController();
  final message = TextEditingController();
  bool attach = false;

  static const recipients = ['Class Teacher', 'Subject Teacher', 'Transport', 'Accounts', 'Principal'];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.ticketsFor(s.child.id);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'writeToSchool'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Helpdesk',
          title: 'Write to school',
          subtitle: 'Every message gets a ticket number. If nobody replies in 48 hours it is escalated to the principal automatically.',
        ),
        gap(16),
        DropdownButtonFormField<String>(
          initialValue: to,
          decoration: const InputDecoration(labelText: 'To'),
          items: [for (final r in recipients) DropdownMenuItem(value: r, child: Text(r))],
          onChanged: (v) => setState(() => to = v!),
        ),
        gap(12),
        TextField(controller: subject, decoration: const InputDecoration(labelText: 'Subject')),
        gap(12),
        TextField(
          controller: message,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'Message',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
              tooltip: 'Speak in your language',
              icon: const Icon(Icons.mic_none),
              onPressed: () => toast(context, 'Voice typing in Telugu / Hindi / English', icon: Icons.mic),
            ),
          ),
        ),
        gap(8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: attach,
          onChanged: (v) => setState(() => attach = v),
          title: const Text('Attach photo / document'),
          subtitle: Text(attach ? 'photo_2026.jpg attached' : 'Optional'),
          secondary: const Icon(Icons.attach_file),
        ),
        gap(8),
        FilledButton.icon(
          onPressed: () {
            if (subject.text.trim().isEmpty || message.text.trim().isEmpty) {
              toast(context, 'Please add a subject and message', icon: Icons.error_outline);
              return;
            }
            final id = s.newTicket(s.child.id, to, subject.text.trim(), message.text.trim(), attach);
            subject.clear();
            message.clear();
            setState(() => attach = false);
            FocusScope.of(context).unfocus();
            toast(context, 'Sent · Ticket $id created');
          },
          icon: const Icon(Icons.send),
          label: const Text('Send message'),
        ),
        gap(6),
        Text('🔒 Sent privately with ${s.child.firstName}\'s name and class.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        SectionTitle('Recent requests (${list.length})'),
        for (final t in list) ...[TicketCard(t: t), gap()],
      ]),
    );
  }
}

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.t, this.forSchool = false});
  final Ticket t;
  final bool forSchool;

  @override
  Widget build(BuildContext context) {
    final (label, color) = ticketStatus(t);
    return AppCard(
      accent: color,
      onTap: () => push(context, TicketDetailScreen(t: t, forSchool: forSchool)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(label, color: color),
          const SizedBox(width: 6),
          Pill(t.to, color: AppColors.slate),
          const Spacer(),
          Text(timeAgo(t.created), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 8),
        Text(t.subject, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 4),
        Text(t.thread.last.text, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          Text(t.id, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const Spacer(),
          if (t.status == TicketStatus.open && !t.escalated)
            Text('Reply due in ${t.slaRemaining.inHours}h', style: const TextStyle(fontSize: 12, color: AppColors.amber, fontWeight: FontWeight.w700)),
          if (t.rating != null) ...[
            for (int i = 0; i < 5; i++) Icon(i < t.rating! ? Icons.star : Icons.star_border, size: 15, color: AppColors.amber),
          ],
        ]),
      ]),
    );
  }
}

(String, Color) ticketStatus(Ticket t) {
  if (t.escalated) return ('Escalated to Principal', AppColors.red);
  return switch (t.status) {
    TicketStatus.open => ('Awaiting reply', AppColors.amber),
    TicketStatus.replied => ('Replied', AppColors.sky),
    TicketStatus.closed => ('Closed', AppColors.green),
  };
}

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.t, this.forSchool = false});
  final Ticket t;
  final bool forSchool;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final reply = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = widget.t;
    final (label, color) = ticketStatus(t);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.id)),
      body: Column(children: [
        Expanded(
          child: PageList(children: [
            Row(children: [Pill(label, color: color), const SizedBox(width: 6), Pill('To: ${t.to}', color: AppColors.slate)]),
            gap(10),
            Text(t.subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            gap(4),
            Text('Opened ${fmtDate(t.created)} · ${s.children.firstWhere((c) => c.id == t.childId).name}',
                style: TextStyle(color: cs.onSurfaceVariant)),
            gap(16),
            for (final m in t.thread)
              Align(
                alignment: m.fromSchool ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m.fromSchool ? cs.surfaceContainerHighest : cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Text(m.text),
                    const SizedBox(height: 4),
                    Text('${fmtShort(m.at)} · ${fmtTime(m.at)}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  ]),
                ),
              ),
            if (!widget.forSchool && t.status == TicketStatus.replied) ...[
              gap(10),
              AppCard(
                child: Column(children: [
                  const Text('Are you satisfied with the response?', style: TextStyle(fontWeight: FontWeight.w700)),
                  gap(8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int i = 1; i <= 5; i++)
                      IconButton(
                        onPressed: () {
                          s.rateTicket(t, i);
                          toast(context, 'Thanks! Ticket closed with $i★ rating');
                        },
                        icon: const Icon(Icons.star_border, color: AppColors.amber, size: 30),
                      ),
                  ]),
                ]),
              ),
            ],
          ]),
        ),
        if (t.status != TicketStatus.closed)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: reply,
                    decoration: InputDecoration(hintText: widget.forSchool ? 'Reply to parent…' : 'Add a message…'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    if (reply.text.trim().isEmpty) return;
                    s.replyTicket(t, widget.forSchool ? s.userName : 'You', reply.text.trim(), fromSchool: widget.forSchool);
                    reply.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Leave
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime from = daysAhead(1);
  DateTime to = daysAhead(1);
  final reason = TextEditingController();

  Future<void> _pick(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? from : to,
      firstDate: daysAgo(7),
      lastDate: daysAhead(120),
    );
    if (d == null) return;
    setState(() {
      if (isFrom) {
        from = d;
        if (to.isBefore(from)) to = from;
      } else {
        to = d.isBefore(from) ? from : d;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.leavesFor(s.child.id);
    final days = to.difference(from).inDays + 1;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'applyLeave'))),
      body: PageList(children: [
        GradientHeader(eyebrow: 'Leave', title: 'Apply leave', subtitle: '${s.child.name} · ${s.child.classLabel}'),
        gap(16),
        Row(children: [
          Expanded(child: _DateField(label: 'From', date: from, onTap: () => _pick(true))),
          const SizedBox(width: 12),
          Expanded(child: _DateField(label: 'To', date: to, onTap: () => _pick(false))),
        ]),
        gap(6),
        Text('$days day${days > 1 ? 's' : ''} · ${weekday(from)}${days > 1 ? ' – ${weekday(to)}' : ''}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        gap(12),
        TextField(
          controller: reason,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. Fever, doctor advised two days of rest', alignLabelWithHint: true),
        ),
        gap(8),
        Wrap(spacing: 8, children: [
          for (final r in ['Fever / unwell', 'Family function', 'Out of town', 'Medical appointment'])
            ActionChip(label: Text(r), onPressed: () => reason.text = r),
        ]),
        gap(14),
        FilledButton(
          onPressed: () {
            if (reason.text.trim().isEmpty) {
              toast(context, 'Please give a reason', icon: Icons.error_outline);
              return;
            }
            s.applyLeave(s.child.id, from, to, reason.text.trim());
            reason.clear();
            toast(context, 'Leave request sent to ${s.child.classTeacher}');
          },
          child: const Text('Submit leave request'),
        ),
        SectionTitle('Recent requests (${list.length})'),
        for (final l in list) ...[LeaveCard(l: l), gap()],
      ]),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
          child: Text(fmtDate(date), style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
}

class LeaveCard extends StatelessWidget {
  const LeaveCard({super.key, required this.l, this.actions});
  final LeaveRequest l;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (l.status) {
      LeaveStatus.pending => (l.escalated ? 'Pending · escalated' : 'Pending', l.escalated ? AppColors.red : AppColors.amber),
      LeaveStatus.approved => ('Approved', AppColors.green),
      LeaveStatus.rejected => ('Rejected', AppColors.red),
    };
    return AppCard(
      accent: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          DateBadge(l.from, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.days == 1 ? fmtDate(l.from) : '${fmtShort(l.from)} – ${fmtDate(l.to)}', style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('${l.days} day${l.days > 1 ? 's' : ''} · applied ${timeAgo(l.applied)}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
          Pill(label, color: color),
        ]),
        const SizedBox(height: 10),
        Text(l.reason),
        if (l.remark != null) ...[
          const SizedBox(height: 6),
          Text('Teacher: ${l.remark}', style: const TextStyle(fontStyle: FontStyle.italic)),
        ],
        if (actions != null) ...[const SizedBox(height: 10), actions!],
      ]),
    );
  }
}

// ---------------------------------------------------------------- PTM
class PtmScreen extends StatelessWidget {
  const PtmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final ptm = s.events.firstWhere((e) => e.type == 'PTM', orElse: () => s.events.first);
    final byTeacher = <String, List<PtmSlot>>{};
    for (final p in s.ptmSlots) {
      byTeacher.putIfAbsent(p.teacher, () => []).add(p);
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'ptm'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Parent–Teacher Meeting',
          title: '${weekday(ptm.date)}, ${fmtShort(ptm.date)}',
          subtitle: 'Pick a 15-minute slot. No more waiting in long queues. Video call option available.',
        ),
        for (final e in byTeacher.entries) ...[
          SectionTitle(e.key),
          Text(e.value.first.subject, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          gap(8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final slot in e.value)
              ChoiceChip(
                label: Text(slot.bookedBy == 'other' ? '${slot.time} · taken' : slot.time),
                selected: slot.bookedBy == 'me',
                onSelected: slot.bookedBy == 'other'
                    ? null
                    : (_) {
                        if (slot.bookedBy == 'me') {
                          s.cancelPtm(slot);
                          toast(context, 'Slot cancelled', icon: Icons.event_busy);
                        } else {
                          s.bookPtm(slot);
                          toast(context, 'Booked ${slot.time} with ${slot.teacher}. Reminder set.', icon: Icons.event_available);
                        }
                      },
              ),
          ]),
        ],
        gap(20),
        OutlinedButton.icon(
          onPressed: () => toast(context, 'Video PTM link will be shared 10 minutes before your slot', icon: Icons.videocam),
          icon: const Icon(Icons.videocam_outlined),
          label: const Text('Prefer a video PTM'),
        ),
      ]),
    );
  }
}

String schoolLabel() => '${MockData.schoolName}, ${MockData.schoolCity}';
