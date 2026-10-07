import 'package:flutter/widgets.dart';

import 'data/app_state.dart';

const languages = {'en': 'English', 'te': 'తెలుగు', 'hi': 'हिंदी'};

const _strings = <String, Map<String, String>>{
  'hello': {'en': 'Hello', 'te': 'నమస్కారం', 'hi': 'नमस्ते'},
  'communication': {'en': 'Communication', 'te': 'సమాచారం', 'hi': 'संवाद'},
  'academics': {'en': 'Academics', 'te': 'విద్యా విషయాలు', 'hi': 'शैक्षणिक'},
  'services': {'en': 'Services & Safety', 'te': 'సేవలు & భద్రత', 'hi': 'सेवाएँ और सुरक्षा'},
  'growth': {'en': 'Growth & AI', 'te': 'అభివృద్ధి & AI', 'hi': 'विकास और AI'},
  'announcements': {'en': 'Announcements', 'te': 'ప్రకటనలు', 'hi': 'घोषणाएँ'},
  'noticeBoard': {'en': 'Notice Board', 'te': 'నోటీసు బోర్డు', 'hi': 'सूचना पट्ट'},
  'applyLeave': {'en': 'Apply Leave', 'te': 'సెలవు దరఖాస్తు', 'hi': 'छुट्टी आवेदन'},
  'writeToSchool': {'en': 'Write to School', 'te': 'పాఠశాలకు వ్రాయండి', 'hi': 'स्कूल को लिखें'},
  'ptm': {'en': 'PTM Booking', 'te': 'PTM బుకింగ్', 'hi': 'PTM बुकिंग'},
  'homework': {'en': 'Homework', 'te': 'హోంవర్క్', 'hi': 'गृहकार्य'},
  'classwork': {'en': 'Class Work', 'te': 'క్లాస్ వర్క్', 'hi': 'कक्षा कार्य'},
  'attendance': {'en': 'Attendance', 'te': 'హాజరు', 'hi': 'उपस्थिति'},
  'marks': {'en': 'Marks & Reports', 'te': 'మార్కులు', 'hi': 'अंक व रिपोर्ट'},
  'econtent': {'en': 'E-Content', 'te': 'ఇ-కంటెంట్', 'hi': 'ई-सामग्री'},
  'calendar': {'en': 'Calendar', 'te': 'క్యాలెండర్', 'hi': 'कैलेंडर'},
  'timetable': {'en': 'Timetable', 'te': 'టైమ్ టేబుల్', 'hi': 'समय सारणी'},
  'onlineTest': {'en': 'Online Tests', 'te': 'ఆన్‌లైన్ పరీక్షలు', 'hi': 'ऑनलाइन टेस्ट'},
  'steamLab': {'en': 'STEAM Lab', 'te': 'STEAM ల్యాబ్', 'hi': 'STEAM लैब'},
  'fees': {'en': 'Fees', 'te': 'ఫీజులు', 'hi': 'शुल्क'},
  'bus': {'en': 'Bus Tracking', 'te': 'బస్ ట్రాకింగ్', 'hi': 'बस ट्रैकिंग'},
  'gallery': {'en': 'Gallery', 'te': 'గ్యాలరీ', 'hi': 'गैलरी'},
  'gatePass': {'en': 'Pickup Pass', 'te': 'పికప్ పాస్', 'hi': 'पिकअप पास'},
  'health': {'en': 'Health', 'te': 'ఆరోగ్యం', 'hi': 'स्वास्थ्य'},
  'wallet': {'en': 'Canteen Wallet', 'te': 'క్యాంటీన్ వాలెట్', 'hi': 'कैंटीन वॉलेट'},
  'store': {'en': 'School Store', 'te': 'స్కూల్ స్టోర్', 'hi': 'स्कूल स्टोर'},
  'refer': {'en': 'Refer & Earn', 'te': 'రిఫర్ చేయండి', 'hi': 'रेफ़र करें'},
  'aiSummary': {'en': 'AI Weekly Summary', 'te': 'AI వారపు సారాంశం', 'hi': 'AI साप्ताहिक सारांश'},
  'home': {'en': 'Home', 'te': 'హోమ్', 'hi': 'होम'},
  'inbox': {'en': 'Inbox', 'te': 'ఇన్‌బాక్స్', 'hi': 'इनबॉक्स'},
  'profile': {'en': 'Profile', 'te': 'ప్రొఫైల్', 'hi': 'प्रोफ़ाइल'},
  'settings': {'en': 'Settings', 'te': 'సెట్టింగ్‌లు', 'hi': 'सेटिंग्स'},
  'today': {'en': 'Today', 'te': 'ఈరోజు', 'hi': 'आज'},
  'present': {'en': 'Present', 'te': 'హాజరు', 'hi': 'उपस्थित'},
  'absent': {'en': 'Absent', 'te': 'గైర్హాజరు', 'hi': 'अनुपस्थित'},
  'onLeave': {'en': 'On leave', 'te': 'సెలవులో', 'hi': 'छुट्टी पर'},
  'holiday': {'en': 'Holiday', 'te': 'సెలవు', 'hi': 'अवकाश'},
  'notMarked': {'en': 'Not marked yet', 'te': 'ఇంకా నమోదు కాలేదు', 'hi': 'अभी दर्ज नहीं'},
  'feeDue': {'en': 'Fee due', 'te': 'ఫీజు బకాయి', 'hi': 'शुल्क बकाया'},
  'payNow': {'en': 'Pay now', 'te': 'ఇప్పుడే చెల్లించండి', 'hi': 'अभी भुगतान करें'},
  'pendingHw': {'en': 'Homework pending', 'te': 'పెండింగ్ హోంవర్క్', 'hi': 'बाकी गृहकार्य'},
  'nextClass': {'en': 'Next class', 'te': 'తదుపరి తరగతి', 'hi': 'अगली कक्षा'},
  'classesOver': {'en': 'Classes over', 'te': 'తరగతులు ముగిశాయి', 'hi': 'कक्षाएँ समाप्त'},
  'busEta': {'en': 'School bus', 'te': 'స్కూల్ బస్', 'hi': 'स्कूल बस'},
  'logout': {'en': 'Logout', 'te': 'లాగ్ అవుట్', 'hi': 'लॉग आउट'},
  'language': {'en': 'Language', 'te': 'భాష', 'hi': 'भाषा'},
  'atAGlance': {'en': 'Today at a glance', 'te': 'ఈరోజు ఒక చూపులో', 'hi': 'आज एक नज़र में'},
  'translate': {'en': 'Translate', 'te': 'అనువదించు', 'hi': 'अनुवाद करें'},
  'aiCard': {
    'en': 'Your weekly progress summary is ready',
    'te': 'మీ వారపు ప్రగతి సారాంశం సిద్ధంగా ఉంది',
    'hi': 'आपका साप्ताहिक प्रगति सारांश तैयार है',
  },
};

String tr(BuildContext context, String key) {
  final lang = AppScope.of(context).lang;
  return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
}
