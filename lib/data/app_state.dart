import 'dart:math';

import 'package:flutter/material.dart';

import 'mock_data.dart';
import 'models.dart';

/// Single source of truth for the demo. Parent, teacher and principal views all
/// read and write the same state, so an action in one role (e.g. a teacher
/// approving leave) is immediately visible in another.
class AppState extends ChangeNotifier {
  Role? role;
  String userName = '';
  String lang = 'en';
  bool darkMode = false;
  bool liteMode = false;
  bool notifyApp = true, notifyWhatsApp = true, notifySms = false;
  bool upiAutopay = false;
  DateTime? consentAt;

  int childIndex = 0;
  final children = MockData.children();
  final homework = MockData.homework();
  final classWork = MockData.classWork();
  final attendance = MockData.attendance();
  final timetable = MockData.timetable();
  final events = MockData.events();
  final announcements = MockData.announcements();
  final notices = MockData.notices();
  final tickets = MockData.tickets();
  final leaves = MockData.leaves();
  final fees = MockData.fees();
  final receipts = MockData.receipts();
  final econtent = MockData.econtent();
  final results = MockData.results();
  final quizzes = MockData.quizzes();
  final albums = MockData.albums();
  final enquiries = MockData.enquiries();
  final wallet = MockData.wallet();
  final ptmSlots = MockData.ptmSlots();
  final roster = MockData.roster();
  final pickupPasses = <PickupPass>[];
  final cart = <StoreItem>[];
  double walletDailyLimit = 100;
  bool rosterSubmittedToday = false;

  final _rng = Random();

  Student get child => children[childIndex];

  // ---------- session ----------
  void login(Role r, String name) {
    role = r;
    userName = name;
    consentAt ??= DateTime.now();
    notifyListeners();
  }

  void logout() {
    role = null;
    notifyListeners();
  }

  void setLang(String l) {
    lang = l;
    notifyListeners();
  }

  void setChild(int i) {
    childIndex = i;
    notifyListeners();
  }

  void toggle(void Function() change) {
    change();
    notifyListeners();
  }

  // ---------- per-child views ----------
  List<Homework> homeworkFor(String childId) =>
      homework.where((h) => h.childId == childId).toList()..sort((a, b) => b.assigned.compareTo(a.assigned));
  List<ClassWork> classWorkFor(String childId) =>
      classWork.where((c) => c.childId == childId).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<FeeItem> feesFor(String childId) => fees.where((f) => f.childId == childId).toList();
  List<Receipt> receiptsFor(String childId) =>
      receipts.where((r) => r.childId == childId).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<EContent> econtentFor(String childId) => econtent.where((e) => e.childId == childId).toList();
  List<ExamResult> resultsFor(String childId) => results.where((r) => r.childId == childId).toList();
  List<Ticket> ticketsFor(String childId) =>
      tickets.where((t) => t.childId == childId).toList()..sort((a, b) => b.created.compareTo(a.created));
  List<LeaveRequest> leavesFor(String childId) =>
      leaves.where((l) => l.childId == childId).toList()..sort((a, b) => b.applied.compareTo(a.applied));
  List<WalletTxn> walletFor(String childId) =>
      wallet.where((w) => w.childId == childId).toList()..sort((a, b) => b.at.compareTo(a.at));
  double walletBalance(String childId) => walletFor(childId).fold(0.0, (a, w) => a + w.amount);

  double dueNow(String childId) => feesFor(childId)
      .where((f) => !f.isPaid && f.due.isBefore(today.add(const Duration(days: 31))))
      .fold(0.0, (a, f) => a + f.balance);

  int pendingHomework(String childId) => homeworkFor(childId).where((h) => !h.done).length;

  AttStatus? attendanceToday(String childId) => attendance[childId]?[today];

  int get unreadAnnouncements => announcements.where((a) => !a.read).length;

  Period? nextPeriod(String childId) {
    final day = timetable[childId]?[today.weekday];
    if (day == null) return null;
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    for (final p in day) {
      if (p.isBreak) continue;
      final parts = p.start.split(':');
      var h = int.parse(parts[0]);
      if (h < 7) h += 12;
      final m = h * 60 + int.parse(parts[1]);
      if (m > nowMin) return p;
    }
    return null;
  }

