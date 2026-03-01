import 'package:event_management_web/screens/auth/sign_up_screen.dart';
import 'package:event_management_web/screens/user/event_detail_page.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/user/user_dashboard.dart';
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/user', builder: (c, s) => const UserDashboard()),
      GoRoute(path: '/organizer',
          builder: (c, s) => const OrganizerDashboard()),
      GoRoute(path: '/admin', builder: (c, s) => const AdminDashboard()),
      GoRoute(
  path: '/event/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return EventDetailPage(eventId: id);
  },
),
    ],
  );
}