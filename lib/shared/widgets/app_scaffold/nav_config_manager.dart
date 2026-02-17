import 'package:flutter/material.dart';

import 'package:cowork/core/routing/routes.dart';
import 'package:cowork/shared/widgets/app_scaffold/nav_models.dart';

const List<NavItem> managerNavItems = [
  NavItem(
    label: 'Talepler',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    route: Routes.requests,
    sheetActions: [
      NavSheetAction(
        label: 'Talepler',
        icon: Icons.list_alt_outlined,
        route: Routes.requests,
      ),
      NavSheetAction(
        label: 'Onaylar',
        icon: Icons.fact_check_outlined,
        route: Routes.approvals,
      ),
    ],
  ),
  NavItem(
    label: 'Vardiyalar',
    icon: Icons.schedule_outlined,
    selectedIcon: Icons.schedule,
    route: Routes.shifts,
    sheetActions: [
      NavSheetAction(
        label: 'Liste',
        icon: Icons.list_alt_outlined,
        route: Routes.shifts,
      ),
      NavSheetAction(
        label: 'Giris/Cikis',
        icon: Icons.add_to_queue_outlined,
        route: Routes.shiftCreate,
      ),
    ],
  ),
  NavItem(
    label: 'Gorevler',
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
    route: Routes.tasks,
    sheetActions: [
      NavSheetAction(
        label: 'Liste',
        icon: Icons.list_alt_outlined,
        route: Routes.tasks,
      ),
      NavSheetAction(
        label: 'Olustur',
        icon: Icons.playlist_add_outlined,
        route: Routes.taskCreate,
      ),
    ],
  ),
  NavItem(
    label: 'Ekibim',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    route: Routes.team,
  ),
];
