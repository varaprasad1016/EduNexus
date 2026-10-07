import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';

// ---------------------------------------------------------------- Bus tracking
class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> with SingleTickerProviderStateMixin {
  late final AnimationController ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 90))..forward(from: 0.18);

  static const stops = [
    ('School depot', '7:05'),
    ('Patamata', '7:18'),
    ('Auto Nagar', '7:26'),
    ('Benz Circle', '7:40'),
    ('Labbipet', '7:48'),
    ('School', '8:20'),
  ];
  static const stopAt = [0.0, 0.2, 0.38, 0.6, 0.75, 1.0];
  static const myStop = 3;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'bus'))),
      body: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) {
          final t = ctrl.value;
          final passed = stopAt.where((p) => p <= t).length - 1;
          final etaMin = t >= stopAt[myStop] ? 0 : ((stopAt[myStop] - t) * 40).ceil();
          final boarded = t >= stopAt[myStop];
          return PageList(children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8EEF7) : const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(painter: _RoutePainter(t, stopAt, myStop), child: const SizedBox.expand()),
              ),
            ),
            gap(12),
            GradientHeader(
              eyebrow: '${s.child.busRoute} · AP 16 TX 4471',
              title: boarded ? 'On board ✅' : 'Arriving in $etaMin min',
              subtitle: boarded
                  ? '${s.child.firstName} tapped RFID card at ${stops[myStop].$1} · ${stops[myStop].$2} AM'
                  : 'Next stop: ${stops[min(passed + 1, stops.length - 1)].$1} · Your stop: ${stops[myStop].$1}',
              trailing: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.directions_bus, color: Colors.white)),
            ),
            gap(12),
            Row(children: [
              const Expanded(child: StatTile(label: 'Driver', value: 'Ramu K', sub: '★ 4.8 · 9 yrs', icon: Icons.person, color: AppColors.sky)),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(label: 'Speed', value: '${(28 + 10 * sin(t * 20)).round()} km/h', sub: 'Limit 40', icon: Icons.speed, color: AppColors.green),
              ),
              const SizedBox(width: 10),
              const Expanded(child: StatTile(label: 'Attendant', value: 'Sarala', sub: 'Lady attendant', icon: Icons.support_agent, color: AppColors.pink)),
            ]),
            const SectionTitle('Stops'),
            AppCard(
              child: Column(children: [
                for (int i = 0; i < stops.length; i++)
                  Row(children: [
                    Column(children: [
                      Container(width: 2, height: 12, color: i == 0 ? Colors.transparent : (i <= passed ? AppColors.green : Colors.grey.shade300)),
                      CircleAvatar(
                        radius: i == myStop ? 9 : 6,
                        backgroundColor: i <= passed ? AppColors.green : (i == myStop ? AppColors.saffron : Colors.grey.shade400),
                      ),
                      Container(width: 2, height: 12, color: i == stops.length - 1 ? Colors.transparent : (i < passed ? AppColors.green : Colors.grey.shade300)),
                    ]),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(stops[i].$1 + (i == myStop ? '  (your stop)' : ''),
                          style: TextStyle(fontWeight: i == myStop ? FontWeight.w800 : FontWeight.w500)),
                    ),
                    Text('${stops[i].$2} AM', style: const TextStyle(fontSize: 12.5)),
                  ]),
              ]),
            ),
            gap(12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => toast(context, 'Calling transport desk…', icon: Icons.call),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Transport desk'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => toast(context, 'You\'ll be alerted when the bus is 1 stop away', icon: Icons.notifications_active),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Alert me'),
                ),
              ),
            ]),
          ]);
        },
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.t, this.stopAt, this.myStop);
  final double t;
  final List<double> stopAt;
  final int myStop;

  Path _route(Size s) => Path()
    ..moveTo(s.width * 0.08, s.height * 0.85)
    ..cubicTo(s.width * 0.25, s.height * 0.9, s.width * 0.2, s.height * 0.45, s.width * 0.42, s.height * 0.5)
    ..cubicTo(s.width * 0.62, s.height * 0.55, s.width * 0.55, s.height * 0.12, s.width * 0.75, s.height * 0.18)
    ..cubicTo(s.width * 0.9, s.height * 0.22, s.width * 0.85, s.height * 0.6, s.width * 0.92, s.height * 0.7);

  @override
  void paint(Canvas canvas, Size size) {
    // faux map blocks
    final block = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final r = Random(3);
    for (int i = 0; i < 26; i++) {
      final x = r.nextDouble() * size.width, y = r.nextDouble() * size.height;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 30 + r.nextDouble() * 50, 20 + r.nextDouble() * 30), const Radius.circular(6)), block);
    }
    final river = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawPath(Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width, size.height * 0.35), river);

    final path = _route(size);
    final metric = path.computeMetrics().first;
    canvas.drawPath(path, Paint()
      ..color = AppColors.slate.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(metric.extractPath(0, metric.length * t), Paint()
      ..color = AppColors.violet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round);

    for (int i = 0; i < stopAt.length; i++) {
      final pos = metric.getTangentForOffset(metric.length * stopAt[i])!.position;
      canvas.drawCircle(pos, i == myStop ? 10 : 7, Paint()..color = Colors.white);
      canvas.drawCircle(pos, i == myStop ? 6 : 4, Paint()..color = i == myStop ? AppColors.saffron : AppColors.indigo);
    }
    final bus = metric.getTangentForOffset(metric.length * t)!.position;
    canvas.drawCircle(bus, 18, Paint()..color = AppColors.amber.withValues(alpha: 0.3));
    canvas.drawCircle(bus, 12, Paint()..color = AppColors.amber);
    final tp = TextPainter(
      text: TextSpan(text: String.fromCharCode(Icons.directions_bus.codePoint),
          style: TextStyle(fontFamily: Icons.directions_bus.fontFamily, package: Icons.directions_bus.fontPackage, fontSize: 15, color: Colors.white)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, bus - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.t != t;
}

// ---------------------------------------------------------------- Gallery
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final latest = s.albums.first;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'gallery'))),
      body: PageList(children: [
        _AlbumCover(album: latest, height: 190, latest: true),
        gap(12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [for (final a in s.albums.skip(1)) _AlbumCover(album: a, height: 120)],
        ),
      ]),
    );
  }
}

