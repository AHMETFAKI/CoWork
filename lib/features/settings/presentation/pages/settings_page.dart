import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Ayarlar',
      child: Center(
        child: Text('Ayarlar ekranı (mock)'),
      ),
    );
  }
}
