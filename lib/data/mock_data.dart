import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

/// Demo data for the sample school. Dates are relative to today so the demo
/// always looks current.
DateTime get today => DateUtils.dateOnly(DateTime.now());
DateTime daysAgo(int n) => today.subtract(Duration(days: n));
DateTime daysAhead(int n) => today.add(Duration(days: n));

class MockData {
  static const schoolName = 'Sunrise International School';
  static const schoolCity = 'Vijayawada';
  static const schoolCode = 'SIS-VJA';

  static DateTime get academicStart {
    final t = today;
    return DateTime(t.month >= 6 ? t.year : t.year - 1, 6, 1);
  }

  static List<Student> children() => [
        Student(
          id: 'c1',
          name: 'Aarav Reddy',
          grade: '5',
          section: 'A',
          rollNo: '14',
          admNo: 'SIS/2021/0457',
          dob: '12-03-2016',
          bloodGroup: 'B+',
          father: 'Srinivas Reddy',
          mother: 'Kavya Reddy',
          phone: '+91 98xxxx2140',
          email: 'parent.reddy@example.com',
          address: 'Benz Circle, Vijayawada',
          house: 'Agni',
          aadhaar: '123456784190',
          apaar: 'APAAR-7741 2290 1183',
          pen: 'PEN 2105 7781 0042',
          busRoute: 'Route 7 · Benz Circle',
          busStop: 'Benz Circle Stop',
          classTeacher: 'Mrs. Lakshmi Prasanna',
          languages: ['Telugu (II)', 'Hindi (III)'],
          activities: ['Chess', 'Robotics Club', 'Swimming'],
          color: const Color(0xFF6C4CF1),
        ),
        Student(
          id: 'c2',
          name: 'Diya Reddy',
          grade: '2',
          section: 'B',
          rollNo: '9',
          admNo: 'SIS/2024/1102',
          dob: '04-09-2019',
          bloodGroup: 'O+',
          father: 'Srinivas Reddy',
          mother: 'Kavya Reddy',
          phone: '+91 98xxxx2140',
          email: 'parent.reddy@example.com',
          address: 'Benz Circle, Vijayawada',
          house: 'Vayu',
          aadhaar: '987654326631',
          apaar: 'APAAR-7741 2290 5521',
          pen: 'PEN 2105 7781 0918',
          busRoute: 'Route 7 · Benz Circle',
          busStop: 'Benz Circle Stop',
          classTeacher: 'Ms. Anusha Ummadi',
          languages: ['Telugu (II)', 'Hindi (III)'],
          activities: ['Dance – Kuchipudi', 'Art & Craft', 'Skating'],
          color: const Color(0xFFEC4899),
        ),
      ];

