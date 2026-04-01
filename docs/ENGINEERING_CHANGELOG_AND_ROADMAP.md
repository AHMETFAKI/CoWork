# CoWork Engineering Changelog and Roadmap

Bu dokuman, projede su ana kadar yapilan teknik gelistirmeleri, modul bazli mimariyi ve sonraki adimlari versiyon mantigiyla toplar.

## 1) Versioning Yaklasimi

- Format: `MAJOR.MINOR.PATCH`
- `MAJOR`: mimariyi veya ana akis davranisini degistiren kirici degisiklik
- `MINOR`: yeni modul/ozellik, geriye uyumlu
- `PATCH`: bugfix, iyilestirme, test/doc guncellemesi

Bu dosya tarihsel kaynak olarak korunur; her release'te yeni bir versiyon bolumu eklenir.

## 2) Modul ve Mimari Ozeti

### 2.1 Mimari

- Feature-based + clean architecture
- Katmanlar:
  - `presentation`: sayfalar, widget'lar, Riverpod controller/provider
  - `domain`: entity, repository interface, use case
  - `data`: Firebase datasource, model, repository implementation
- Ortak UI ve altyapi:
  - `lib/shared/**`
  - `lib/core/**`

### 2.2 Ana Modul Haritasi

- Auth: `lib/features/auth/**`
- Dashboard: `lib/features/dashboard/**`
- Requests + Approvals: `lib/features/requests/**`, `lib/features/approvals/**`
- Tasks: `lib/features/tasks/**`
- Shift Attendance: `lib/features/shifts/**`
- Team/Messaging: `lib/features/team/**`, `lib/features/messages/**`
- Admin Management:
  - Users: `lib/features/users/**`
  - Departments: `lib/features/departments/**`