  // ---------- attendance stats ----------
  AttendanceStats stats(String childId) => AttendanceStats.from(attendance[childId] ?? {});

  // ---------- mutations ----------
  void toggleHomework(Homework h) {
    h.done = !h.done;
    notifyListeners();
  }

  void addHomework(Homework h) {
    homework.add(h);
    notifyListeners();
  }

  void addClassWork(ClassWork c) {
    classWork.add(c);
    notifyListeners();
  }

  String newTicket(String childId, String to, String subject, String message, bool attachment) {
    final id = 'T-${7800 + tickets.length}';
    tickets.add(Ticket(
      id: id,
      childId: childId,
      to: to,
      subject: subject,
      created: DateTime.now(),
      hasAttachment: attachment,
      thread: [TicketMessage('You', message, DateTime.now())],
    ));
    notifyListeners();
    return id;
  }

  void replyTicket(Ticket t, String author, String text, {bool fromSchool = false}) {
    t.thread.add(TicketMessage(author, text, DateTime.now(), fromSchool: fromSchool));
    if (fromSchool) t.status = TicketStatus.replied;
    notifyListeners();
  }

  void rateTicket(Ticket t, int stars) {
    t.rating = stars;
    t.status = TicketStatus.closed;
    notifyListeners();
  }

  void applyLeave(String childId, DateTime from, DateTime to, String reason) {
    leaves.add(LeaveRequest(
      id: 'L-${330 + leaves.length}',
      childId: childId,
      from: from,
      to: to,
      reason: reason,
      applied: DateTime.now(),
    ));
    notifyListeners();
  }

  void decideLeave(LeaveRequest l, bool approve, {String? remark}) {
    l.status = approve ? LeaveStatus.approved : LeaveStatus.rejected;
    l.remark = remark;
    if (approve) {
      var d = l.from;
      while (!d.isAfter(l.to)) {
        if (!d.isAfter(today)) attendance[l.childId]?[d] = AttStatus.leave;
        d = d.add(const Duration(days: 1));
      }
    }
    notifyListeners();
  }

  /// Pays the selected fee items. When [partial] is set, it is spread across
  /// items in order of due date.
  Receipt payFees(String childId, List<FeeItem> items, String mode, {double? partial}) {
    items.sort((a, b) => a.due.compareTo(b.due));
    var remaining = partial ?? items.fold<double>(0, (a, f) => a + f.balance);
    final paidTotal = remaining;
    for (final f in items) {
      if (remaining <= 0) break;
      final pay = min(remaining, f.balance);
      f.paid += pay;
      remaining -= pay;
    }
    final r = Receipt(
      'RCPT-${DateTime.now().year % 100}-${1200 + receipts.length}',
      childId,
      items.length == 1 ? items.first.title : '${items.length} fee items',
      paidTotal,
      DateTime.now(),
      mode,
    );
    receipts.add(r);
    notifyListeners();
    return r;
  }

  void submitRoster(String childIdInClass, String rollNo) {
    rosterSubmittedToday = true;
    final entry = roster.firstWhere((r) => r.roll.toString() == rollNo, orElse: () => roster.first);
    attendance[childIdInClass]?[today] = entry.present ? AttStatus.present : AttStatus.absent;
    if (!entry.present) {
      announcements.insert(
        0,
        Announcement('Absent alert', '${children.firstWhere((c) => c.id == childIdInClass).firstName} was marked absent today. If this is unexpected, please contact the class teacher.',
            'Attendance', 'alert', today),
      );
    }
    notifyListeners();
  }

  void addAnnouncement(String title, String body, String from) {
    announcements.insert(0, Announcement(title, body, from, 'general', today));
    notifyListeners();
  }

  void markAnnouncementsRead() {
    for (final a in announcements) {
      a.read = true;
    }
    notifyListeners();
  }