  static List<Homework> homework() {
    final list = <Homework>[];
    int n = 0;
    void add(String child, String subject, String title, String details, int ago, int dueIn,
        {List<String> files = const [], Map<String, String> tr = const {}, bool done = false}) {
      list.add(Homework(
        id: 'hw${n++}',
        childId: child,
        subject: subject,
        title: title,
        details: details,
        assigned: daysAgo(ago),
        due: daysAgo(ago).add(Duration(days: dueIn)),
        attachments: files,
        translations: tr,
        done: done,
        postedBy: subject == 'Mathematics' ? 'Mr. Tulasi Ram' : 'Class teacher',
      ));
    }

    add('c1', 'Mathematics', 'Fractions – Exercise 6.2',
        'Solve questions 1 to 10 of Exercise 6.2 (page 84). Show all steps in your notebook.', 0, 1,
        files: ['ex6_2_hints.pdf'],
        tr: {
          'te': 'అభ్యాసం 6.2 (పేజీ 84) లోని 1 నుండి 10 ప్రశ్నలను సాధించండి. అన్ని దశలను నోట్‌బుక్‌లో చూపించండి.',
          'hi': 'अभ्यास 6.2 (पृष्ठ 84) के प्रश्न 1 से 10 हल करें। सभी चरण अपनी कॉपी में दिखाएँ।',
        });
    add('c1', 'English', 'Informal letter',
        'Write an informal letter (8–10 sentences) to your friend about your favourite festival. Remember: address, date, greeting, body, closing.',
        0, 2,
        tr: {
          'te': 'మీకు ఇష్టమైన పండుగ గురించి మీ స్నేహితుడికి ఒక అనధికారిక లేఖ (8–10 వాక్యాలు) వ్రాయండి.',
          'hi': 'अपने पसंदीदा त्योहार के बारे में अपने मित्र को एक अनौपचारिक पत्र (8–10 वाक्य) लिखें।',
        });
    add('c1', 'Science', 'Plant parts worksheet',
        'Complete worksheet 4 – label the parts of a plant and write one function of each.', 1, 2,
        files: ['plant_parts_ws4.pdf']);
    add('c1', 'Telugu', 'పద్యం కంఠస్థం',
        'Learn the poem on page 32 by heart for recitation on Friday.', 1, 3);
    add('c1', 'Social Studies', 'Map work – Rivers of India',
        'Mark the major rivers of India on the outline map provided in class.', 2, 1,
        files: ['india_outline_map.jpg']);
    add('c1', 'Computers', 'Scratch project',
        'Create a Scratch animation with a sprite that moves using arrow keys. Save it in your lab account.', 3, 5,
        done: true);
    add('c1', 'Hindi', 'वर्णमाला अभ्यास',
        'Write 5 words for each of क, ख, ग, घ in your copy.', 4, 2, done: true);
    add('c1', 'Mathematics', 'Bar graphs',
        'Complete Exercise 5.3 – draw bar graphs for questions 2 and 4 on graph paper.', 5, 2, done: true);

    add('c2', 'English', 'Rhyming words',
        'Write 5 pairs of rhyming words and draw a picture for any two.', 0, 1);
    add('c2', 'Mathematics', 'Addition worksheet',
        'Complete worksheet 4 and 5 – addition with carry over (page 29, 30).', 1, 2,
        files: ['addition_ws4_5.pdf']);
    add('c2', 'EVS', 'My family tree',
        'Paste photos and draw your family tree on an A4 sheet.', 3, 4, done: true);
    return list;
  }

  static List<ClassWork> classWork() {
    final out = <ClassWork>[];
    final c1 = {
      0: [
        ['English', 'Completed reading of "The Clever Crow" (LB pg 112–115). Discussed new words and their meanings.'],
        ['Mathematics', 'Introduced equivalent fractions with paper-folding activity. Exercise 6.1 Q1–5 done in class.'],
        ['Computers', 'Scratch 3: events and motion blocks. Students made a sprite move across the stage.'],
        ['PE – Swimming', 'Freestyle kicking drills (10 m). Good progress in body alignment.'],
      ],
      1: [
        ['Science', 'Parts of a plant – root, stem, leaf, flower. Observed a hibiscus plant in the garden.'],
        ['Telugu', 'పాఠం 5 చదవడం పూర్తి చేశారు. కొత్త పదాల అర్థాలు నేర్చుకున్నారు.'],
        ['Chess', 'Special moves: castling, en passant and pawn promotion.'],
      ],
      2: [
        ['Social Studies', 'Rivers of India – Himalayan vs peninsular rivers.'],
        ['Hindi', 'वर्णमाला – व्यंजन क से ङ तक का अभ्यास।'],
        ['Mathematics', 'Revision of bar graphs and pictographs.'],
      ],
    };
    c1.forEach((ago, items) {
      for (final i in items) {
        out.add(ClassWork('c1', i[0], i[1], daysAgo(ago)));
      }
    });
    out.add(ClassWork('c2', 'English', 'Rhyming words and phonics sounds "at", "an", "ig".', daysAgo(0)));
    out.add(ClassWork('c2', 'Mathematics', 'Addition with carry-over using bundles of sticks.', daysAgo(0)));
    out.add(ClassWork('c2', 'Art & Craft', 'Paper-plate Dasara mask activity.', daysAgo(1)));
    return out;
  }