- Mock/placeholder kalanlar:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/audit_logs/presentation/pages/audit_logs_page.dart`
  - `lib/features/settings/presentation/pages/settings_page.dart`

## 3) Version History

## v1.4.0 - Dashboard-Centered Messaging

### Yapilanlar

1. Team sekmesi ana sayfaya tasindi.
  - Bottom nav'dan `Ekibim` cikarildi.
  - Dashboard ana ekrani sohbet listesi olacak sekilde duzenlendi.
2. Sohbet listesi stream'i eklendi.
  - `conversations` icin repository/data/domain akisina summary stream eklendi.
3. FAB ile sohbet baslatma akisi eklendi.
  - `+` butonu ile tum kullanicilar listeleniyor.
  - Gruplama: departman bazli, her grupta manager ustte employee altta.
4. Sohbet detay UX'i sadeletildi.
  - Buyuk profil blogu kaldirildi.
  - Kompakt chat header + AppBar bilgisi.
  - Son mesaja otomatik inis.
  - Chat detayinda bottom nav kapatildi.
5. Navigation duzenlendi.
  - `/team` liste route kaldirildi.
  - Detay route (`/team/member/:uid`) push ile aciliyor (geri tusu calisiyor).

### Etkilenen Dosyalar (Ozet)

- Navigation:
  - `lib/shared/widgets/app_scaffold/nav_config_admin.dart`
  - `lib/shared/widgets/app_scaffold/nav_config_manager.dart`
  - `lib/shared/widgets/app_scaffold/nav_config_employee.dart`
  - `lib/core/routing/app_router.dart`
  - `lib/core/routing/routes.dart`
  - `lib/core/routing/guards.dart`
- Dashboard/chat:
  - `lib/features/dashboard/presentation/widgets/dashboard_chat_home.dart`
  - `lib/features/team/presentation/pages/team_member_profile_page.dart`
- Messages:
  - `lib/features/messages/domain/entities/chat_conversation_summary.dart`
  - `lib/features/messages/data/models/chat_conversation_summary_model.dart`
  - `lib/features/messages/domain/repositories/messages_repository.dart`
  - `lib/features/messages/data/repositories/messages_repository_impl.dart`
  - `lib/features/messages/data/datasources/messages_remote_ds.dart`
  - `lib/features/messages/presentation/controllers/messages_controller.dart`
- Directory (tum kullanicilar/departmanlar):
  - `lib/features/users/presentation/controllers/users_controller.dart`
  - `lib/features/users/domain/repositories/user_repository.dart`
  - `lib/features/users/data/repositories/user_repository_impl.dart`
  - `lib/features/users/data/datasources/user_remote_ds.dart`
  - `lib/features/departments/presentation/controllers/departments_controller.dart`
  - `lib/features/departments/domain/repositories/department_repository.dart`
  - `lib/features/departments/data/repositories/department_repository_impl.dart`
  - `lib/features/departments/data/datasources/department_remote_ds.dart`
- Security rules:
  - `firestore.rules`

## v1.4.1 - Rules and Usability Fixes

### Yapilanlar

1. `permission-denied` icin rules tarafinda directory okuyacak sekilde izinler genisletildi.
2. Departman adlari eksik gorunme hatasi giderildi:
  - dashboard chat user picker artik directory department stream kullaniyor.
3. Sohbet AppBar sadeletildi:
  - chat detayinda hamburger ve global profil aksiyonu kapatildi.

## v1.4.2 - Test and Documentation Baseline

### Yapilanlar

1. Messages controller testleri eklendi.
  - Dosya: `test/features/messages/presentation/controllers/messages_controller_test.dart`
2. Directory provider testleri eklendi.
  - Dosya: `test/features/directory/presentation/controllers/directory_providers_test.dart`
3. Bu versiyon dokumani eklendi.
  - Dosya: `docs/ENGINEERING_CHANGELOG_AND_ROADMAP.md`

## 4) Test Stratejisi (Mevcut + Hedef)

### Mevcut

- Task controller testleri:
  - `test/features/tasks/presentation/controllers/task_controller_test.dart`
- Shift controller testleri:
  - `test/features/shifts/presentation/controllers/shift_controller_test.dart`
- Messages controller testleri:
  - `test/features/messages/presentation/controllers/messages_controller_test.dart`
- Directory provider testleri:
  - `test/features/directory/presentation/controllers/directory_providers_test.dart`

### Eksik/Hedef

1. Request controller unit testleri (create + status transition + validation)
2. Approvals business flow testleri
3. Router/guard testleri (role bazli access)
4. Messaging integration tests (conversation create + receive + list sync)
5. Firestore rule emulation testleri (firebase emulator ile)

## 5) Clean Code ve Modul Kurallari

1. Presentation katmaninda Firebase import edilmeyecek.
2. Domain contract degisince:
  - interface -> data impl -> provider wiring -> presentation kullanim sirasiyla guncellenecek.
3. Ortak UI tekrar etmeyecek:
  - `AppScaffold`, `ResolvedAvatar`, feedback/dialog widget'lari kullanilacak.
4. Yeni feature eklenirken minimum paket:
  - entity + repository contract + datasource + controller + page + rules + index + test

## 6) Gelecek Plan (Roadmap)

## Kisa Vade (v1.5.x)

1. Profile sayfasini mock'tan cikar:
  - ad, telefon, unvan, bio, avatar update
2. Audit Logs gercek liste:
  - filtreleme (actor, tarih, entity_type)
3. Settings gercek ayarlar:
  - bildirim, tema, dil, oturum/guvenlik
4. Chat UX iyilestirme:
  - kullanici yukari kaydirdiginda zorla auto-scroll yapmama
  - mesaj zaman damgasi/okundu bilgisi altyapisi

## Orta Vade (v1.6.x)

1. Requests/Approvals detay ekranlari
2. Task detail + activity history
3. Shift QR dogrulama akisi (sentetik linkten gercek QR pipeline'a gecis)
4. Emulator tabanli CI test pipeline

## Uzun Vade (v2.0)

1. Multi-tenant organization katmani
2. Gelismis analytics dashboard
3. Notification orchestration (FCM + in-app inbox)

## 7) Operational Notes

1. Rules degisikligi sonrasinda her zaman deploy gerekir:
  - `firebase deploy --only firestore:rules`
2. Index degisikligi gerektiren sorgular:
  - `firestore.indexes.json` ile versiyonlanir ve deploy edilir.
3. Dokuman drift olusmamasi icin bu dosya her release'te guncellenmelidir.





• Özetle, roadmap’e göre en net açıklar bunlar:

1. Profile/Audit/Settings hala mock.

- lib/features/profile/presentation/pages/profile_page.dart:32
- lib/features/audit_logs/presentation/pages/audit_logs_page.dart:13
- lib/features/settings/presentation/pages/settings_page.dart:13

2. Profil düzenleme için rules engeli var.

- firestore.rules:84 sadece admin’e users update izni veriyor; kullanıcı kendi profilini güncelleyemiyor.
- v1.5 hedefin (profil update) için önce bu kural + data/controller akışı açılmalı.

3. Test borcu roadmap’te yazıyor ve kodda gerçekten yok.

- Hedefler: docs/ENGINEERING_CHANGELOG_AND_ROADMAP.md:133
- requests/approvals/router/rules/integration test dosyaları yok (test altında bulunmuyor).

4. CI/emulator pipeline yok.

- .github dizini yok, workflow yok.
- Roadmap’te “emulator tabanlı CI” var ama uygulanmamış.

5. İndeks tarafında audit_logs yok.

- firestore.indexes.json içinde audit_logs geçmiyor.
- Audit ekranında filtre/sıralama yapacaksan indeks eklemen gerekecek.

6. Repo hijyeni sorunu:

- functions/node_modules gitte takip ediliyor (5641 dosya). Bu ciddi gereksiz yük.
- .gitignore içinde functions/node_modules/ yok.

7. Versiyon/doküman drift:

- Roadmap v1.4.x anlatıyor ama pubspec.yaml:19 hala 1.0.0+1.
- docs/ENGINEERING_CHANGELOG_AND_ROADMAP.md şu an gitte untracked görünüyor.

Yapman gereken sıra (pratik backlog):

1. v1.5.0 için önce Profile’ı gerçek akışa çevir (entity/repo/ds/controller/page + rules + test).
2. Audit Logs’u gerçek liste+filtre ile bitir ve gerekli indexleri ekle.
3. Settings’i gerçek ayarlara bağla.
4. Request/Approval + Router/Guard + Rules emulation testlerini ekle.
5. CI workflow (Flutter test + emulator rules test) kur.
6. functions/node_modules takibini kaldır, .gitignore düzelt, versiyonları senkronla.

Not: Bu ortamda flutter test ve flutter --version komutları sürekli timeout oldu, çalıştırma sonucu doğrulaması yapamadım.