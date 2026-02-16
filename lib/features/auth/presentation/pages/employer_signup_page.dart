import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cowork/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cowork/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cowork/shared/widgets/app_scaffold.dart';

class EmployerSignupPage extends ConsumerStatefulWidget {
  const EmployerSignupPage({super.key});

  @override
  ConsumerState<EmployerSignupPage> createState() => _EmployerSignupPageState();
}

class _EmployerSignupPageState extends ConsumerState<EmployerSignupPage> {
  final _picker = ImagePicker();
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

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _photoBytes = bytes);
  }

  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickPhoto(source);
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
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil fotografi zorunludur.')),
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && _photoBytes != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('$uid.jpg');
        await ref.putData(
          _photoBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final photoUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'photo_url': photoUrl,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
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