  static Map<String, Map<DateTime, AttStatus>> attendance() {
    final holidays = <DateTime>{};
    final y = academicStart.year;
    for (final d in [
      DateTime(y, 8, 15),
      DateTime(y, 8, 27),
      DateTime(y, 10, 2),
      DateTime(y, 11, 1),
      DateTime(y, 12, 25),
    ]) {
      holidays.add(d);
    }
    // Second Saturdays are holidays.
    for (int m = 6; m <= 17; m++) {
      final first = DateTime(y, m, 1);
      final firstSat = first.add(Duration(days: (DateTime.saturday - first.weekday + 7) % 7));
      holidays.add(firstSat.add(const Duration(days: 7)));
    }

    Map<DateTime, AttStatus> gen(int seed, bool markToday) {
      final r = Random(seed);
      final map = <DateTime, AttStatus>{};
      var d = academicStart;
      while (!d.isAfter(today)) {
        final key = DateUtils.dateOnly(d);
        if (d.weekday == DateTime.sunday || holidays.contains(key)) {
          map[key] = AttStatus.holiday;
        } else if (key == today && !markToday) {
          // not marked yet – teacher marks it from the teacher app
        } else {
          final roll = r.nextInt(100);
          map[key] = roll < 4
              ? AttStatus.absent
              : roll < 6
                  ? AttStatus.leave
                  : AttStatus.present;
        }
        d = d.add(const Duration(days: 1));
      }
      return map;
    }

    return {'c1': gen(7, false), 'c2': gen(11, true)};
  }

  static Map<String, Map<int, List<Period>>> timetable() {
    List<Period> day(List<List<String>> p) {
      final slots = [
        ['8:55', '9:35'],
        ['9:35', '10:15'],
        ['10:15', '10:55'],
        ['11:05', '11:45'],
        ['11:45', '12:25'],
        ['1:05', '1:45'],
        ['1:45', '2:25'],
        ['2:25', '3:05'],
      ];
      final out = <Period>[];
      for (int i = 0; i < p.length; i++) {
        if (i == 3) out.add(const Period('10:55', '11:05', 'Short Break', ''));
        if (i == 5) out.add(const Period('12:25', '1:05', 'Lunch Break', ''));
        out.add(Period(slots[i][0], slots[i][1], p[i][0], p[i][1]));
      }
      return out;
    }

    const m = ['Mathematics', 'Mr. Tulasi Ram'];
    const e = ['English', 'Mrs. Lakshmi Prasanna'];
    const s = ['Science', 'Mr. Anil Bethapudi'];
    const ss = ['Social Studies', 'Mrs. Padmaja K'];
    const te = ['Telugu', 'Mrs. Chandrika Mundla'];
    const hi = ['Hindi', 'Mrs. Usha K'];
    const cs = ['Computers', 'Mr. Venkat Thatiparti'];
    const pe = ['PE / Sports', 'Mr. Ashok Kumar'];
    const ar = ['Art & Craft', 'Ms. Bhargavi C'];
    const cl = ['Clubs', 'Activity mentors'];
    const ch = ['Chess', 'Mr. Gopal Chunduri'];

    final c1 = {
      1: day([m, e, s, te, ss, hi, cs, cl]),
      2: day([e, m, ss, s, hi, te, pe, ar]),
      3: day([m, e, cs, s, hi, e, cl, cl]),
      4: day([s, m, e, ss, te, ch, pe, cl]),
      5: day([e, m, te, hi, s, ss, ar, cl]),
      6: day([m, s, e, cs, pe, ss, cl, cl]),
    };
    const e2 = ['English', 'Ms. Anusha Ummadi'];
    const m2 = ['Mathematics', 'Mrs. Rani K'];
    const ev = ['EVS', 'Mrs. Sowmya P'];
    final c2 = {
      1: day([e2, m2, ev, te, hi, ar, pe, cl]),
      2: day([m2, e2, te, ev, hi, cs, ar, cl]),
      3: day([e2, m2, ev, hi, te, pe, cl, cl]),
      4: day([m2, e2, ev, te, ar, hi, cl, cl]),
      5: day([e2, m2, cs, ev, hi, te, pe, cl]),
      6: day([m2, e2, ev, ar, pe, cl, cl, cl]),
    };
    return {'c1': c1, 'c2': c2};
  }

  static List<SchoolEvent> events() => [
        SchoolEvent(daysAgo(12), 'Investiture Ceremony', 'Event'),
        SchoolEvent(daysAgo(5), 'Grandparents\' Day', 'Event'),
        SchoolEvent(daysAhead(3), 'Parent–Teacher Meeting (Term 1)', 'PTM',
            note: 'Book a slot from PTM Booking'),
        SchoolEvent(daysAhead(5), 'Dasara Holidays', 'Holiday', days: 7),
        SchoolEvent(daysAhead(13), 'School reopens', 'Event'),
        SchoolEvent(daysAhead(16), 'Formative Assessment 2 begins', 'Exam', days: 5),
        SchoolEvent(daysAhead(24), 'Science & Robotics Fair', 'Event'),
        SchoolEvent(daysAhead(30), 'Admissions open for next academic year', 'Event'),
        SchoolEvent(daysAhead(38), 'Children\'s Day celebrations', 'Event'),
        SchoolEvent(daysAhead(52), 'Annual Sports Meet', 'Event', days: 2),
        SchoolEvent(daysAhead(70), 'Summative Assessment 1', 'Exam', days: 8),
        SchoolEvent(daysAhead(85), 'Christmas Holiday', 'Holiday'),
      ];

