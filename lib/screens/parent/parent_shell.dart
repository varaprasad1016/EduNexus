import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../l10n.dart';
import '../features/communication.dart';
import '../features/fees.dart';
import '../features/profile.dart';
import 'parent_home.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final pages = [
      ParentHome(onOpenTab: (i) => setState(() => index = i)),
      const InboxScreen(embedded: true),
      const FeesScreen(embedded: true),
      const ProfileScreen(embedded: true),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr(context, 'home')),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: s.unreadAnnouncements > 0,
              label: Text('${s.unreadAnnouncements}'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: const Icon(Icons.inbox),
            label: tr(context, 'inbox'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: tr(context, 'fees'),
          ),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: tr(context, 'profile')),
        ],
      ),
    );
  }
}
