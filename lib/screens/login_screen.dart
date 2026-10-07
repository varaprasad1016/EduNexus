import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../l10n.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Role role = Role.parent;
  final phone = TextEditingController(text: '9876502140');
  final otp = TextEditingController();
  final school = TextEditingController(text: MockData.schoolCode);
  bool otpSent = false;
  bool consent = true;
  bool loading = false;

  static const names = {
    Role.parent: 'Srinivas Reddy',
    Role.teacher: 'Lakshmi Prasanna',
    Role.principal: 'Dr. Ramesh Varma',
  };

  Future<void> _continue() async {
    if (!otpSent) {
      if (phone.text.trim().length < 10) {
        toast(context, 'Enter a valid 10-digit mobile number', icon: Icons.error_outline);
        return;
      }
      setState(() => otpSent = true);
      toast(context, 'OTP sent via SMS & WhatsApp (demo OTP: 1234)', icon: Icons.sms_outlined);
      return;
    }
    if (otp.text.trim() != '1234') {
      toast(context, 'Incorrect OTP. Use 1234 for the demo.', icon: Icons.error_outline);
      return;
    }
    if (!consent) {
      toast(context, 'Please accept the data-privacy consent to continue', icon: Icons.privacy_tip_outlined);
      return;
    }
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    AppScope.read(context).login(role, names[role]!);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                initialValue: s.lang,
                onSelected: s.setLang,
                itemBuilder: (_) => [
                  for (final e in languages.entries) PopupMenuItem(value: e.key, child: Text(e.value)),
                ],
                child: Chip(avatar: const Icon(Icons.translate, size: 16), label: Text(languages[s.lang]!)),
              ),
            ),
            const SizedBox(height: 12),
            const Center(child: BrandMark(size: 92)),
            const SizedBox(height: 18),
            const Center(
              child: Text('EduNexus', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ),
            Center(
              child: Text('School · Parents · Students — connected',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            const SizedBox(height: 28),
            SegmentedButton<Role>(
              segments: const [
                ButtonSegment(value: Role.parent, label: Text('Parent'), icon: Icon(Icons.family_restroom)),
                ButtonSegment(value: Role.teacher, label: Text('Teacher'), icon: Icon(Icons.co_present_outlined)),
                ButtonSegment(value: Role.principal, label: Text('Principal'), icon: Icon(Icons.admin_panel_settings_outlined)),
              ],
              selected: {role},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => role = v.first),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: school,
              decoration: const InputDecoration(labelText: 'School code', prefixIcon: Icon(Icons.apartment_outlined)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Registered mobile number',
                prefixText: '+91 ',
                counterText: '',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            if (otpSent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: otp,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Demo OTP: 1234',
                  counterText: '',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
            const SizedBox(height: 8),
            CheckboxListTile(
              value: consent,
              onChanged: (v) => setState(() => consent = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: const Text(
                'I consent to the school processing my child\'s data for academic purposes as per the DPDP Act, 2023.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: loading ? null : _continue,
              child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : Text(otpSent ? 'Verify & sign in' : 'Get OTP'),
            ),
            const SizedBox(height: 18),
            Card(
              color: cs.secondaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Icon(Icons.info_outline, color: cs.onSecondaryContainer),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Demo build. Pick any role, tap Get OTP and enter 1234. Actions in one role (e.g. teacher approving leave) show up in the others.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
