import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'data/models.dart';
import 'screens/login_screen.dart';
import 'screens/parent/parent_shell.dart';
import 'screens/principal/principal_shell.dart';
import 'screens/teacher/teacher_shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(EduNexusApp(state: AppState()));
}

class EduNexusApp extends StatelessWidget {
  const EduNexusApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'EduNexus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: switch (state.role) {
            null => const LoginScreen(),
            Role.parent => const ParentShell(),
            Role.teacher => const TeacherShell(),
            Role.principal => const PrincipalShell(),
          },
        ),
      ),
    );
  }
}

/// Pops back to the root route before switching roles so no stale pages remain.
void logout(BuildContext context) {
  Navigator.of(context).popUntil((r) => r.isFirst);
  AppScope.read(context).logout();
}
