# Departman Bazlı İnsan Kaynakları ve Çalışan Yönetim Sistemi
## Strateji ve Katmanlı Mimari Dosya Yapısı

Bu doküman, verilen proje raporuna göre **MVP odaklı geliştirme stratejisini** ve **feature-based + hafif clean architecture** yaklaşımına uygun önerilen dosya yapısını tanımlar.

## 1) Strateji: MVP’yi çekirdeğe oturt, sonra genişlet
### A. Çekirdek prensipler (kritik 3 madde)
1. **Role + department authorization her katmanda hissedilir**
   - UI menüleri role göre açılıp kapanır.
   - Backend’de **Firestore Security Rules** ile gerçek yetki korunur.
   - Data katmanında **tüm sorgular departmentId filtreli** akar (Admin hariç).
2. **MVP modülleri tam çalışır**
   - Auth + Dashboard + Tasks + Shifts + Requests + Approvals.
3. **Audit log zorunlu**
   - Kritik aksiyonlar (onay/ret, görev atama, vardiya ekleme) loglanır.

### B. MVP geliştirme sırası (en hızlı demo)
1. **Auth + Session**
   - Firebase Auth ile login.
   - Firestore’da `users/{uid}` dokümanını çek → `role`, `departmentId`.
   - Role göre dashboard route.
2. **Role-based Navigation**
   - Admin: sistem geneli.
   - Manager: departman ekranları.
   - Employee: kişisel ekranlar.
3. **Requests + Approvals**
   - Employee request oluşturur (izin/avans/masraf).
   - Manager onay/ret + yorum.
   - Approval kaydı + audit log.
4. **Tasks**
   - Manager -> employee’ye görev atar.
   - “Departmana görev” için çalışan başına task dokümanı oluştur (hesap verilebilirlik).
5. **Shifts**
   - Manager vardiya tanımlar.
   - Çakışma kontrolü (aynı employee için zaman aralığı overlap var mı?).

## 2) Mimari karar: Feature-based + Clean Architecture (hafif)
Her feature aşağıdaki katmanlara sahip olur:
- **presentation/** (UI, pages, widgets, controllers/notifiers)
- **domain/** (entity + repository interface + usecase)
- **data/** (dto/model, datasource, repository impl)

Ortak modüller:
- **core/** (routing, theme, error, utils, constants)
- **shared/** (common widgets, validators, formatters)
- **services/** (firebase init, storage, analytics vs.)

State management: **Riverpod**.

## 3) Önerilen dosya yapısı (büyüyebilir ve karışmaz)
```
lib/
  main.dart
  app.dart

  core/
    config/
      env.dart
      firebase_options.dart
    routing/
      app_router.dart
      routes.dart
      guards.dart          // role/department guard
    theme/
      app_theme.dart
      colors.dart
      typography.dart
    errors/
      failures.dart
      exceptions.dart
      error_mapper.dart
    utils/
      date_utils.dart
      id_utils.dart
    constants/
      app_constants.dart

  services/
    firebase/
      firebase_initializer.dart
      firestore_path.dart
    storage/
      storage_service.dart
    notifications/
      notification_service.dart   // MVP dışı ama altyapı dursun

  shared/
    widgets/
      app_scaffold.dart
      empty_state.dart
      loading.dart
      app_text_field.dart
      confirm_dialog.dart
    validators/
      validators.dart

  features/
    auth/
      presentation/
        pages/login_page.dart
        controllers/auth_controller.dart
      domain/
        entities/app_user.dart
        repositories/auth_repository.dart
        usecases/sign_in.dart
        usecases/sign_out.dart
        usecases/watch_session.dart
      data/
        models/app_user_model.dart
        datasources/auth_remote_ds.dart
        repositories/auth_repository_impl.dart

    profile/
      presentation/pages/profile_page.dart
      domain/usecases/get_profile.dart
      data/...

    dashboard/
      presentation/
        pages/admin_dashboard_page.dart
        pages/manager_dashboard_page.dart
        pages/employee_dashboard_page.dart
        widgets/kpi_card.dart
      domain/...
      data/...

    departments/                 // Admin ağırlıklı
      presentation/pages/departments_page.dart
      domain/...
      data/...

    users/                       // Admin + Manager (listeleme)
      presentation/pages/users_page.dart
      domain/...
      data/...

    tasks/
      presentation/
        pages/task_list_page.dart
        pages/task_detail_page.dart
        pages/task_create_page.dart
        controllers/task_controller.dart
      domain/
        entities/task.dart
        repositories/task_repository.dart
        usecases/create_task.dart
        usecases/update_task_status.dart
        usecases/watch_tasks.dart
      data/
        models/task_model.dart
        datasources/task_remote_ds.dart
        repositories/task_repository_impl.dart

    shifts/
      presentation/pages/shift_list_page.dart
      presentation/pages/shift_create_page.dart
      domain/entities/shift.dart
      domain/usecases/create_shift.dart
      data/...

    requests/
      presentation/
        pages/request_list_page.dart
        pages/request_create_page.dart
        pages/request_detail_page.dart
      domain/
        entities/request.dart
        repositories/request_repository.dart
        usecases/create_request.dart
        usecases/watch_requests.dart
      data/...

    approvals/
      presentation/pages/approval_inbox_page.dart
      domain/entities/approval.dart
      domain/usecases/approve_request.dart
      domain/usecases/reject_request.dart
      data/...

    audit_logs/
      data/datasources/audit_remote_ds.dart
      domain/usecases/log_action.dart
```

## 4) Routing + Guard mantığı (rol/departman)
- Splash → session kontrol.
- Session varsa `AppUser(role, departmentId)` yüklenir.
- `guards.dart` içinde Admin/Manager/Employee route kuralları tanımlanır.
- Manager, `/users` sayfasına girebilir ama query her zaman `departmentId == manager.departmentId`.

## 5) Firestore koleksiyonları ile uygulama katmanlarının eşleşmesi
Koleksiyonlar:
- `departments`, `users`, `tasks`, `shifts`, `requests`, `attachments`, `approvals`, `audit_logs`

UI menüleri de aynı modüllere oturtulur:
- **Admin:** departments, users, system monitoring (requests/tasks/shifts overview)
- **Manager:** tasks, shifts, approvals (inbox), employees (department users)
- **Employee:** my tasks, my shifts, my requests, create request

## 6) “Departmana ortak görev” yaklaşımı
Görevler bireye atanır; departmana/toplu görev için **çalışan başına kopya task dokümanı** oluşturulur.
- Kim ne yaptı belli.
- Geciken kişi net.
- Performans ölçümü daha doğru.

> İleride `group_task` üst dokümanı + `taskInstances` alt koleksiyonu eklenebilir; MVP’de şart değildir.

## 7) İlk sprint checklist’i
- Proje oluştur + Riverpod setup.
- Firebase init (auth + firestore).
- `users/{uid}` modeli + role routing.
- 3 dashboard sayfası (dummy KPI kartları).
- Requests create/list + Manager approval inbox (en hızlı “kurumsal demo”).

