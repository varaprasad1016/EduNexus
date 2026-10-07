import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../features/academics.dart';
import '../features/attendance.dart';
import '../features/communication.dart';
import '../features/growth.dart';
import '../features/marks.dart';
import '../features/services.dart';
import '../features/settings.dart';

class Feature {
  const Feature(this.key, this.icon, this.color, this.page);
  final String key;
  final IconData icon;
  final Color color;
  final Widget Function() page;
}

final featureGroups = <String, List<Feature>>{
  'communication': [
    Feature('announcements', Icons.campaign_outlined, AppColors.saffron, () => const AnnouncementsScreen()),
    Feature('noticeBoard', Icons.push_pin_outlined, AppColors.indigo, () => const NoticeBoardScreen()),
    Feature('applyLeave', Icons.event_busy_outlined, AppColors.pink, () => const LeaveScreen()),
    Feature('writeToSchool', Icons.forum_outlined, AppColors.teal, () => const WriteToSchoolScreen()),
    Feature('ptm', Icons.groups_2_outlined, AppColors.violet, () => const PtmScreen()),
  ],
  'academics': [
    Feature('homework', Icons.edit_note, const Color(0xFF2563EB), () => const HomeworkScreen()),
    Feature('classwork', Icons.class_outlined, AppColors.green, () => const ClassWorkScreen()),
    Feature('attendance', Icons.how_to_reg_outlined, AppColors.teal, () => const AttendanceScreen()),
    Feature('marks', Icons.insights_outlined, AppColors.violet, () => const MarksScreen()),
    Feature('econtent', Icons.folder_copy_outlined, AppColors.amber, () => const EContentScreen()),
    Feature('timetable', Icons.schedule, AppColors.sky, () => const TimetableScreen()),
    Feature('calendar', Icons.calendar_month_outlined, AppColors.red, () => const CalendarScreen()),
    Feature('onlineTest', Icons.quiz_outlined, AppColors.indigo, () => const OnlineTestsScreen()),
    Feature('steamLab', Icons.precision_manufacturing_outlined, AppColors.pink, () => const SteamLabScreen()),
  ],
  'services': [
    Feature('bus', Icons.directions_bus_outlined, AppColors.amber, () => const BusScreen()),
    Feature('gatePass', Icons.verified_user_outlined, AppColors.green, () => const PickupPassScreen()),
    Feature('health', Icons.favorite_border, AppColors.red, () => const HealthScreen()),
    Feature('wallet', Icons.restaurant_outlined, AppColors.saffron, () => const WalletScreen()),
    Feature('store', Icons.storefront_outlined, AppColors.indigo, () => const StoreScreen()),
    Feature('gallery', Icons.photo_library_outlined, AppColors.sky, () => const GalleryScreen()),
  ],
  'growth': [
    Feature('aiSummary', Icons.auto_awesome, AppColors.violet, () => const AiSummaryScreen()),
    Feature('refer', Icons.card_giftcard, AppColors.saffron, () => const ReferScreen()),
  ],
};

