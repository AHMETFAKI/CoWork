import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class TaskCreatePage extends StatelessWidget {
  const TaskCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Gorev Olustur',
      child: Center(
        child: Text('Gorev olusturma (mock)'),
      ),
    );
  }
}
