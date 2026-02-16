import 'package:cowork/features/auth/domain/entities/app_user.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_config_admin.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_config_employee.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_config_manager.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_models.dart';

const Map<AppRole, List<NavItem>> roleNavItems = {
  AppRole.employee: employeeNavItems,
  AppRole.manager: managerNavItems,
  AppRole.admin: adminNavItems,
};
