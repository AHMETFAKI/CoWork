import 'package:flutter/material.dart';

import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_models.dart';

const List<NavItem> employeeNavItems = [
  NavItem(
    label: 'Talepler',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    route: Routes.requests,
    sheetActions: [
      NavSheetAction(
        label: 'Liste',
        icon: Icons.list_alt_outlined,
        route: Routes.requests,
      ),
      NavSheetAction(
        label: 'Yeni Talep',
        icon: Icons.add_circle_outline,
        route: Routes.requestCreate,
      ),
    ],
  ),
  NavItem(
    label: 'Vardiyalar',
    icon: Icons.schedule_outlined,
    selectedIcon: Icons.schedule,
    route: Routes.shifts,
  ),
  NavItem(
    label: 'Gorevler',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
    route: Routes.tasks,
  ),
  NavItem(
    label: 'Ekibim',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    route: Routes.team,
  ),
];
