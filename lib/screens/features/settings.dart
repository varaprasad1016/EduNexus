import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../l10n.dart';
import '../../main.dart' show logout;
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'settings'))),
      body: PageList(children: [
        const SectionTitle('Language'),
        AppCard(
          child: Wrap(spacing: 8, children: [
            for (final e in languages.entries)
              ChoiceChip(label: Text(e.value), selected: s.lang == e.key, onSelected: (_) => s.setLang(e.key)),
          ]),
        ),
        const SectionTitle('Display'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              value: s.darkMode,
              onChanged: (v) => s.toggle(() => s.darkMode = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.data_saver_on_outlined),
              title: const Text('Lite mode'),
              subtitle: const Text('Fewer images and animations – for low-end phones and slow data'),
              value: s.liteMode,
              onChanged: (v) => s.toggle(() => s.liteMode = v),
            ),
          ]),
        ),
        const SectionTitle('Notifications'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('App notifications'),
              value: s.notifyApp,
              onChanged: (v) => s.toggle(() => s.notifyApp = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.chat_outlined),
              title: const Text('WhatsApp messages'),
              subtitle: const Text('Absent alerts, fee reminders, notices'),
              value: s.notifyWhatsApp,
              onChanged: (v) => s.toggle(() => s.notifyWhatsApp = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.sms_outlined),
              title: const Text('SMS fallback'),
              subtitle: const Text('When there is no internet'),
              value: s.notifySms,
              onChanged: (v) => s.toggle(() => s.notifySms = v),
            ),
            ListTile(
              leading: const Icon(Icons.notification_add_outlined),
              title: const Text('Send a test notification'),
              onTap: () => toast(context, 'Test notification delivered ✔', icon: Icons.notifications_active),
            ),
          ]),
        ),
        const SectionTitle('Privacy & data (DPDP Act 2023)'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Consent given'),
              subtitle: Text(s.consentAt == null ? '—' : '${fmtDate(s.consentAt!)} · ${fmtTime(s.consentAt!)}'),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_done_outlined),
              title: const Text('Data stored in India'),
              subtitle: const Text('Encrypted at rest and in transit'),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download my data'),
              onTap: () => toast(context, 'Your data export will be emailed within 24 hours', icon: Icons.mail_outline),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Request data deletion'),
              onTap: () => toast(context, 'Request sent to the school\'s data protection officer', icon: Icons.privacy_tip_outlined),
            ),
          ]),
        ),
        const SectionTitle('Security'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: const Text('Change app PIN'),
              onTap: () => toast(context, 'PIN updated (demo)', icon: Icons.lock),
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('Logged-in devices'),
              subtitle: const Text('This phone · 1 other device'),
              onTap: () => toast(context, 'Other devices logged out', icon: Icons.logout),
            ),
          ]),
        ),
        gap(20),
        const Center(child: BrandMark(size: 48)),
        gap(8),
        const Center(child: Text('EduNexus · v1.0.0 (demo)', style: TextStyle(fontWeight: FontWeight.w700))),
        const Center(child: Text('Made in India 🇮🇳', style: TextStyle(fontSize: 12))),
        gap(16),
        OutlinedButton.icon(onPressed: () => logout(context), icon: const Icon(Icons.logout), label: Text(tr(context, 'logout'))),
      ]),
    );
  }
}
