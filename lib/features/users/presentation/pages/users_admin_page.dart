import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class UsersAdminPage extends ConsumerStatefulWidget {
  const UsersAdminPage({super.key});

  @override
  ConsumerState<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends ConsumerState<UsersAdminPage> {
  final _uid = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _departmentId = TextEditingController();
  final _managerId = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'employee';
  bool _isActive = true;
  bool _saving = false;

  @override
  void dispose() {
    _uid.dispose();
    _name.dispose();
    _email.dispose();
    _departmentId.dispose();
    _managerId.dispose();
    _phone.dispose();
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
    setState(() => _saving = true);
    try {
      final firestore = ref.read(firestoreProvider);
      final docRef = firestore.collection('users').doc(uid);
      final existing = await docRef.get();
      final data = <String, dynamic>{
        'full_name': _name.text.trim(),
        'email': _email.text.trim(),
        'role': _role,
        'department_id': _departmentId.text.trim(),
        'manager_id': _managerId.text.trim().isEmpty
            ? null
            : _managerId.text.trim(),
        'phone': _phone.text.trim(),
        'is_active': _isActive,
        'updated_at': FieldValue.serverTimestamp(),
      };
      if (!existing.exists) {
        data['created_at'] = FieldValue.serverTimestamp();
      }
      await docRef.set(data, SetOptions(merge: true));
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

  void _fillFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return;
    _uid.text = doc.id;
    _name.text = (data['full_name'] ?? '') as String;
    _email.text = (data['email'] ?? '') as String;
    _role = (data['role'] ?? 'employee') as String;
    _departmentId.text = (data['department_id'] ?? '') as String;
    _managerId.text = (data['manager_id'] ?? '') as String;
    _phone.text = (data['phone'] ?? '') as String;
    _isActive = (data['is_active'] ?? true) as bool;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firestore = ref.watch(firestoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
              setState(() => _role = value);
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _departmentId,
            decoration: const InputDecoration(labelText: 'Department Id'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _managerId,
            decoration: const InputDecoration(labelText: 'Manager Id'),
          ),
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
