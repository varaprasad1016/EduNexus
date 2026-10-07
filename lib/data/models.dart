import 'package:flutter/material.dart';

enum Role { parent, teacher, principal }

enum AttStatus { present, absent, holiday, leave }

enum TicketStatus { open, replied, closed }

enum LeaveStatus { pending, approved, rejected }

class Student {
  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.rollNo,
    required this.admNo,
    required this.dob,
    required this.bloodGroup,
    required this.father,
    required this.mother,
    required this.phone,
    required this.email,
    required this.address,
    required this.house,
    required this.aadhaar,
    required this.apaar,
    required this.pen,
    required this.busRoute,
    required this.busStop,
    required this.classTeacher,
    required this.languages,
    required this.activities,
    required this.color,
  });

  final String id, name, grade, section, rollNo, admNo, dob, bloodGroup;
  final String father, mother, phone, email, address, house;
  final String aadhaar, apaar, pen, busRoute, busStop, classTeacher;
  final List<String> languages, activities;
  final Color color;

  String get firstName => name.split(' ').first;
  String get initials =>
      name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
  String get classLabel => 'Grade $grade · $section';
  String get maskedAadhaar => 'XXXX XXXX ${aadhaar.substring(aadhaar.length - 4)}';
}

class Homework {
  Homework({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    required this.details,
    required this.assigned,
    required this.due,
    this.attachments = const [],
    this.done = false,
    this.translations = const {},
    this.postedBy = '',
  });

  final String id, childId, subject, title, details, postedBy;
  final DateTime assigned, due;
  final List<String> attachments;
  final Map<String, String> translations;
  bool done;
}

class ClassWork {
  ClassWork(this.childId, this.subject, this.text, this.date);
  final String childId, subject, text;
  final DateTime date;
}

class Period {
  const Period(this.start, this.end, this.subject, this.teacher);
  final String start, end, subject, teacher;
  bool get isBreak => teacher.isEmpty;
}

class SchoolEvent {
  SchoolEvent(this.date, this.title, this.type, {this.days = 1, this.note = ''});
  final DateTime date;
  final String title, type, note; // type: Event | Holiday | Exam | PTM
  final int days;
}

class TicketMessage {
  TicketMessage(this.author, this.text, this.at, {this.fromSchool = false});
  final String author, text;
  final DateTime at;
  final bool fromSchool;
}

class Ticket {
  Ticket({
    required this.id,
    required this.childId,
    required this.to,
    required this.subject,
    required this.created,
    required this.thread,
    this.status = TicketStatus.open,
    this.rating,
    this.hasAttachment = false,
  });

  final String id, childId, to, subject;
  final DateTime created;
  final List<TicketMessage> thread;
  TicketStatus status;
  int? rating;
  bool hasAttachment;

  /// Tickets with no school reply for 48 hours are escalated to the principal.
  bool get escalated =>
      status == TicketStatus.open &&
      DateTime.now().difference(created) > const Duration(hours: 48);

  Duration get slaRemaining =>
      const Duration(hours: 48) - DateTime.now().difference(created);
}

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.childId,
    required this.from,
    required this.to,
    required this.reason,
    required this.applied,
    this.status = LeaveStatus.pending,
    this.remark,
  });

  final String id, childId, reason;
  final DateTime from, to, applied;
  LeaveStatus status;
  String? remark;

  int get days => to.difference(from).inDays + 1;
  bool get escalated =>
      status == LeaveStatus.pending &&
      DateTime.now().difference(applied) > const Duration(hours: 24);
}

class Announcement {
  Announcement(this.title, this.body, this.from, this.kind, this.date, {this.read = false});
  final String title, body, from, kind; // kind: fee | event | alert | general | complaint
  final DateTime date;
  bool read;
}

class FeeItem {
  FeeItem({
    required this.id,
    required this.childId,
    required this.title,
    required this.amount,
    required this.due,
    this.paid = 0,
  });

  final String id, childId, title;
  final double amount;
  final DateTime due;
  double paid;

  double get balance => amount - paid;
  bool get isPaid => balance <= 0;
  bool get overdue => !isPaid && due.isBefore(DateTime.now());
}

class Receipt {
  Receipt(this.no, this.childId, this.title, this.amount, this.date, this.mode);
  final String no, childId, title, mode;
  final double amount;
  final DateTime date;
}

class EContent {
  EContent(this.childId, this.title, this.subject, this.date, this.files);
  final String childId, title, subject;
  final DateTime date;
  final List<String> files;
}

class ExamResult {
  ExamResult(this.childId, this.exam, this.date, this.max, this.marks, {this.classAvg = const {}});
  final String childId, exam;
  final DateTime date;
  final int max;
  final Map<String, int> marks;
  final Map<String, int> classAvg;

  int get total => marks.values.fold(0, (a, b) => a + b);
  double get percent => total * 100 / (max * marks.length);
}

class QuizQuestion {
  const QuizQuestion(this.q, this.options, this.answer);
  final String q;
  final List<String> options;
  final int answer;
}

class Quiz {
  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.minutes,
    required this.questions,
    this.score,
    this.answers,
  });

  final String id, title, subject;
  final int minutes;
  final List<QuizQuestion> questions;
  int? score;
  List<int?>? answers;
}

class Album {
  Album(this.title, this.date, this.count, this.color, this.icon);
  final String title;
  final DateTime date;
  final int count;
  final Color color;
  final IconData icon;
}

class Enquiry {
  Enquiry({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.phone,
    required this.grade,
    required this.source,
    required this.date,
    this.stage = 'Enquiry',
  });

  final String id, studentName, parentName, phone, grade, source;
  final DateTime date;
  String stage; // Enquiry | Campus visit | Applied | Admitted
}

class WalletTxn {
  WalletTxn(this.childId, this.title, this.amount, this.at);
  final String childId, title;
  final double amount; // negative = spent
  final DateTime at;
}

class PtmSlot {
  PtmSlot(this.teacher, this.subject, this.time, {this.bookedBy});
  final String teacher, subject, time;
  String? bookedBy;
}

class StoreItem {
  const StoreItem(this.name, this.price, this.icon, this.category);
  final String name, category;
  final double price;
  final IconData icon;
}

class PickupPass {
  PickupPass(this.childId, this.name, this.relation, this.phone, this.otp, this.expires);
  final String childId, name, relation, phone, otp;
  final DateTime expires;
}

class RosterEntry {
  RosterEntry(this.roll, this.name, {this.present = true});
  final int roll;
  final String name;
  bool present;
}
