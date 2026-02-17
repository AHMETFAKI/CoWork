# CoWork Delivery Plan

Bu plan, mock alanlardan gercek uygulamaya gecis icin onceliklendirilmis yol haritasidir.

## 1) Uygulama Oncelik Sirasi

1. Tasks Modulu
   - `lib/features/tasks/presentation/pages/task_list_page.dart`
   - `lib/features/tasks/presentation/pages/task_create_page.dart`
2. Shifts Modulu
   - `lib/features/shifts/presentation/pages/shift_list_page.dart`
   - `lib/features/shifts/presentation/pages/shift_create_page.dart`
   - Not: Bu modul klasik vardiya olusturma degil, QR/Link tabanli giris-cikis (attendance) odakli gelistirilecektir.
3. Team Directory + Mesajlasma (Ekibim)
   - `lib/features/team/presentation/pages/team_list_page.dart`
   - `lib/features/team/presentation/pages/team_member_profile_page.dart`
   - `lib/features/messages/presentation/pages/conversation_page.dart`
4. Profile Duzenleme
   - `lib/features/profile/presentation/pages/profile_page.dart`
5. Audit Logs
   - `lib/features/audit_logs/presentation/pages/audit_logs_page.dart`
6. Settings
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

## 2.2 Shift Attendance Collection

`shift_attendance/{attendanceId}`

- `department_id`: string
- `user_id`: string
- `user_role`: `admin | manager | employee`
- `event_type`: `check_in | check_out`
- `event_at`: timestamp
- `source`: `qr | link`
- `token_id`: string (nullable)
- `created_at`: timestamp

Index:

- `(department_id ASC, event_at DESC)`
- `(user_id ASC, event_at DESC)`
- `(department_id ASC, user_role ASC, event_at DESC)`

## 2.2.1 Shift Attendance (QR/Link) Stratejisi

Amaç:
- Giris ve cikis aninda saat/tarih kaydi tutmak.
- Yetki hiyerarsisi:
1. `admin`: kendi + manager + employee kayitlarini gorur.
2. `manager`: kendi + employee kayitlarini gorur.
3. `employee`: sadece kendi kayitlarini gorur.

Gecici teknik cozum (QR oncesi):
1. Her kullanici icin bir `check_token` (veya sentetik link tokeni) uretilir.
2. Kullanici uygulamada "Check-in / Check-out" butonuna basar veya tokenli linke tiklar.
3. Sistem token + kullanici kimligi dogrular, attendance kaydini olusturur.
4. QR asamasinda ayni token payload'u QR icine yazilip tarama ile ayni endpoint akisi kullanilir.

Onerilen koleksiyon:

`shift_attendance/{attendanceId}`

- `department_id`: string
- `user_id`: string
- `event_type`: `check_in | check_out`
- `event_at`: timestamp
- `source`: `qr | link`
- `token_id`: string (opsiyonel)
- `created_at`: timestamp

Index:

- `(department_id ASC, event_at DESC)`
- `(user_id ASC, event_at DESC)`

Goruntuleme kurali:
- Liste sorgusu user role'a gore filtrelenir:
  - employee: `user_id == currentUser.uid`
  - manager: `department_id == currentUser.department_id` + UI'da `role != admin`
  - admin: `department_id == currentUser.department_id` (veya scope kararina gore tum departmanlar)

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

## 2.5 Team Directory + Mesajlasma Veri Kurgusu

### Team Listeleme

- Kaynak: `users` collection
- Liste alani: `full_name`, `photo_url`, `department_id`, `role`, `is_active`
- Siralama: `full_name ASC`
- Filtre: oturum kullanicisinin gorebildigi ekip kurallari (admin/manager/employee)

### Conversations Collection

`conversations/{conversationId}`

- `participant_ids`: array<string> (2 kisi icin)
- `department_id`: string (nullable)
- `last_message`: string (nullable)
- `last_message_at`: timestamp (nullable)
- `created_at`: timestamp
- `updated_at`: timestamp

Index:

- `(participant_ids ARRAY_CONTAINS, last_message_at DESC)`

### Messages Collection

`conversations/{conversationId}/messages/{messageId}`

- `sender_user_id`: string
- `text`: string
- `created_at`: timestamp
- `updated_at`: timestamp
- `is_deleted`: bool (opsiyonel, default false)

Index:

- `(created_at ASC)`

### Team UX Akisi

1. `Ekibim` listesinde ad + profil fotografi gorunur.
2. Kisiye tiklaninca profil detay sayfasi acilir.
3. Profil sayfasinda ust-orta profil fotografi, altta mesaj giris alani olur.
4. Mesaj gonderme ile conversation yoksa olusturulur, varsa mevcut conversation'a mesaj eklenir.

## 2.6 Attendance Analytics (Mock Plan Sonrasi)

Bu kisim ilk canli fazdan sonra eklenecek analytics kapsamidir:

- Zaman araliklari:
  - bugun
  - son 3 gun
  - son hafta
  - son ay
- Kullanici bazli istatistik:
  - toplam check-in sayisi
  - toplam check-out sayisi
  - toplam calisilan sure
  - ilk giris saati / son cikis saati
- Gun bazli grafik:
  - her gun calisilan toplam saat
  - gunluk check-in ve check-out saatleri
- Ofise tekrar giris-cikis metrikleri:
  - ayni gunde kac kez giris yapildi
  - ayni gunde kac kez cikis yapildi

## 3) Uygulama Kurali (Her Yeni Modulde)

Her yeni collection/akista su adimlar birlikte tamamlanir:

1. Domain entity + repository contract
2. Data model + datasource + repository implementation
3. Presentation controller + page/widget
4. Firestore rules guncellemesi
5. Firestore index guncellemesi
6. Temel testler (unit/controller)

## 3.1 Shift Attendance Uygulama Sirasi

1. Domain:
   - `ShiftAttendance` entity + repository contract
2. Data:
   - Firestore datasource + model + repository implementation
3. Presentation:
   - `Check-in / Check-out` aksiyonlari
   - role'a gore filtreli listeleme sayfasi
4. Security:
   - Firestore rules ile hiyerarsik read/write yetkileri
5. Gecici token akisi:
   - sentetik link tokeni uretilmesi ve dogrulanmasi
6. Sonraki faz:
   - QR tarama entegrasyonu (mevcut token akisina baglanacak)

## 4) Teknik Not

- Naming standardi: snake_case field adlari.
- Ortak zorunlu alanlar (uygunsa): `department_id`, `created_by_user_id`, `created_at`, `updated_at`.
- UI tekrarlarinda `shared/` bilesenleri tercih edilir (dialog, snackbar, async button, photo picker, scaffold).