class _AlbumCover extends StatelessWidget {
  const _AlbumCover({required this.album, required this.height, this.latest = false});
  final Album album;
  final double height;
  final bool latest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => push(context, _AlbumScreen(album: album)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [album.color, album.color.withValues(alpha: 0.55)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Stack(children: [
            Center(child: Icon(album.icon, size: height * 0.4, color: Colors.white.withValues(alpha: 0.9))),
            if (latest) const Positioned(left: 10, top: 10, child: Pill('LATEST ALBUM', color: Colors.black54, solid: true)),
            Positioned(right: 10, bottom: 10, child: Pill('${album.count} photos', color: Colors.black45, solid: true, icon: Icons.photo)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(fmtDate(album.date), style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class _AlbumScreen extends StatelessWidget {
  const _AlbumScreen({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(album.title), actions: [
        IconButton(
          onPressed: () => toast(context, 'Downloading ${album.count} photos…', icon: Icons.download),
          icon: const Icon(Icons.download_outlined),
        ),
      ]),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
        itemCount: album.count,
        itemBuilder: (context, i) {
          final shade = 0.45 + (i % 5) * 0.11;
          return InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (_) => Dialog(
                clipBehavior: Clip.antiAlias,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    height: 280,
                    color: album.color.withValues(alpha: shade),
                    child: Center(child: Icon(album.icon, color: Colors.white, size: 90)),
                  ),
                  ListTile(
                    title: Text('${album.title} · ${i + 1}/${album.count}'),
                    subtitle: const Text('Face-tagged: only photos with your child are highlighted'),
                  ),
                ]),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(color: album.color.withValues(alpha: shade), borderRadius: BorderRadius.circular(10)),
              child: Icon(album.icon, color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Pickup pass
class PickupPassScreen extends StatefulWidget {
  const PickupPassScreen({super.key});

  @override
  State<PickupPassScreen> createState() => _PickupPassScreenState();
}

class _PickupPassScreenState extends State<PickupPassScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  String relation = 'Uncle / Aunt';
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = s.child;
    final passes = s.pickupPasses.where((p) => p.childId == c.id && p.expires.isAfter(DateTime.now())).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'gatePass'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Safe pickup',
          title: 'Only authorised people can pick up ${c.firstName}',
          subtitle: 'The gate staff scan the QR or enter the OTP. You get an instant alert with a photo.',
          gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF14B8A6)]),
        ),
        const SectionTitle('Always authorised'),
        AppCard(
          child: Column(children: [
            for (final p in [(c.father, 'Father'), (c.mother, 'Mother'), ('Narasimha Reddy', 'Grandfather')])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(p.$1[0])),
                title: Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(p.$2),
                trailing: const Icon(Icons.verified, color: AppColors.green),
              ),
          ]),
        ),
        for (final p in passes) ...[
          const SectionTitle('Active one-time pass'),
          AppCard(
            accent: AppColors.green,
            child: Column(children: [
              PseudoQr(data: p.otp, size: 150),
              gap(10),
              Text(p.otp.split('').join(' '), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text('${p.name} (${p.relation}) · ${p.phone}'),
              gap(4),
              Pill('Valid for ${p.expires.difference(DateTime.now()).inMinutes} min', color: AppColors.green, icon: Icons.timer_outlined),
              gap(8),
              OutlinedButton.icon(
                onPressed: () => toast(context, 'Pass sent to ${p.name} on WhatsApp', icon: Icons.send),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Send to pickup person'),
              ),
            ]),
          ),
        ],
        const SectionTitle('Create a one-time pickup pass'),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Pickup person\'s name')),
        gap(10),
        DropdownButtonFormField<String>(
          initialValue: relation,
          decoration: const InputDecoration(labelText: 'Relation'),
          items: [for (final r in ['Uncle / Aunt', 'Driver', 'Neighbour', 'Family friend', 'Other']) DropdownMenuItem(value: r, child: Text(r))],
          onChanged: (v) => setState(() => relation = v!),
        ),
        gap(10),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Mobile number', prefixText: '+91 '),
        ),
        gap(12),
        FilledButton.icon(
          onPressed: () {
            if (name.text.trim().isEmpty || phone.text.trim().length < 10) {
              toast(context, 'Enter name and a 10-digit mobile number', icon: Icons.error_outline);
              return;
            }
            s.createPickupPass(c.id, name.text.trim(), relation, phone.text.trim());
            name.clear();
            phone.clear();
            toast(context, 'One-time pass created · valid 4 hours');
          },
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Generate pass'),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Health
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final h = MockData.healthRecord[s.child.id]!;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'health'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Health record',
          title: s.child.name,
          subtitle: 'Blood group ${s.child.bloodGroup} · Last check-up ${fmtDate(daysAgo(40))}',
          gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEC4899)]),
        ),
        gap(12),
        Row(children: [
          Expanded(child: StatTile(label: 'Height', value: h['height']!, icon: Icons.height, color: AppColors.sky)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Weight', value: h['weight']!, icon: Icons.monitor_weight_outlined, color: AppColors.violet)),
        ]),
        gap(10),
        Row(children: [
          Expanded(child: StatTile(label: 'BMI', value: h['bmi']!, icon: Icons.favorite_outline, color: AppColors.green)),
          const SizedBox(width: 10),
          Expanded(child: StatTile(label: 'Vision', value: h['vision']!, icon: Icons.visibility_outlined, color: AppColors.teal)),
        ]),
        gap(10),
        AppCard(
          accent: AppColors.red,
          child: Column(children: [
            InfoRow('Allergies', h['allergies']!),
            InfoRow('Conditions', h['conditions']!),
            const InfoRow('Emergency contact', 'Father · +91 98xxxx2140'),
          ]),
        ),
        const SectionTitle('Vaccinations'),
        AppCard(
          child: Column(children: [
            for (final v in MockData.vaccinations)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  v[1] == 'Done' ? Icons.check_circle : Icons.schedule,
                  color: v[1] == 'Done' ? AppColors.green : AppColors.amber,
                ),
                title: Text(v[0], style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(v[1]),
              ),
          ]),
        ),
        const SectionTitle('Infirmary visits'),
        AppCard(
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.healing_outlined)),
              title: const Text('Minor scrape during skating'),
              subtitle: Text('${fmtDate(daysAgo(18))} · Cleaned and dressed. Parent informed.'),
            ),
          ]),
        ),
        gap(10),
        OutlinedButton.icon(
          onPressed: () => toast(context, 'Health record updated (demo)', icon: Icons.edit),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Update allergies / medical notes'),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Canteen wallet
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final bal = s.walletBalance(s.child.id);
    final txns = s.walletFor(s.child.id);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'wallet'))),
      body: PageList(children: [
        GradientHeader(
          eyebrow: 'Cashless canteen · ID card tap',
          title: inr(bal),
          subtitle: 'Balance for ${s.child.firstName}',
          gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFF59E0B)]),
          bottom: Row(children: [
            for (final a in [200, 500, 1000]) ...[
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.saffron, minimumSize: const Size(0, 42)),
                  onPressed: () {
                    s.topUpWallet(s.child.id, a.toDouble());
                    toast(context, 'Added ${inr(a)} via UPI');
                  },
                  child: Text('+ ${inr(a)}'),
                ),
              ),
              if (a != 1000) const SizedBox(width: 8),
            ],
          ]),
        ),
        gap(12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Daily spend limit', style: TextStyle(fontWeight: FontWeight.w700))),
              Text(inr(s.walletDailyLimit), style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
            Slider(
              value: s.walletDailyLimit,
              min: 50,
              max: 300,
              divisions: 10,
              label: inr(s.walletDailyLimit),
              onChanged: (v) => s.toggle(() => s.walletDailyLimit = v),
            ),
            const Text('Junk food is blocked automatically. Allergy items (peanuts) are flagged at the counter.', style: TextStyle(fontSize: 12.5)),
          ]),
        ),
        const SectionTitle('Today\'s menu'),
        SizedBox(
          height: 96,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final m in [('Idli & chutney', 40, Icons.rice_bowl), ('Veg sandwich', 45, Icons.lunch_dining), ('Fruit bowl', 35, Icons.apple), ('Lemon rice', 50, Icons.ramen_dining), ('Buttermilk', 15, Icons.local_drink)])
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(m.$3, color: AppColors.saffron),
                    const Spacer(),
                    Text(m.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    Text(inr(m.$2), style: const TextStyle(fontSize: 12)),
                  ]),
                ),
              ),
          ]),
        ),
        const SectionTitle('Transactions'),
        for (final t in txns)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: (t.amount > 0 ? AppColors.green : AppColors.saffron).withValues(alpha: 0.12),
              child: Icon(t.amount > 0 ? Icons.add : Icons.restaurant, color: t.amount > 0 ? AppColors.green : AppColors.saffron),
            ),
            title: Text(t.title),
            subtitle: Text('${relDay(t.at)} · ${fmtShort(t.at)}'),
            trailing: Text(
              '${t.amount > 0 ? '+' : ''}${inr(t.amount)}',
              style: TextStyle(fontWeight: FontWeight.w800, color: t.amount > 0 ? AppColors.green : null),
            ),
          ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- Store
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String cat = 'All';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final items = MockData.storeItems.where((i) => cat == 'All' || i.category == cat).toList();
    final cartTotal = s.cart.fold<double>(0, (a, i) => a + i.price);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'store'))),
      body: PageList(padding: const EdgeInsets.fromLTRB(16, 4, 16, 110), children: [
        Wrap(spacing: 8, children: [
          for (final c in ['All', 'Uniform', 'Books', 'STEAM', 'Other'])
            ChoiceChip(label: Text(c), selected: cat == c, onSelected: (_) => setState(() => cat = c)),
        ]),
        gap(12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: [
            for (final i in items)
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.indigo.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: Icon(i.icon, size: 44, color: AppColors.indigo),
                    ),
                  ),
                  gap(8),
                  Text(i.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Row(children: [
                    Text(inr(i.price), style: const TextStyle(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    IconButton.filledTonal(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        s.addToCart(i);
                        toast(context, 'Added to bag: ${i.name}', icon: Icons.shopping_bag);
                      },
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ]),
                ]),
              ),
          ],
        ),
      ]),
      bottomSheet: s.cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              color: Theme.of(context).cardTheme.color,
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Expanded(
                    child: Text('${s.cart.length} item${s.cart.length > 1 ? 's' : ''} · ${inr(cartTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  TextButton(onPressed: s.clearCart, child: const Text('Clear')),
                  FilledButton(
                    onPressed: () {
                      s.clearCart();
                      toast(context, 'Order placed · collect from the school store or deliver with the school bus');
                    },
                    child: const Text('Order'),
                  ),
                ]),
              ),
            ),
    );
  }
}
