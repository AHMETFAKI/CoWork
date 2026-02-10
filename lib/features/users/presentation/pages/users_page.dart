import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/user_form_section.dart';
import '../widgets/users_list_section.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/models/user_profile_model.dart';
import '../controllers/users_controller.dart';
import '../controllers/users_form_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../departments/presentation/controllers/departments_controller.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {

  Future<void> _saveUser() async {
    final fields = ref.read(usersFormFieldsProvider.notifier);
    final fieldsState = ref.read(usersFormFieldsProvider);
    final result = await ref.read(usersFormControllerProvider.notifier).saveUser(
          docId: fields.docId.text.trim(),
          fullName: fields.name.text.trim(),
          email: fields.email.text.trim(),
          password: fields.password.text,
          role: fieldsState.role,
          departmentId: fieldsState.selectedDeptId?.trim(),
          selectedDeptManagerId: fieldsState.selectedDeptManagerId,
          phone: fields.phone.text.trim(),
          isActive: fieldsState.isActive,
          setDeptManager: fieldsState.setDeptManager,
        );

    if (!mounted) return;

    if (result.alreadyExists) {
      final shouldLoad = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kullanıcı zaten var'),
          content: const Text('Bu email zaten kayıtlı. Profili yükleyip düzenlemek ister misin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hayır'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet, yükle'),
            ),
          ],
        ),
      );
      if (shouldLoad == true) {
        final snap = await ref
            .read(firestoreProvider)
            .collection('users')
            .where('email', isEqualTo: fields.email.text.trim())
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          _fillFromDoc(snap.docs.first);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil bulunamadı.')),
          );
        }
      }
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Save failed.')),
      );
      return;
    }

    if (result.createdUid != null) {
      fields.docId.text = result.createdUid!;
      fields.password.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User saved.')),
    );
  }

  void _clearForm() {
    ref.read(usersFormFieldsProvider.notifier).clearForm();
  }

  Future<void> _selectUser(UserProfile user) async {
    ref.read(usersFormFieldsProvider.notifier).fillFromUser(user);
  }

  void _fillFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return;
    final model = UserProfileModel.fromMap(doc.id, data);
    _selectUser(model.toEntity());
  }

  @override
  Widget build(BuildContext context) {
    final usersStream = ref.watch(usersStreamProvider);
    final formState = ref.watch(usersFormControllerProvider);
    final fieldsState = ref.watch(usersFormFieldsProvider);
    final fields = ref.read(usersFormFieldsProvider.notifier);
    final departmentsStream = ref.watch(departmentsStreamProvider);

    return AppScaffold(
      title: 'Kullanicilar',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          UserFormSection(
            docId: fields.docId,
            name: fields.name,
            email: fields.email,
            password: fields.password,
            managerIdView: fields.managerIdView,
            phone: fields.phone,
            role: fieldsState.role,
            selectedDeptId: fieldsState.selectedDeptId,
            setDeptManager: fieldsState.setDeptManager,
            isActive: fieldsState.isActive,
            saving: formState.isLoading,
            departmentsStream: departmentsStream.when(
              data: (items) => Stream.value(items),
              error: (err, _) => Stream.error(err),
              loading: () => const Stream.empty(),
            ),
            onNew: _clearForm,
            onSave: _saveUser,
            onRoleChanged: fields.applyRole,
            onDeptChanged: fields.setDept,
            onDeptManagerResolved: fields.setDeptManager,
            onSetDeptManagerChanged: fields.setSetDeptManager,
            onActiveChanged: fields.setActive,
          ),
          const SizedBox(height: 24),
          const Text('Users'),
          const SizedBox(height: 8),
          UsersListSection(
            session: usersStream,
            stream: usersStream.when(
              data: (items) => Stream.value(items),
              error: (err, _) => Stream.error(err),
              loading: () => const Stream<List<UserProfile>>.empty(),
            ),
            onSelect: _selectUser,
          ),
        ],
      ),
    );
  }
}
