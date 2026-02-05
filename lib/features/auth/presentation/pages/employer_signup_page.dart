import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';

class EmployerSignupPage extends ConsumerStatefulWidget {
  const EmployerSignupPage({super.key});

  @override
  ConsumerState<EmployerSignupPage> createState() => _EmployerSignupPageState();
}

class _EmployerSignupPageState extends ConsumerState<EmployerSignupPage> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _departmentName = TextEditingController();
  final _phone = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _departmentName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _fullName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final deptName = _departmentName.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || deptName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen tum zorunlu alanlari doldurun.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(authRepositoryProvider) as AuthRepositoryImpl;
      await repo.createEmployerAccount(
        fullName: name,
        email: email,
        password: password,
        departmentName: deptName,
        phone: phone.isEmpty ? null : phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayit basarili. Yonlendiriliyorsunuz...')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayit hatasi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isveren Kayit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _fullName,
            decoration: const InputDecoration(labelText: 'Ad Soyad *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email *'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Sifre *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _departmentName,
            decoration: const InputDecoration(labelText: 'Ilk Departman *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Telefon'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydi Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}
