import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class ShiftListPage extends StatelessWidget {
  const ShiftListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Vardiyalar',
      child: Center(
        child: Text('Vardiya listesi (mock)'),
      ),
    );
  }
}
