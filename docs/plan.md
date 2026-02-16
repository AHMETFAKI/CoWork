# CoWork Delivery Plan

Bu plan, mock alanlardan gercek uygulamaya gecis icin onceliklendirilmis yol haritasidir.

## 1) Uygulama Oncelik Sirasi

1. Tasks Modulu
   - `lib/features/tasks/presentation/pages/task_list_page.dart`
   - `lib/features/tasks/presentation/pages/task_create_page.dart`
2. Shifts Modulu
   - `lib/features/shifts/presentation/pages/shift_list_page.dart`
   - `lib/features/shifts/presentation/pages/shift_create_page.dart`
3. Profile Duzenleme
   - `lib/features/profile/presentation/pages/profile_page.dart`
4. Audit Logs
   - `lib/features/audit_logs/presentation/pages/audit_logs_page.dart`
5. Settings
   - `lib/features/settings/presentation/pages/settings_page.dart`

## 2) Veri Kurgusu

## 2.1 Tasks Collection

`tasks/{taskId}`

- `department_id`: string
- `assigned_to_user_id`: string
- `assigned_by_user_id`: string
- `title`: string
- `description`: string
- `status`: `todo | in_progress | done | cancelled`
- `priority`: `low | medium | high | urgent`
- `due_at`: timestamp (nullable)
- `created_at`: timestamp
- `updated_at`: timestamp

Index:

- `(department_id ASC, created_at DESC)`
- `(assigned_to_user_id ASC, status ASC, due_at ASC)`

## 2.2 Shifts Collection

`shifts/{shiftId}`

- `department_id`: string
- `user_id`: string
- `start_at`: timestamp
- `end_at`: timestamp
- `shift_type`: `morning | evening | night | custom`
- `note`: string (nullable)
- `created_by_user_id`: string
- `created_at`: timestamp
- `updated_at`: timestamp

Index:

- `(department_id ASC, start_at DESC)`
- `(user_id ASC, start_at DESC)`

## 2.3 Audit Logs Collection

`audit_logs/{logId}`

- `actor_user_id`: string
- `department_id`: string (nullable)
- `entity_type`: `task | shift | request | user | department | bootstrap`
- `entity_id`: string
- `action`: `create | update | delete | approve | reject | login | logout`
- `metadata_json`: string/json
- `created_at`: timestamp

Index:

- `(department_id ASC, created_at DESC)`
- `(actor_user_id ASC, created_at DESC)`

## 2.4 Users Profil Ek Alanlari

`users/{uid}` icin:

- `title`: string (opsiyonel)
- `bio`: string (opsiyonel)
- `updated_at`: timestamp (zorunlu)

## 3) Uygulama Kurali (Her Yeni Modulde)

Her yeni collection/akista su adimlar birlikte tamamlanir:

1. Domain entity + repository contract
2. Data model + datasource + repository implementation
3. Presentation controller + page/widget
4. Firestore rules guncellemesi
5. Firestore index guncellemesi
6. Temel testler (unit/controller)

## 4) Teknik Not

- Naming standardi: snake_case field adlari.
- Ortak zorunlu alanlar (uygunsa): `department_id`, `created_by_user_id`, `created_at`, `updated_at`.
- UI tekrarlarinda `shared/` bilesenleri tercih edilir (dialog, snackbar, async button, photo picker, scaffold).