  static List<Announcement> announcements() => [
        Announcement('Dasara holidays', 'School will remain closed for Dasara holidays for 7 days. Classes resume after the break. Holiday homework is posted in E-Content.', 'Principal', 'event', daysAgo(0)),
        Announcement('Fee reminder – Term 2', 'This is a gentle reminder that Term 2 tuition and transport fees are overdue. Please pay through the Fees section using UPI to avoid late fee.', 'Accounts', 'fee', daysAgo(1)),
        Announcement('Complaint #7781 resolved', 'Your request about field-trip photos has been resolved. Photos are now available in the Gallery.', 'Helpdesk', 'complaint', daysAgo(2), read: true),
        Announcement('Bus route 7 – timing change', 'From Monday, Route 7 pickup at Benz Circle will be at 7:40 AM instead of 7:35 AM.', 'Transport', 'alert', daysAgo(4), read: true),
        Announcement('Grandparents\' Day photos', 'Thank you for joining us! Photos are uploaded to the Gallery.', 'Admin', 'general', daysAgo(5), read: true),
      ];

  static List<Announcement> notices() => [
        Announcement('Early dispersal during FA-2', 'During Formative Assessment 2 the school will disperse at 12:30 PM. Buses will run accordingly.', 'Principal', 'general', daysAgo(1)),
        Announcement('Uniform guidelines – Winter', 'Students may wear the navy school sweater from November 1st. Available in the School Store.', 'Admin', 'general', daysAgo(6)),
        Announcement('Robotics club selections', 'Selections for the inter-school robotics team on Saturday in the STEAM lab. Grades 5–8.', 'STEAM Lab', 'event', daysAgo(8)),
        Announcement('Health check-up camp', 'Free dental and eye check-up for all students next week. Reports will appear in the Health section.', 'Infirmary', 'general', daysAgo(10)),
      ];

  static List<Ticket> tickets() => [
        Ticket(
          id: 'T-7790',
          childId: 'c1',
          to: 'Class Teacher',
          subject: 'Lunch box comes back full',
          created: DateTime.now().subtract(const Duration(hours: 60)),
          thread: [
            TicketMessage('You', 'Aarav says he gets only 5 minutes to eat. Can you please check?', DateTime.now().subtract(const Duration(hours: 60))),
          ],
        ),
        Ticket(
          id: 'T-7781',
          childId: 'c1',
          to: 'Class Teacher',
          subject: 'Field trip photos missing in gallery',
          created: daysAgo(4),
          status: TicketStatus.replied,
          thread: [
            TicketMessage('You', 'I could not find photos of 5-A from the field trip.', daysAgo(4)),
            TicketMessage('Mrs. Lakshmi Prasanna', 'Thank you for reaching out. The photos are uploaded now – please check the Gallery.', daysAgo(2), fromSchool: true),
          ],
        ),
        Ticket(
          id: 'T-7702',
          childId: 'c2',
          to: 'Transport',
          subject: 'Bus stop change request',
          created: daysAgo(20),
          status: TicketStatus.closed,
          rating: 4,
          thread: [
            TicketMessage('You', 'Can the bus stop near our street to avoid crossing the main road?', daysAgo(20)),
            TicketMessage('Transport Desk', 'We reviewed the route. The stop is moved 200 m closer from next Monday.', daysAgo(18), fromSchool: true),
          ],
        ),
      ];

  static List<LeaveRequest> leaves() => [
        LeaveRequest(
          id: 'L-301',
          childId: 'c2',
          from: daysAgo(26),
          to: daysAgo(26),
          reason: 'Fever, doctor advised rest.',
          applied: daysAgo(27),
          status: LeaveStatus.approved,
          remark: 'Get well soon!',
        ),
        LeaveRequest(
          id: 'L-322',
          childId: 'c1',
          from: daysAhead(2),
          to: daysAhead(3),
          reason: 'Family function in Guntur.',
          applied: DateTime.now().subtract(const Duration(hours: 30)),
        ),
      ];

