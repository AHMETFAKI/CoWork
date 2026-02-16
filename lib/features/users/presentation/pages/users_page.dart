import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cowork/shared/widgets/app_scaffold.dart';
import 'package:cowork/shared/ui/dialogs/confirm_dialog.dart';
import 'package:cowork/shared/ui/feedback/app_feedback.dart';
import 'package:cowork/shared/utils/image_picker_utils.dart';
import 'package:cowork/features/users/presentation/widgets/user_form_section.dart';
import 'package:cowork/features/users/presentation/widgets/users_list_section.dart';
import 'package:cowork/features/users/domain/entities/user_profile.dart';
import 'package:cowork/features/users/presentation/controllers/users_controller.dart';
import 'package:cowork/features/users/presentation/controllers/users_form_controller.dart';
import 'package:cowork/features/departments/presentation/controllers/departments_controller.dart';
import 'package:cowork/shared/widgets/photo_source_sheet.dart';

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
          photoBytes: fieldsState.photoBytes,
        );

    if (!mounted) return;

    if (result.alreadyExists) {
      final shouldLoad = await showConfirmDialog(
        context,
        title: 'Kullanici zaten var',
        content: 'Bu email zaten kayitli. Profili yukleyip duzenlemek ister misin?',
        cancelText: 'Hayir',
        confirmText: 'Evet, yukle',
      );
      if (shouldLoad) {
        final user = await ref
            .read(usersFormControllerProvider.notifier)
            .loadUserByEmail(fields.email.text.trim());
        if (user != null) {
          _selectUser(user);
        } else {
          showErrorSnackBar(context, 'Profil bulunamadi.');
        }
      }
      return;
    }

    if (!result.success) {
      showErrorSnackBar(context, result.errorMessage ?? 'Save failed.');
      return;
    }

    if (result.createdUid != null) {
      fields.docId.text = result.createdUid!;
      fields.password.clear();
    }

    showSuccessSnackBar(context, 'User saved.');
  }

  void _clearForm() {
    ref.read(usersFormFieldsProvider.notifier).clearForm();
  }

  Future<void> _choosePhotoSource() async {
    final source = await showPhotoSourceSheet(context);
    if (source == null) return;
    final bytes = await pickImageBytes(source: source);
    if (bytes == null || !mounted) return;
    ref.read(usersFormFieldsProvider.notifier).setPhotoBytes(bytes);
  }

  Future<void> _selectUser(UserProfile user) async {
    ref.read(usersFormFieldsProvider.notifier).fillFromUser(user);
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
            photoUrl: fieldsState.photoUrl,
            photoBytes: fieldsState.photoBytes,
            saving: formState.isLoading,
            departmentsStream: departmentsStream.when(
              data: (items) => Stream.value(items),
              error: (err, _) => Stream.error(err),
              loading: () => const Stream.empty(),
            ),
            onNew: _clearForm,
            onSave: _saveUser,
            onPickPhoto: _choosePhotoSource,
            onClearPhoto: () => ref.read(usersFormFieldsProvider.notifier).clearPhoto(),
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
