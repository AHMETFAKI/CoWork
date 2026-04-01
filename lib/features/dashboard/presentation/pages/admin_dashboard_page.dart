import 'package:flutter/material.dart';

import 'package:cowork/features/dashboard/presentation/widgets/dashboard_chat_home.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardChatHome(title: 'Sohbetler');
  }
}
