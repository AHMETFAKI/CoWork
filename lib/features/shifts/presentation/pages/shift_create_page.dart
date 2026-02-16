import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class ShiftCreatePage extends StatelessWidget {
  const ShiftCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Vardiya Olustur',
      child: Center(
        child: Text('Vardiya olusturma (mock)'),
      ),
    );
  }
}
