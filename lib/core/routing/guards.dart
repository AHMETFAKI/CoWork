import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'routes.dart';

class Guards {
  static String homeForRole(AppRole role) {
    return switch (role) {
      AppRole.admin => Routes.admin,
      AppRole.manager => Routes.manager,
      AppRole.employee => Routes.employee,
    };
  }

  static bool canAccess(AppRole role, String location) {
    // Basit guard (Sprint 1):
    if (location.startsWith(Routes.admin)) return role == AppRole.admin;
    if (location.startsWith(Routes.manager)) {
      return role == AppRole.admin || role == AppRole.manager;
    }
    if (location.startsWith(Routes.employee)) return true;
    if (location.startsWith(Routes.profile)) return true;
    if (location.startsWith(Routes.taskCreate)) {
      return role == AppRole.admin || role == AppRole.manager;
    }
    if (location.startsWith(Routes.shiftCreate)) {
      return role == AppRole.admin || role == AppRole.manager;
    }
    if (location.startsWith(Routes.approvals)) {
      return role == AppRole.admin || role == AppRole.manager;
    }
    if (location.startsWith(Routes.auditLogs)) {
      return role == AppRole.admin;
    }
    if (location.startsWith(Routes.settings)) {
      return role == AppRole.admin;
    }
    if (location.startsWith(Routes.requests)) return true;
    if (location.startsWith(Routes.tasks)) return true;
    if (location.startsWith(Routes.shifts)) return true;
    if (location.startsWith(Routes.users)) return true;
    if (location.startsWith(Routes.departments)) return role == AppRole.admin;
    return true;
  }
}
