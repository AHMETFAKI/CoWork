import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cowork/core/di/app_providers.dart';
import 'package:cowork/features/auth/presentation/pages/login_page.dart';
import 'package:cowork/features/auth/presentation/pages/employer_signup_page.dart';
import 'package:cowork/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:cowork/features/dashboard/presentation/pages/manager_dashboard_page.dart';
import 'package:cowork/features/dashboard/presentation/pages/employee_dashboard_page.dart';
import 'package:cowork/features/requests/presentation/pages/request_create_page.dart';
import 'package:cowork/features/requests/presentation/pages/request_list_page.dart';
import 'package:cowork/features/approvals/presentation/pages/approval_inbox_page.dart';
import 'package:cowork/features/users/presentation/pages/users_page.dart';
import 'package:cowork/features/departments/presentation/pages/departments_page.dart';
import 'package:cowork/features/tasks/presentation/pages/task_list_page.dart';
import 'package:cowork/features/tasks/presentation/pages/task_create_page.dart';
import 'package:cowork/features/shifts/presentation/pages/shift_list_page.dart';
import 'package:cowork/features/shifts/presentation/pages/shift_create_page.dart';
import 'package:cowork/features/audit_logs/presentation/pages/audit_logs_page.dart';
import 'package:cowork/features/settings/presentation/pages/settings_page.dart';
import 'package:cowork/features/profile/presentation/pages/profile_page.dart';
import 'package:cowork/features/team/presentation/pages/team_member_profile_page.dart';
import 'guards.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // authUidProvider: uid stream
  // sessionProvider: AppUser stream
  final authUid = ref.watch(authUidProvider);
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: GoRouterRefreshStream(
      // router redirect tetiklensin diye stream'i dinletiyoruz
      ref.watch(authUidStreamProvider),
    ),
    redirect: (context, state) {
      final loc = state.uri.toString();

      // Auth uid yükleniyorsa bekle
      if (authUid.isLoading) return null;

      final uid = authUid.asData?.value;

      // Oturum yoksa login veya employer signup serbest
      if (uid == null) {
        if (loc == Routes.login || loc == Routes.employerSignup) return null;
        return Routes.login;
      }

      // Oturum var, profil çekiliyor olabilir
      if (session.isLoading) return null;
      if (session.hasError) return Routes.login;

      final appUser = session.asData?.value;
      if (appUser == null) return Routes.login;

      // Login'deyse role home'a at
      if (loc == Routes.login) return Guards.homeForRole(appUser.role);

      // Yetkisiz erişim
      if (!Guards.canAccess(appUser.role, loc)) {
        return Guards.homeForRole(appUser.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.employerSignup,
        builder: (context, state) => const EmployerSignupPage(),
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: Routes.manager,
        builder: (context, state) => const ManagerDashboardPage(),
      ),
      GoRoute(
        path: Routes.employee,
        builder: (context, state) => const EmployeeDashboardPage(),
      ),
      GoRoute(
        path: Routes.requests,
        builder: (context, state) => const RequestListPage(),
      ),
      GoRoute(
        path: Routes.requestCreate,
        builder: (context, state) => const RequestCreatePage(),
      ),
      GoRoute(
        path: Routes.approvals,
        builder: (context, state) => const ApprovalInboxPage(),
      ),
      GoRoute(
        path: Routes.users,
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: Routes.departments,
        builder: (context, state) => const DepartmentsPage(),
      ),
      GoRoute(
        path: Routes.tasks,
        builder: (context, state) => const TaskListPage(),
      ),
      GoRoute(
        path: Routes.taskCreate,
        builder: (context, state) => const TaskCreatePage(),
      ),
      GoRoute(
        path: Routes.shifts,
        builder: (context, state) => const ShiftListPage(),
      ),
      GoRoute(
        path: Routes.shiftCreate,
        builder: (context, state) => const ShiftCreatePage(),
      ),
      GoRoute(
        path: Routes.auditLogs,
        builder: (context, state) => const AuditLogsPage(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '${Routes.teamMember}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return TeamMemberProfilePage(memberUid: uid);
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