  static List<FeeItem> fees() => [
        FeeItem(id: 'F1', childId: 'c1', title: 'Tuition Fee – Term 1', amount: 42500, due: daysAgo(120), paid: 42500),
        FeeItem(id: 'F2', childId: 'c1', title: 'Tuition Fee – Term 2', amount: 42500, due: daysAgo(30)),
        FeeItem(id: 'F3', childId: 'c1', title: 'Transport – Term 2 (Route 7)', amount: 9800, due: daysAgo(30)),
        FeeItem(id: 'F4', childId: 'c1', title: 'Activity & Lab Fee', amount: 6000, due: daysAhead(20)),
        FeeItem(id: 'F5', childId: 'c1', title: 'Tuition Fee – Term 3', amount: 42500, due: daysAhead(55)),
        FeeItem(id: 'F6', childId: 'c2', title: 'Tuition Fee – Term 1', amount: 36000, due: daysAgo(120), paid: 36000),
        FeeItem(id: 'F7', childId: 'c2', title: 'Tuition Fee – Term 2', amount: 36000, due: daysAhead(10)),
        FeeItem(id: 'F8', childId: 'c2', title: 'Transport – Term 2 (Route 7)', amount: 9800, due: daysAhead(10)),
      ];

  static List<Receipt> receipts() => [
        Receipt('RCPT-24-1182', 'c1', 'Tuition Fee – Term 1', 42500, daysAgo(124), 'UPI · GPay'),
        Receipt('RCPT-24-1183', 'c2', 'Tuition Fee – Term 1', 36000, daysAgo(124), 'UPI · GPay'),
      ];

  static List<EContent> econtent() => [
        EContent('c1', 'Fractions – concept notes & practice', 'Mathematics', daysAgo(1), ['fractions_notes.pdf', 'ex6_practice.pdf']),
        EContent('c1', 'FA-2 Syllabus & date sheet', 'General', daysAgo(2), ['fa2_syllabus_grade5.pdf']),
        EContent('c1', 'The Clever Crow – workbook answer key', 'English', daysAgo(3), ['clever_crow_key.pdf']),
        EContent('c1', 'Rivers of India – video lesson', 'Social Studies', daysAgo(5), ['rivers_of_india.mp4', 'map_activity.pdf']),
        EContent('c1', 'Plant parts – worksheet 4', 'Science', daysAgo(6), ['plant_parts_ws4.pdf']),
        EContent('c1', 'Scratch 3 starter guide', 'Computers', daysAgo(9), ['scratch_guide.docx']),
        EContent('c1', 'పాఠం 5 – పద్యాలు', 'Telugu', daysAgo(11), ['telugu_lesson5.pdf']),
        EContent('c2', 'Addition with carry-over worksheets', 'Mathematics', daysAgo(1), ['addition_ws4_5.pdf']),
        EContent('c2', 'Phonics flash cards', 'English', daysAgo(4), ['phonics_cards.pdf']),
      ];

  static List<ExamResult> results() => [
        ExamResult('c1', 'Formative Assessment 1', daysAgo(70), 50,
            {'English': 44, 'Mathematics': 47, 'Science': 41, 'Social Studies': 39, 'Telugu': 42, 'Hindi': 36},
            classAvg: {'English': 38, 'Mathematics': 36, 'Science': 37, 'Social Studies': 35, 'Telugu': 39, 'Hindi': 34}),
        ExamResult('c1', 'Unit Check 2', daysAgo(35), 25,
            {'English': 22, 'Mathematics': 24, 'Science': 19, 'Social Studies': 20, 'Telugu': 21, 'Hindi': 18},
            classAvg: {'English': 19, 'Mathematics': 18, 'Science': 18, 'Social Studies': 17, 'Telugu': 20, 'Hindi': 17}),
        ExamResult('c2', 'Formative Assessment 1', daysAgo(70), 50,
            {'English': 46, 'Mathematics': 43, 'EVS': 45, 'Telugu': 40, 'Hindi': 38},
            classAvg: {'English': 40, 'Mathematics': 39, 'EVS': 41, 'Telugu': 38, 'Hindi': 35}),
      ];