  void submitQuiz(Quiz q, List<int?> answers) {
    q.answers = answers;
    q.score = [for (int i = 0; i < q.questions.length; i++) answers[i] == q.questions[i].answer].where((b) => b).length;
    notifyListeners();
  }

  void addEnquiry(String student, String parent, String phone, String grade) {
    enquiries.insert(
      0,
      Enquiry(
        id: 'E${enquiries.length + 1}',
        studentName: student,
        parentName: parent,
        phone: phone,
        grade: grade,
        source: 'Parent referral · $userName',
        date: today,
      ),
    );
    notifyListeners();
  }

  void advanceEnquiry(Enquiry e) {
    const stages = ['Enquiry', 'Campus visit', 'Applied', 'Admitted'];
    final i = stages.indexOf(e.stage);
    if (i < stages.length - 1) e.stage = stages[i + 1];
    notifyListeners();
  }

  void topUpWallet(String childId, double amount) {
    wallet.add(WalletTxn(childId, 'Top-up via UPI', amount, DateTime.now()));
    notifyListeners();
  }

  void bookPtm(PtmSlot s) {
    s.bookedBy = 'me';
    notifyListeners();
  }

  void cancelPtm(PtmSlot s) {
    s.bookedBy = null;
    notifyListeners();
  }

  PickupPass createPickupPass(String childId, String name, String relation, String phone) {
    final otp = (100000 + _rng.nextInt(900000)).toString();
    final p = PickupPass(childId, name, relation, phone, otp, DateTime.now().add(const Duration(hours: 4)));
    pickupPasses.insert(0, p);
    notifyListeners();
    return p;
  }

  void addToCart(StoreItem i) {
    cart.add(i);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ---------- principal metrics ----------
  List<Ticket> get escalatedTickets => tickets.where((t) => t.escalated).toList();
  List<LeaveRequest> get pendingLeaves => leaves.where((l) => l.status == LeaveStatus.pending).toList();
}

class AttendanceStats {
  AttendanceStats({
    required this.present,
    required this.absent,
    required this.leave,
    required this.working,
    required this.longestStreak,
    required this.bestMonth,
    required this.worstWeekday,
    required this.monthly,
  });

  final int present, absent, leave, working, longestStreak;
  final String bestMonth, worstWeekday;
  final Map<DateTime, List<int>> monthly; // month -> [present, working]

  double get percent => working == 0 ? 0 : present * 100 / working;

  static const _weekdays = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
  static const _months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  factory AttendanceStats.from(Map<DateTime, AttStatus> map) {
    final keys = map.keys.toList()..sort();
    int p = 0, a = 0, l = 0, streak = 0, best = 0;
    final missByDay = <int, int>{};
    final monthly = <DateTime, List<int>>{};
    for (final d in keys) {
      final s = map[d]!;
      if (s == AttStatus.holiday) continue;
      final m = DateTime(d.year, d.month);
      monthly.putIfAbsent(m, () => [0, 0]);
      monthly[m]![1]++;
      if (s == AttStatus.present) {
        p++;
        monthly[m]![0]++;
        streak++;
        best = max(best, streak);
      } else {
        streak = 0;
        missByDay[d.weekday] = (missByDay[d.weekday] ?? 0) + 1;
        if (s == AttStatus.absent) a++;
        if (s == AttStatus.leave) l++;
      }
    }
    String bestMonth = '-';
    double bestPct = -1;
    monthly.forEach((m, v) {
      final pct = v[1] == 0 ? 0.0 : v[0] / v[1];
      if (pct >= bestPct) {
        bestPct = pct;
        bestMonth = '${_months[m.month]} ${m.year}';
      }
    });
    String worst = '-';
    if (missByDay.isNotEmpty) {
      final e = missByDay.entries.reduce((x, y) => x.value >= y.value ? x : y);
      worst = _weekdays[e.key];
    }
    return AttendanceStats(
      present: p,
      absent: a,
      leave: l,
      working: p + a + l,
      longestStreak: best,
      bestMonth: bestMonth,
      worstWeekday: worst,
      monthly: monthly,
    );
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
