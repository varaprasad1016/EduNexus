import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../l10n.dart';
import '../../main.dart' show logout;
import '../../theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool revealAadhaar = false;

  Future<void> _reveal() async {
    final pin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter app PIN'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Sensitive IDs are masked by default (DPDP Act). Demo PIN: 1234'),
          const SizedBox(height: 12),
          TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number, maxLength: 4, autofocus: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, pin.text == '1234'), child: const Text('Reveal')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      setState(() => revealAadhaar = true);
      Future.delayed(const Duration(seconds: 20), () {
        if (mounted) setState(() => revealAadhaar = false);
      });
    } else if (ok == false) {
      toast(context, 'Incorrect PIN', icon: Icons.lock);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.embedded,
          title: Text(tr(context, 'profile')),
          actions: [
            IconButton(onPressed: () => push(context, const SettingsScreen()), icon: const Icon(Icons.settings_outlined)),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(children: [
                  GradientHeader(
                    title: c.name,
                    subtitle: '${c.classLabel} · Roll ${c.rollNo} · ${c.house} House',
                    trailing: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(c.initials, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c.color)),
                    ),
                    bottom: Wrap(spacing: 8, children: [
                      for (int i = 0; i < s.children.length; i++)
                        ChoiceChip(
                          label: Text(s.children[i].firstName),
                          selected: s.childIndex == i,
                          onSelected: (_) => s.setChild(i),
                        ),
                    ]),
                  ),
                  gap(8),
                  const TabBar(tabs: [Tab(text: 'Personal'), Tab(text: 'Academic'), Tab(text: 'ID & Admin')]),
                ]),
              ),
            ),
          ],
          body: TabBarView(children: [
            PageList(children: [
              AppCard(
                child: Column(children: [
                  InfoRow('Admission no.', c.admNo),
                  InfoRow('Date of birth', c.dob),
                  InfoRow('Blood group', c.bloodGroup),
                  InfoRow('Father', c.father),
                  InfoRow('Mother', c.mother),
                  InfoRow('Contact', c.phone),
                  InfoRow('Email', c.email),
                  InfoRow('Address', c.address),
                ]),
              ),
              gap(12),
              FilledButton.tonalIcon(
                onPressed: () => toast(context, 'Change request sent to the school office for verification', icon: Icons.edit),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Request a correction'),
              ),
              gap(8),
              OutlinedButton.icon(
                onPressed: () => logout(context),
                icon: const Icon(Icons.logout),
                label: Text(tr(context, 'logout')),
              ),
            ]),
            PageList(children: [
              AppCard(
                child: Column(children: [
                  InfoRow('Class teacher', c.classTeacher),
                  InfoRow('House', c.house),
                  InfoRow('Languages', c.languages.join(', ')),
                  InfoRow('Activities', c.activities.join(', ')),
                  InfoRow('Board', 'CBSE'),
                  InfoRow('Transport', c.busRoute),
                  InfoRow('Bus stop', c.busStop),
                ]),
              ),
            ]),
            PageList(children: [
              AppCard(
                child: Column(children: [
                  InfoRow(
                    'Aadhaar',
                    revealAadhaar ? c.aadhaar.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim() : c.maskedAadhaar,
                    trailing: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: revealAadhaar ? () => setState(() => revealAadhaar = false) : _reveal,
                      icon: Icon(revealAadhaar ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    ),
                  ),
                  InfoRow('APAAR ID', c.apaar),
                  InfoRow('PEN', c.pen),
                  InfoRow('UDISE+ school', '2816 0100 512'),
                ]),
              ),
              gap(14),
              // Digital ID card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8F2)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(gradient: AppColors.brand),
                    child: Row(children: [
                      const BrandMark(size: 34),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(MockData.schoolName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                      Text(MockData.schoolCode, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 17)),
                          Text(c.classLabel, style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text('Adm: ${c.admNo}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Text('Blood: ${c.bloodGroup}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Text('Bus: ${c.busRoute}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ]),
                      ),
                      PseudoQr(data: c.admNo, size: 92),
                    ]),
                  ),
                ]),
              ),
              gap(8),
              Text('Digital ID · scanned at the gate, library and canteen',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ]),
        ),
      ),
    );
  }
}
