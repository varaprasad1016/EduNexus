import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final selected = <String>{};
  String? childId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (childId != s.child.id) {
      // default selection: everything overdue or due within 31 days
      childId = s.child.id;
      selected
        ..clear()
        ..addAll(s.feesFor(s.child.id).where((f) => !f.isPaid && f.due.isBefore(DateTime.now().add(const Duration(days: 31)))).map((f) => f.id));
    }
    final fees = s.feesFor(s.child.id);
    final unpaid = fees.where((f) => !f.isPaid).toList()..sort((a, b) => a.due.compareTo(b.due));
    final chosen = unpaid.where((f) => selected.contains(f.id)).toList();
    final total = chosen.fold<double>(0, (a, f) => a + f.balance);
    final paidYear = fees.fold<double>(0, (a, f) => a + f.paid);
    final yearTotal = fees.fold<double>(0, (a, f) => a + f.amount);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !widget.embedded,
          title: Text(tr(context, 'fees')),
          bottom: const TabBar(tabs: [Tab(text: 'Pay fees'), Tab(text: 'Receipts')]),
        ),
        body: TabBarView(children: [
          PageList(padding: const EdgeInsets.fromLTRB(16, 14, 16, 120), children: [
            GradientHeader(
              eyebrow: 'Current payable · ${s.child.firstName}',
              title: inr(total),
              subtitle: 'Total of the selected fees',
              bottom: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: yearTotal == 0 ? 0 : paidYear / yearTotal,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${inr(paidYear)} of ${inr(yearTotal)} paid this year',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              ]),
            ),
            gap(12),
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.autorenew, color: AppColors.violet),
                title: const Text('UPI Autopay', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(s.upiAutopay
                    ? 'Fees will be debited automatically on the due date. You get a WhatsApp alert 3 days before.'
                    : 'Never miss a due date. Set up a one-time UPI mandate.'),
                value: s.upiAutopay,
                onChanged: (v) {
                  s.toggle(() => s.upiAutopay = v);
                  toast(context, v ? 'UPI Autopay mandate created (demo)' : 'Autopay turned off', icon: Icons.autorenew);
                },
              ),
            ),
            if (unpaid.isEmpty)
              const EmptyState(icon: Icons.verified, title: 'All fees paid 🎉', message: 'Receipts are available in the Receipts tab.'),
            if (unpaid.isNotEmpty) ...[
              Row(children: [
                const Expanded(child: SectionTitle('Fee items')),
                TextButton(
                  onPressed: () => setState(() {
                    if (selected.length == unpaid.length) {
                      selected.clear();
                    } else {
                      selected.addAll(unpaid.map((f) => f.id));
                    }
                  }),
                  child: Text(selected.length == unpaid.length ? 'Clear all' : 'Select all'),
                ),
              ]),
              for (final f in unpaid) ...[
                AppCard(
                  accent: f.overdue ? AppColors.red : null,
                  padding: const EdgeInsets.fromLTRB(4, 8, 14, 8),
                  onTap: () => setState(() => selected.contains(f.id) ? selected.remove(f.id) : selected.add(f.id)),
                  child: Row(children: [
                    Checkbox(
                      value: selected.contains(f.id),
                      onChanged: (_) => setState(() => selected.contains(f.id) ? selected.remove(f.id) : selected.add(f.id)),
                    ),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(f.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Text('Due ${fmtDate(f.due)}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          if (f.overdue) const Pill('Overdue', color: AppColors.red),
                          if (f.paid > 0) Pill('Part-paid ${inr(f.paid)}', color: AppColors.sky),
                        ]),
                      ]),
                    ),
                    Text(inr(f.balance), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ]),
                ),
                gap(8),
              ],
            ],
            if (fees.any((f) => f.isPaid)) ...[
              const SectionTitle('Paid'),
              for (final f in fees.where((f) => f.isPaid)) ...[
                Opacity(
                  opacity: 0.7,
                  child: AppCard(
                    child: Row(children: [
                      const Icon(Icons.check_circle, color: AppColors.green),
                      const SizedBox(width: 10),
                      Expanded(child: Text(f.title)),
                      Text(inr(f.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                gap(8),
              ],
            ],
            gap(8),
            AppCard(
              accent: AppColors.amber,
              child: Row(children: [
                const Expanded(
                  child: Text('Money debited but no receipt? Check the payment status (last 2 days).', style: TextStyle(fontSize: 13)),
                ),
                TextButton(
                  onPressed: () => toast(context, 'No pending transactions found', icon: Icons.verified_outlined),
                  child: const Text('Status check'),
                ),
              ]),
            ),
          ]),
          _ReceiptsTab(),
        ]),
        bottomSheet: total <= 0
            ? null
            : Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(children: [
                    Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('YOU ARE PAYING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                        Text(inr(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    FilledButton.icon(
                      onPressed: () => _pay(context, s, chosen, total),
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: Text(tr(context, 'payNow')),
                    ),
                  ]),
                ),
              ),
      ),
    );
  }

  Future<void> _pay(BuildContext context, AppState s, List<FeeItem> items, double total) async {
    final partialCtrl = TextEditingController();
    bool partial = false;
    final method = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pay ${inr(total)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('${items.length} item${items.length > 1 ? 's' : ''} · ${s.child.name}'),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pay part amount'),
              subtitle: const Text('Pay in instalments if needed'),
              value: partial,
              onChanged: (v) => setSheet(() => partial = v),
            ),
            if (partial)
              TextField(
                controller: partialCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Amount'),
              ),
            const SizedBox(height: 12),
            const Text('Choose payment method', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final m in [
              ('UPI · Google Pay', Icons.account_balance_wallet, AppColors.sky),
              ('UPI · PhonePe', Icons.phone_android, AppColors.violet),
              ('UPI · Paytm', Icons.payments_outlined, const Color(0xFF00B9F1)),
              ('UPI · BHIM / any UPI ID', Icons.qr_code_2, AppColors.saffron),
              ('Debit / Credit card', Icons.credit_card, AppColors.indigo),
              ('Net banking', Icons.account_balance, AppColors.green),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: m.$3.withValues(alpha: 0.12), child: Icon(m.$2, color: m.$3)),
                title: Text(m.$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, m.$1),
              ),
            const SizedBox(height: 4),
            const Row(children: [
              Icon(Icons.lock, size: 14),
              SizedBox(width: 6),
              Text('Secured by the payment gateway · PCI-DSS', style: TextStyle(fontSize: 12)),
            ]),
          ]),
        ),
      ),
    );
    if (method == null || !context.mounted) return;
    double? amount;
    if (partial) {
      amount = double.tryParse(partialCtrl.text.trim());
      if (amount == null || amount <= 0 || amount > total) {
        toast(context, 'Enter a valid part amount up to ${inr(total)}', icon: Icons.error_outline);
        return;
      }
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 18),
          Expanded(child: Text('Waiting for UPI approval…')),
        ]),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!context.mounted) return;
    Navigator.pop(context);
    final r = s.payFees(s.child.id, items, method, partial: amount);
    setState(() => selected.clear());
    push(context, ReceiptScreen(r: r));
  }
}

