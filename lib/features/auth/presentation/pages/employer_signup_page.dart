import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/utils/image_picker_utils.dart';
import 'package:cowork/shared/widgets/async_elevated_button.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/widgets/photo_source_sheet.dart';

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
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _departmentName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _choosePhotoSource() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return;
    final bytes = await pickImageBytes(source: source);
    if (bytes == null || !mounted) return;
    setState(() => _photoBytes = bytes);
  }

  Future<void> _submit() async {
    final name = _fullName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final deptName = _departmentName.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || deptName.isEmpty) {
      showErrorSnackBar(context, 'Lutfen tum zorunlu alanlari doldurun.');
      return;
    }
    if (_photoBytes == null) {
      showErrorSnackBar(context, 'Profil fotografi zorunludur.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(authControllerProvider.notifier).createEmployerAccount(
        fullName: name,
        email: email,
        password: password,
        departmentName: deptName,
        phone: phone.isEmpty ? null : phone,
        photoBytes: _photoBytes,
      );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Kayit basarili. Yonlendiriliyorsunuz...');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Kayit hatasi: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Isveren Kayit',
      showNavigationBar: false,
      showDrawer: false,
      showProfileAction: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PhotoPickerRow(
            photoBytes: _photoBytes,
            onPickPhoto: _choosePhotoSource,
            onClearPhoto: () => setState(() => _photoBytes = null),
          ),
          const SizedBox(height: 12),
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
            child: AsyncElevatedButton(
              loading: _saving,
              onPressed: _submit,
              child: const Text('Kaydi Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPickerRow extends StatelessWidget {
  final Uint8List? photoBytes;
  final VoidCallback onPickPhoto;
  final VoidCallback onClearPhoto;

  const _PhotoPickerRow({
    required this.photoBytes,
    required this.onPickPhoto,
    required this.onClearPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        photoBytes != null ? MemoryImage(photoBytes!) : null;

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          backgroundImage: imageProvider,
          child:
              imageProvider == null ? const Icon(Icons.person_outline) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil Fotografi *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onPickPhoto,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Sec'),
                  ),
                  const SizedBox(width: 8),
                  if (imageProvider != null)
                    TextButton(
                      onPressed: onClearPhoto,
                      child: const Text('Kaldir'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
