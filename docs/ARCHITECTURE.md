# CoWork Architecture Guide

Bu dosya proje icin teknik referanstir. Yeni gelistirmeler bu kurallara gore yapilmalidir.

## 1) Mimari Prensip

- Mimari: `feature-based clean architecture` (presentation / domain / data).
- UI tarafinda tekrar azaltilir, ortak bilesenler `shared/` altinda toplanir.
- Firebase/altyapi kodu `presentation` katmanina yazilmaz.

## 2) Katmanlar

### Presentation

- Konum: `lib/features/**/presentation/**`
- Icerik:
  - `pages/`, `widgets/`, `controllers/`
  - Riverpod state yonetimi
  - Kullanici etkileşimi
- Kurallar:
  - `cloud_firestore`, `firebase_auth`, `firebase_storage`, `cloud_functions` import ETME.
  - `data` modellerini (`.../data/models/...`) import ETME.
  - Is kurali ve persistence islemlerini repository/usecase uzerinden cagir.

### Domain

- Konum: `lib/features/**/domain/**`, `lib/shared/domain/**`
- Icerik:
  - `entities`, `repositories` (abstract), `usecases`
- Kurallar:
  - Framework bagimsiz ol.
  - UI/Firebase bagimliligi olmasin.

### Data

- Konum: `lib/features/**/data/**`, `lib/shared/data/**`
- Icerik:
  - `datasources`, `models`, repository implementasyonlari
  - Firebase/HTTP/Storage entegrasyonlari
- Kurallar:
  - Dis servislerin tum detayini burada izole et.
  - Domain entity donusumu repository/model tarafinda yap.

## 3) Dependency Injection (Composition Root)

- Ana DI dosyasi: `lib/core/di/app_providers.dart`
- Tum Firebase instance/provider/repository wiring burada bulunur.
- Feature controller'lari DI tanimlamaz; sadece bu provider'lari kullanir.

## 4) UI Reuse Standartlari

Tekrar eden UI davranislari merkezi tutulur:

- App layout:
  - `lib/shared/widgets/app_scaffold.dart`
  - `lib/shared/widgets/app_scaffold/*`
- Role navigation config:
  - `lib/shared/widgets/app_scaffold/nav_config_employee.dart`
  - `lib/shared/widgets/app_scaffold/nav_config_manager.dart`
  - `lib/shared/widgets/app_scaffold/nav_config_admin.dart`
- Avatar url cozumleme (gs:// -> https):
  - Service: `lib/shared/domain/services/photo_url_resolver.dart`
  - Usecase: `lib/shared/domain/usecases/resolve_photo_url.dart`
  - Data impl: `lib/shared/data/services/firebase_photo_url_resolver.dart`
  - Widget: `lib/shared/widgets/resolved_avatar.dart`
- Photo source picker:
  - `lib/shared/widgets/photo_source_sheet.dart`
  - `lib/shared/utils/image_picker_utils.dart`
- Feedback:
  - `lib/shared/ui/feedback/app_feedback.dart`
- Dialog:
  - `lib/shared/ui/dialogs/confirm_dialog.dart`
  - `lib/shared/ui/dialogs/optional_note_dialog.dart`
- Async buttons:
  - `lib/shared/widgets/async_elevated_button.dart`
  - `lib/shared/widgets/async_outlined_button.dart`

## 5) Role ve Veri Sinirlari

- Admin departman gorunurlugu: sadece kendi olusturdugu departmanlar.
- Departments listeleme/user form departman secimi bu kurala uyar.
- Bu davranis hem app sorgularinda hem Firestore rules tarafinda korunur.

## 6) Kod Yazim Kurallari (Bu proje icin zorunlu)

- Yeni bir page/widget yazmadan once `shared/` altinda benzeri var mi kontrol et.
- Ayni UX patterni ikinci kez yazma; ortak bilesen olustur.
- Feature page dosyalari buyurse parcalandir:
  - form section
  - header
  - action row
  - picker/dialog
- Domain repository interface degisirse:
  1. domain interface
  2. data implementation
  3. provider wiring
  4. presentation usage
  sirasiyla guncelle.

## 7) Don’t List

- `presentation` icinde Firebase sorgusu yazma.
- `presentation` icinde `data/model` parse etme.
- Ayni SnackBar/Dialog kodunu farkli sayfalara kopyalama.
- `AppScaffold` disinda custom app shell yazma (ozel bir gerekce yoksa).

## 8) Gelecek Gelistirme Onceligi

- Uzun kalan dosyalari parcala:
  - `lib/features/users/presentation/controllers/users_form_controller.dart`
  - `lib/features/users/data/datasources/user_remote_ds.dart`
- Munkun oldugunca create/update akislari farkli usecase’lere ayrilsin.

---

Bu dokuman, yeni sohbetlerde de ayni mimari cizginin korunmasi icin kaynak referanstir.
