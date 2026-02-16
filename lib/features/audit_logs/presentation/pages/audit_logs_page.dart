import 'package:flutter/material.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Audit Logs',
      child: Center(
        child: Text('Audit log ekrani (mock)'),
      ),
    );
  }
}