  static List<Quiz> quizzes() => [
        Quiz(id: 'q1', title: 'Fractions quick check', subject: 'Mathematics', minutes: 5, questions: const [
          QuizQuestion('Which fraction is equal to 1/2?', ['2/3', '3/6', '1/4', '4/6'], 1),
          QuizQuestion('What is 3/8 + 2/8?', ['5/16', '1/8', '5/8', '6/8'], 2),
          QuizQuestion('Which is the largest?', ['1/3', '1/5', '1/2', '1/4'], 2),
          QuizQuestion('Simplest form of 6/9 is', ['2/3', '3/4', '1/3', '6/9'], 0),
          QuizQuestion('How many quarters make a whole?', ['2', '3', '4', '5'], 2),
        ]),
        Quiz(id: 'q2', title: 'Plant parts', subject: 'Science', minutes: 4, questions: const [
          QuizQuestion('Which part of the plant makes food?', ['Root', 'Leaf', 'Stem', 'Flower'], 1),
          QuizQuestion('Roots absorb ___ from the soil.', ['Sunlight', 'Water', 'Air', 'Seeds'], 1),
          QuizQuestion('The stem carries water to the', ['Roots', 'Soil', 'Leaves', 'Seeds'], 2),
          QuizQuestion('Which part becomes the fruit?', ['Flower', 'Leaf', 'Root', 'Bark'], 0),
        ]),
        Quiz(id: 'q3', title: 'Grammar – nouns and verbs', subject: 'English', minutes: 5, score: 4, answers: [0, 1, 2, 1, 0], questions: const [
          QuizQuestion('Pick the noun: "The dog ran fast."', ['dog', 'ran', 'fast', 'the'], 0),
          QuizQuestion('Pick the verb: "Riya sings well."', ['Riya', 'sings', 'well', 'none'], 1),
          QuizQuestion('Plural of "child" is', ['childs', 'childes', 'children', 'childrens'], 2),
          QuizQuestion('Past tense of "go" is', ['goed', 'went', 'gone', 'going'], 1),
          QuizQuestion('"Happiness" is a', ['noun', 'verb', 'adjective', 'adverb'], 0),
        ]),
      ];

  static List<Album> albums() => [
        Album('Grandparents\' Day', daysAgo(5), 48, const Color(0xFFF59E0B), Icons.elderly_woman),
        Album('Field Trip – Science Museum', daysAgo(14), 36, const Color(0xFF0EA5E9), Icons.museum_outlined),
        Album('Independence Day', daysAgo(54), 62, const Color(0xFF16A34A), Icons.flag_outlined),
        Album('Ganesh Chaturthi', daysAgo(42), 28, const Color(0xFFEF4444), Icons.celebration_outlined),
        Album('Yellow Colour Day', daysAgo(60), 22, const Color(0xFFEAB308), Icons.wb_sunny_outlined),
        Album('Inter-house Chess', daysAgo(75), 18, const Color(0xFF6366F1), Icons.extension_outlined),
      ];

  static List<Enquiry> enquiries() => [
        Enquiry(id: 'E1', studentName: 'Ishaan K', parentName: 'Ravi Kumar', phone: '98xxxx1101', grade: 'Grade 1', source: 'Website', date: daysAgo(2)),
        Enquiry(id: 'E2', studentName: 'Meghana P', parentName: 'Sravani P', phone: '97xxxx5520', grade: 'LKG', source: 'Parent referral', date: daysAgo(3), stage: 'Campus visit'),
        Enquiry(id: 'E3', studentName: 'Rohit V', parentName: 'Venu V', phone: '91xxxx3381', grade: 'Grade 6', source: 'Walk-in', date: daysAgo(6), stage: 'Applied'),
        Enquiry(id: 'E4', studentName: 'Sahithi M', parentName: 'Madhavi M', phone: '99xxxx8812', grade: 'Grade 3', source: 'Parent referral', date: daysAgo(9), stage: 'Admitted'),
        Enquiry(id: 'E5', studentName: 'Kiran T', parentName: 'Teja T', phone: '90xxxx4472', grade: 'UKG', source: 'Instagram', date: daysAgo(1)),
      ];