class _ReceiptsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = s.receiptsFor(s.child.id);
    if (list.isEmpty) return const EmptyState(icon: Icons.receipt_long, title: 'No receipts yet');
    return PageList(padding: const EdgeInsets.fromLTRB(16, 14, 16, 32), children: [
      for (final r in list) ...[
        AppCard(
          onTap: () => push(context, ReceiptScreen(r: r)),
          child: Row(children: [
            const CircleAvatar(child: Icon(Icons.receipt_long)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${r.no} · ${fmtDate(r.date)} · ${r.mode}', style: const TextStyle(fontSize: 12)),
              ]),
            ),
            Text(inr(r.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
        ),
        gap(8),
      ],
    ]);
  }
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.r});
  final Receipt r;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.children.firstWhere((c) => c.id == r.childId);
    return Scaffold(
      appBar: AppBar(title: const Text('Fee receipt')),
      body: PageList(children: [
        gap(10),
        const Center(child: CircleAvatar(radius: 36, backgroundColor: AppColors.green, child: Icon(Icons.check, color: Colors.white, size: 40))),
        gap(12),
        Center(child: Text(inr(r.amount), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900))),
        const Center(child: Text('Payment successful')),
        gap(20),
        AppCard(
          child: Column(children: [
            InfoRow('Receipt no.', r.no),
            InfoRow('Student', '${c.name} · ${c.classLabel}'),
            InfoRow('Admission no.', c.admNo),
            InfoRow('Towards', r.title),
            InfoRow('Paid via', r.mode),
            InfoRow('Date', '${fmtDate(r.date)} · ${fmtTime(r.date)}'),
            const InfoRow('GSTIN', 'Exempt – educational services'),
          ]),
        ),
        gap(16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => toast(context, 'Receipt PDF saved', icon: Icons.download_done),
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => toast(context, 'Receipt shared on WhatsApp', icon: Icons.share),
              icon: const Icon(Icons.share),
              label: const Text('WhatsApp'),
            ),
          ),
        ]),
      ]),
    );
  }
}