class ParentHome extends StatelessWidget {
  const ParentHome({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        sliver: SliverList.list(children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${tr(context, 'hello')}, ${s.userName.split(' ').first} 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text('${MockData.schoolName}, ${MockData.schoolCity}',
                    style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
            IconButton(
              tooltip: tr(context, 'language'),
              onPressed: () => _pickLanguage(context),
              icon: const Icon(Icons.translate),
            ),
            IconButton(
              tooltip: tr(context, 'settings'),
              onPressed: () => push(context, const SettingsScreen()),
              icon: const Icon(Icons.settings_outlined),
            ),
          ]),
          const SizedBox(height: 12),
          _ChildSwitcher(),
          const SizedBox(height: 14),
          _GlanceRow(onOpenTab: onOpenTab),
          if (!s.liteMode) ...[
            const SizedBox(height: 14),
            _AiBanner(childName: c.firstName),
          ],
        ]),
      ),
      for (final g in featureGroups.entries) ...[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverToBoxAdapter(child: SectionTitle(tr(context, g.key))),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.count(
            crossAxisCount: s.liteMode ? 4 : 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: s.liteMode ? 0.95 : 1.02,
            children: [for (final f in g.value) _FeatureTile(f, lite: s.liteMode)],
          ),
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ]);
  }

  void _pickLanguage(BuildContext context) {
    final s = AppScope.read(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final e in languages.entries)
            ListTile(
              title: Text(e.value),
              trailing: s.lang == e.key ? const Icon(Icons.check_circle, color: AppColors.green) : null,
              onTap: () {
                s.setLang(e.key);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _ChildSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: s.children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = s.children[i];
          final sel = i == s.childIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => s.setChild(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel ? AppColors.brand : null,
                color: sel ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sel ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: sel ? Colors.white : c.color.withValues(alpha: 0.15),
                  child: Text(c.initials, style: TextStyle(color: c.color, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: TextStyle(fontWeight: FontWeight.w800, color: sel ? Colors.white : null)),
                  Text('${c.classLabel} · Roll ${c.rollNo}',
                      style: TextStyle(fontSize: 12, color: sel ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant)),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _GlanceRow extends StatelessWidget {
  const _GlanceRow({required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    final att = s.attendanceToday(c.id);
    final (attLabel, attColor, attIcon) = switch (att) {
      AttStatus.present => (tr(context, 'present'), AppColors.green, Icons.check_circle),
      AttStatus.absent => (tr(context, 'absent'), AppColors.red, Icons.cancel),
      AttStatus.leave => (tr(context, 'onLeave'), AppColors.amber, Icons.event_busy),
      AttStatus.holiday => (tr(context, 'holiday'), AppColors.slate, Icons.beach_access),
      null => (tr(context, 'notMarked'), AppColors.slate, Icons.hourglass_top),
    };
    final next = s.nextPeriod(c.id);
    final due = s.dueNow(c.id);
    final hw = s.pendingHomework(c.id);

    Widget tile(String label, String value, IconData icon, Color color, VoidCallback onTap, {String? sub}) => SizedBox(
          width: 150,
          child: AppCard(
            onTap: onTap,
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.outline),
              ]),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
              if (sub != null)
                Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
            ]),
          ),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tr(context, 'atAGlance'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 10),
      SizedBox(
        height: 118,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          tile(tr(context, 'attendance'), attLabel, attIcon, attColor, () => push(context, const AttendanceScreen())),
          const SizedBox(width: 10),
          tile(tr(context, 'pendingHw'), '$hw', Icons.edit_note, const Color(0xFF2563EB), () => push(context, const HomeworkScreen()),
              sub: hw == 0 ? 'All done 🎉' : 'tap to view'),
          const SizedBox(width: 10),
          tile(tr(context, 'nextClass'), next?.subject ?? tr(context, 'classesOver'), Icons.schedule, AppColors.sky,
              () => push(context, const TimetableScreen()),
              sub: next == null ? null : '${next.start} · ${next.teacher}'),
          const SizedBox(width: 10),
          tile(tr(context, 'busEta'), 'Live', Icons.directions_bus, AppColors.amber, () => push(context, const BusScreen()),
              sub: c.busRoute),
          const SizedBox(width: 10),
          tile(tr(context, 'feeDue'), due == 0 ? 'No dues' : inr(due), Icons.currency_rupee, due == 0 ? AppColors.green : AppColors.red,
              () => onOpenTab(2),
              sub: due == 0 ? null : tr(context, 'payNow')),
        ]),
      ),
    ]);
  }
}

class _AiBanner extends StatelessWidget {
  const _AiBanner({required this.childName});
  final String childName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => push(context, const AiSummaryScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFEC4899)]),
        ),
        child: Row(children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.auto_awesome, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(context, 'aiCard'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('$childName\'s attendance, homework and marks in one read',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            ]),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ]),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile(this.f, {required this.lite});
  final Feature f;
  final bool lite;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    int badge = 0;
    if (f.key == 'announcements') badge = s.unreadAnnouncements;
    if (f.key == 'homework') badge = s.pendingHomework(s.child.id);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      onTap: () => push(context, f.page()),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Badge(
          isLabelVisible: badge > 0,
          label: Text('$badge'),
          child: lite
              ? Icon(f.icon, color: f.color, size: 26)
              : Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(f.icon, color: f.color, size: 26),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(context, f.key),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: lite ? 11 : 12.5, fontWeight: FontWeight.w700, height: 1.15),
        ),
      ]),
    );
  }
}