  static List<WalletTxn> wallet() => [
        WalletTxn('c1', 'Top-up via UPI', 500, daysAgo(6)),
        WalletTxn('c1', 'Veg sandwich + juice', -60, daysAgo(2)),
        WalletTxn('c1', 'Idli plate', -40, daysAgo(1)),
        WalletTxn('c1', 'Fruit bowl', -35, daysAgo(0)),
        WalletTxn('c2', 'Top-up via UPI', 300, daysAgo(10)),
        WalletTxn('c2', 'Milk + biscuits', -30, daysAgo(1)),
      ];

  static List<PtmSlot> ptmSlots() => [
        PtmSlot('Mrs. Lakshmi Prasanna', 'Class Teacher · English', '9:00 AM'),
        PtmSlot('Mrs. Lakshmi Prasanna', 'Class Teacher · English', '9:15 AM', bookedBy: 'other'),
        PtmSlot('Mrs. Lakshmi Prasanna', 'Class Teacher · English', '9:30 AM'),
        PtmSlot('Mr. Tulasi Ram', 'Mathematics', '10:00 AM'),
        PtmSlot('Mr. Tulasi Ram', 'Mathematics', '10:15 AM', bookedBy: 'other'),
        PtmSlot('Mr. Anil Bethapudi', 'Science', '10:30 AM'),
        PtmSlot('Mr. Anil Bethapudi', 'Science', '10:45 AM'),
        PtmSlot('Ms. Anusha Ummadi', 'Class Teacher · Grade 2B', '11:00 AM'),
      ];

  static const storeItems = [
        StoreItem('Summer uniform set', 1450, Icons.checkroom_outlined, 'Uniform'),
        StoreItem('Winter sweater (navy)', 890, Icons.dry_cleaning_outlined, 'Uniform'),
        StoreItem('Sports T-shirt (house colour)', 420, Icons.sports_soccer_outlined, 'Uniform'),
        StoreItem('Grade 5 notebook set (12)', 640, Icons.menu_book_outlined, 'Books'),
        StoreItem('Grade 5 textbook bundle', 3250, Icons.auto_stories_outlined, 'Books'),
        StoreItem('Replacement ID card', 150, Icons.badge_outlined, 'Other'),
        StoreItem('School diary', 120, Icons.book_outlined, 'Other'),
        StoreItem('Robotics starter kit', 2400, Icons.precision_manufacturing_outlined, 'STEAM'),
      ];

  static List<RosterEntry> roster() {
    const names = [
      'Aadhya Sharma', 'Abhinav Rao', 'Akshara Naidu', 'Arjun Varma', 'Bhavya Sri', 'Charan Teja',
      'Deepika Chowdary', 'Dhruv Patel', 'Eshwar Goud', 'Gayathri Devi', 'Harsha Vardhan', 'Ishita Jain',
      'Jahnavi Reddy', 'Aarav Reddy', 'Karthik Raju', 'Lasya Priya', 'Manish Kumar', 'Nandini S',
      'Pranav Sai', 'Rithika M', 'Sai Charan', 'Sanjana K', 'Tanvi Gupta', 'Uday Kiran',
      'Varun Tej', 'Vaishnavi P', 'Yashwanth B', 'Zoya Khan',
    ];
    return [for (int i = 0; i < names.length; i++) RosterEntry(i + 1, names[i])];
  }

  static const healthRecord = {
    'c1': {
      'height': '138 cm',
      'weight': '31 kg',
      'bmi': '16.2 · Healthy',
      'vision': '6/6 both eyes',
      'allergies': 'Peanuts (mild)',
      'conditions': 'None',
    },
    'c2': {
      'height': '118 cm',
      'weight': '21 kg',
      'bmi': '15.1 · Healthy',
      'vision': '6/6 both eyes',
      'allergies': 'None known',
      'conditions': 'None',
    },
  };

  static const vaccinations = [
    ['MMR (2nd dose)', 'Done'],
    ['DPT booster', 'Done'],
    ['Typhoid conjugate', 'Done'],
    ['HPV', 'Not applicable yet'],
    ['Annual influenza', 'Due this month'],
  ];

  static const steamProjects = [
    ['Line-follower robot', 'Robotics', 'In progress', 0.6],
    ['Solar-powered fan', 'Science', 'Submitted', 1.0],
    ['Scratch: Maze game', 'Coding', 'Graded A', 1.0],
    ['Paper bridge challenge', 'Engineering', 'Starts next week', 0.0],
  ];
}
