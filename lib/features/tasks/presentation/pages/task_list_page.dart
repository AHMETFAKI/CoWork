import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Gorevler',
      child: Center(
        child: Text('Gorev listesi (mock)'),
      ),
    );
  }
}
