import 'package:flutter/material.dart';

import 'package:cowork/features/dashboard/presentation/widgets/dashboard_chat_home.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardChatHome(title: 'Sohbetler');
  }
}
