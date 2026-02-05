import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class UsersAdminPage extends ConsumerStatefulWidget {
  const UsersAdminPage({super.key});

  @override
  ConsumerState<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _DepartmentOption {
  final String id;
  final String name;
  final String? managerId;

  const _DepartmentOption({
    required this.id,
    required this.name,
    required this.managerId,
  });
}


class _UsersAdminPageState extends ConsumerState<UsersAdminPage> {
  final _uid = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _managerId = TextEditingController();
  final _phone = TextEditingController();
  final _deptName = TextEditingController();
  final _deptDesc = TextEditingController();
  String _role = 'employee';
  String? _selectedDeptId;
  String? _selectedDeptManagerId;
  bool _setDeptManager = true;
  bool _isActive = true;
  bool _saving = false;
  bool _deptActive = true;
  bool _deptSaving = false;

  @override
  void dispose() {
    _uid.dispose();
    _name.dispose();
    _email.dispose();
    _managerId.dispose();
    _phone.dispose();
    _deptName.dispose();
    _deptDesc.dispose();
    super.dispose();
  }




  Future<void> _saveUser() async {
    final uid = _uid.text.trim();
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UID is required.')),
      );
      return;
    }
    final deptId = _selectedDeptId?.trim();
    if (_role != 'admin' && (deptId == null || deptId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department is required for this role.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final firestore = ref.read(firestoreProvider);
      final docRef = firestore.collection('users').doc(uid);
      final existing = await docRef.get();
      final departmentId = deptId != null && deptId.isNotEmpty ? deptId : null;
    final managerId = switch (_role) {
        'manager' => uid,
        'employee' => _selectedDeptManagerId,
        _ => null,
      };
    if (_role == 'employee' && (managerId == null || managerId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uyari: Bu departmanda manager yok.')),
      );
    }
      final data = <String, dynamic>{
        'full_name': _name.text.trim(),
        'email': _email.text.trim(),
        'role': _role,
        'department_id': departmentId,
        'manager_id': managerId,
        'phone': _phone.text.trim(),
        'is_active': _isActive,
        'updated_at': FieldValue.serverTimestamp(),
      };
      if (!existing.exists) {
        data['created_at'] = FieldValue.serverTimestamp();
      }
      final batch = firestore.batch();
      batch.set(docRef, data, SetOptions(merge: true));
      if (_role == 'manager' && _setDeptManager && departmentId != null) {
        final deptRef = firestore.collection('departments').doc(departmentId);
        batch.set(
          deptRef,
          {
            'manager_id': uid,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _createDepartment() async {
    final name = _deptName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departman adi gerekli.')),
      );
      return;
    }
    setState(() => _deptSaving = true);
    try {
      final firestore = ref.read(firestoreProvider);
      final docRef = firestore.collection('departments').doc();
      await docRef.set({
        'name': name,
        'description': _deptDesc.text.trim(),
        'manager_id': null,
        'is_active': _deptActive,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _deptName.clear();
      _deptDesc.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departman olusturuldu.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Departman olusturma hatasi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _deptSaving = false);
      }
    }
  }

  void _fillFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return;
    _uid.text = doc.id;
    _name.text = (data['full_name'] ?? '') as String;
    _email.text = (data['email'] ?? '') as String;
    _role = (data['role'] ?? 'employee') as String;
    _managerId.text = (data['manager_id'] ?? '') as String;
    _phone.text = (data['phone'] ?? '') as String;
    _isActive = (data['is_active'] ?? true) as bool;
    _selectedDeptId = (data['department_id'] ?? '') as String?;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firestore = ref.watch(firestoreProvider);

    return AppScaffold(
      title: 'User Admin',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Departman Olustur',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _deptName,
            decoration: const InputDecoration(labelText: 'Departman Adi *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deptDesc,
            decoration: const InputDecoration(labelText: 'Aciklama'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Aktif'),
            value: _deptActive,
            onChanged: (value) => setState(() => _deptActive = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _deptSaving ? null : _createDepartment,
              child: _deptSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Departman Olustur'),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _uid,
            decoration: const InputDecoration(labelText: 'UID'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('admin')),
              DropdownMenuItem(value: 'manager', child: Text('manager')),
              DropdownMenuItem(value: 'employee', child: Text('employee')),
            ],
            onChanged: (value) {
              if (value == null) return;
              if (value != _role) {
                _role = value;
                if (_role != 'admin' && (_selectedDeptId == null || _selectedDeptId!.isEmpty)) {
                  _managerId.text = '';
                }
                if (_role == 'manager') {
                  _managerId.text = _uid.text.trim();
                } else if (_role == 'employee') {
                  _managerId.text = _selectedDeptManagerId ?? '';
                } else {
                  _managerId.text = '';
                }
              }
              setState(() => _role = value);
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('departments').orderBy('name').snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final items = docs.map((doc) {
                final data = doc.data();
                final name = (data['name'] ?? doc.id) as String;
                final managerId = data['manager_id'] as String?;
                return _DepartmentOption(
                  id: doc.id,
                  name: name,
                  managerId: managerId,
                );
              }).toList();
              final selected = items.firstWhere(
                (item) => item.id == _selectedDeptId,
                orElse: () => const _DepartmentOption(id: '', name: '', managerId: null),
              );
              return DropdownButtonFormField<String>(
                value: selected.id.isEmpty ? null : selected.id,
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  _selectedDeptId = value;
                  final match = items.firstWhere(
                    (item) => item.id == value,
                    orElse: () => const _DepartmentOption(id: '', name: '', managerId: null),
                  );
                  _selectedDeptManagerId = match.managerId;
                  if (_role == 'employee') {
                    _managerId.text = _selectedDeptManagerId ?? '';
                  }
                  if (_role == 'manager') {
                    _managerId.text = _uid.text.trim();
                  }
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: _role == 'admin' ? 'Department (optional)' : 'Department *',
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _managerId,
            readOnly: _role != 'admin',
            decoration: InputDecoration(
              labelText: _role == 'employee'
                  ? 'Manager Id (from department)'
                  : _role == 'manager'
                      ? 'Manager Id (self)'
                      : 'Manager Id',
            ),
          ),
          if (_role == 'manager') ...[
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Set as department manager'),
              value: _setDeptManager,
              onChanged: (value) => setState(() => _setDeptManager = value),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Active'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveUser,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Users'),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .collection('users')
                .orderBy('full_name')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Text('No users found.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final name = (data['full_name'] ?? '-') as String;
                  final email = (data['email'] ?? '-') as String;
                  final role = (data['role'] ?? '-') as String;
                  final dept = (data['department_id'] ?? '-') as String;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text(
                      'UID: ${doc.id}\nemail: $email\nrole: $role | dept: $dept',
                    ),
                    onTap: () => _fillFromDoc(doc),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
