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



## 8) Firestore koleksiyonlar ve ornek document sablonlari

### departments/{deptId}
```json
{
  "name": "Insan Kaynaklari",
  "description": "IK operasyonlari",
  "manager_id": "user_abc123",
  "is_active": true,
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP"
}
```

### users/{userId}
Kullanici id'si olarak FirebaseAuth uid kullanman onerilir.

```json
{
  "full_name": "Ahmet Faki",
  "email": "ahmet@example.com",
  "role": "employee",
  "department_id": "dept_hr",
  "manager_id": "user_mgr01",
  "phone": "+90...",
  "is_active": true,
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP",
  "last_login_at": "SERVER_TIMESTAMP"
}
```

### tasks/{taskId}
```json
{
  "department_id": "dept_hr",
  "assigned_to_user_id": "user_emp01",
  "assigned_by_user_id": "user_mgr01",
  "title": "Aday CV tarama",
  "description": "Gelen basvurulari incele",
  "status": "todo",
  "priority": "medium",
  "due_date": "2026-02-10T12:00:00Z",
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP",
  "completed_at": null
}
```

### shifts/{shiftId}
```json
{
  "department_id": "dept_hr",
  "user_id": "user_emp01",
  "start_at": "2026-02-05T06:00:00Z",
  "end_at": "2026-02-05T14:00:00Z",
  "location": "Ofis",
  "shift_type": "day",
  "notes": "",
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP"
}
```

### requests/{requestId}
NOT: department_id zorunlu alan.

```json
{
  "department_id": "dept_hr",
  "created_by_user_id": "user_emp01",
  "type": "leave",
  "status": "pending",
  "amount": null,
  "currency": "TRY",
  "start_date": "2026-02-10T00:00:00Z",
  "end_date": "2026-02-12T00:00:00Z",
  "category": null,
  "reason": "Aile ziyareti",
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP"
}
```

Masraf ornegi:

```json
{
  "department_id": "dept_hr",
  "created_by_user_id": "user_emp01",
  "type": "expense",
  "status": "pending",
  "amount": 245.5,
  "currency": "TRY",
  "start_date": null,
  "end_date": null,
  "category": "Yol",
  "reason": "Sehir ici ulasim",
  "created_at": "SERVER_TIMESTAMP",
  "updated_at": "SERVER_TIMESTAMP"
}
```

### requests/{requestId}/attachments/{attachmentId}
```json
{
  "uploaded_by_user_id": "user_emp01",
  "file_url": "gs://.../receipt.jpg",
  "file_type": "image",
  "created_at": "SERVER_TIMESTAMP"
}
```

### requests/{requestId}/approvals/{approvalId}
```json
{
  "reviewer_user_id": "user_mgr01",
  "action": "approved",
  "comment": "Uygun",
  "reviewed_at": "SERVER_TIMESTAMP"
}
```

### audit_logs/{logId}
```json
{
  "actor_user_id": "user_mgr01",
  "department_id": "dept_hr",
  "entity_type": "request",
  "entity_id": "req_001",
  "action": "approve",
  "metadata_json": "{\"status\":{\"old\":\"pending\",\"new\":\"approved\"}}",
  "created_at": "SERVER_TIMESTAMP"
}
```

## 9) Alan adlandirma ve zorunlu alanlar

### Adlandirma kurallari
- Koleksiyon ve alan adlari: `snake_case`
- Dokuman id: `kebab-case` veya `snake_case` (tutarlilik oncelikli)
- Tarih/saat alanlari: ISO-8601 string veya Firestore `Timestamp`
- Audit metadata: tek satir JSON string (or: map) - standartlasma gerekli

### Zorunlu alanlar (minimum)

#### departments
- `name`, `manager_id`, `is_active`, `created_at`, `updated_at`

#### users
- `full_name`, `email`, `role`, `department_id`, `manager_id`, `is_active`, `created_at`, `updated_at`

#### tasks
- `department_id`, `assigned_to_user_id`, `assigned_by_user_id`, `title`, `status`, `priority`, `created_at`, `updated_at`

#### shifts
- `department_id`, `user_id`, `start_at`, `end_at`, `shift_type`, `created_at`, `updated_at`

#### requests
- `department_id`, `created_by_user_id`, `type`, `status`, `created_at`, `updated_at`
- `amount` ve `currency` sadece `expense` icin zorunlu
- `start_date` ve `end_date` sadece `leave` icin zorunlu

#### requests/{requestId}/attachments
- `uploaded_by_user_id`, `file_url`, `file_type`, `created_at`

#### requests/{requestId}/approvals
- `reviewer_user_id`, `action`, `reviewed_at`

#### audit_logs
- `actor_user_id`, `department_id`, `entity_type`, `entity_id`, `action`, `created_at`

## 10) Role/flow bazli zorunlu alanlar

### Employee akislari

#### Request olusturma (leave)
- Zorunlu: `department_id`, `created_by_user_id`, `type`, `status`, `start_date`, `end_date`, `created_at`, `updated_at`
- Opsiyonel: `reason`

#### Request olusturma (expense)
- Zorunlu: `department_id`, `created_by_user_id`, `type`, `status`, `amount`, `currency`, `category`, `created_at`, `updated_at`
- Opsiyonel: `reason`, `start_date`, `end_date`

#### Request attachment yukleme
- Zorunlu: `uploaded_by_user_id`, `file_url`, `file_type`, `created_at`

#### Task durumu guncelleme
- Zorunlu: `status`, `updated_at`
- Opsiyonel: `completed_at` (status `done` ise)

#### Shift goruntuleme
- Zorunlu: yok (read-only)

### Manager akislari

#### Task olusturma
- Zorunlu: `department_id`, `assigned_to_user_id`, `assigned_by_user_id`, `title`, `status`, `priority`, `created_at`, `updated_at`
- Opsiyonel: `description`, `due_date`

#### Shift olusturma
- Zorunlu: `department_id`, `user_id`, `start_at`, `end_at`, `shift_type`, `created_at`, `updated_at`
- Opsiyonel: `location`, `notes`

#### Request onay/ret
- Zorunlu (approvals): `reviewer_user_id`, `action`, `reviewed_at`
- Opsiyonel: `comment`
- Not: Onay/ret sonrasi `requests.status` guncellenir ve `updated_at` atilir

#### Department icin kullanici listeleme
- Zorunlu: yok (read-only)

### Admin akislari

#### Department olusturma
- Zorunlu: `name`, `manager_id`, `is_active`, `created_at`, `updated_at`
- Opsiyonel: `description`

#### User olusturma/aktiflik guncelleme
- Zorunlu: `full_name`, `email`, `role`, `department_id`, `manager_id`, `is_active`, `created_at`, `updated_at`
- Opsiyonel: `phone`, `last_login_at`

#### Audit log yazimi (sistem)
- Zorunlu: `actor_user_id`, `department_id`, `entity_type`, `entity_id`, `action`, `created_at`
- Opsiyonel: `metadata_json`

## 11) Firestore Security Rules taslagi (role + department)

Asagidaki taslak, `users/{uid}` dokumanindan role ve department bilgisini okur ve tum yazmalarda department uyumu zorunlu tutar.

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function userDoc() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid));
    }

    function role() {
      return userDoc().data.role;
    }

    function deptId() {
      return userDoc().data.department_id;
    }

    function isAdmin() {
      return role() == 'admin';
    }

    function isManager() {
      return role() == 'manager';
    }

    function isEmployee() {
      return role() == 'employee';
    }

    function sameDept(resourceDept) {
      return resourceDept == deptId();
    }

    // departments
    match /departments/{deptId} {
      allow read: if isSignedIn() && (isAdmin() || deptId == deptId());
      allow create, update, delete: if isSignedIn() && isAdmin();
    }

    // users
    match /users/{userId} {
      allow read: if isSignedIn() && (
        isAdmin() || userId == request.auth.uid || resource.data.department_id == deptId()
      );

      allow create, update: if isSignedIn() && (
        isAdmin() || (userId == request.auth.uid && request.resource.data.department_id == deptId())
      );

      allow delete: if isSignedIn() && isAdmin();
    }

    // tasks
    match /tasks/{taskId} {
      allow read: if isSignedIn() && (isAdmin() || resource.data.department_id == deptId());

      allow create: if isSignedIn() && (isAdmin() || isManager())
        && request.resource.data.department_id == deptId();

      allow update: if isSignedIn() && (
        isAdmin() || isManager() || request.auth.uid == resource.data.assigned_to_user_id
      ) && resource.data.department_id == deptId();

      allow delete: if isSignedIn() && (isAdmin() || isManager())
        && resource.data.department_id == deptId();
    }

    // shifts
    match /shifts/{shiftId} {
      allow read: if isSignedIn() && (isAdmin() || resource.data.department_id == deptId());

      allow create, update, delete: if isSignedIn() && (isAdmin() || isManager())
        && request.resource.data.department_id == deptId();
    }

    // requests
    match /requests/{requestId} {
      allow read: if isSignedIn() && (
        isAdmin() || resource.data.department_id == deptId()
      );

      allow create: if isSignedIn() && (
        isAdmin() || isEmployee() || isManager()
      ) && request.resource.data.department_id == deptId()
        && request.resource.data.created_by_user_id == request.auth.uid;

      allow update: if isSignedIn() && (
        isAdmin() || isManager() || request.auth.uid == resource.data.created_by_user_id
      ) && resource.data.department_id == deptId();

      allow delete: if isSignedIn() && isAdmin();

      match /attachments/{attachmentId} {
        allow read: if isSignedIn() && (isAdmin() || get(/databases/$(database)/documents/requests/$(requestId)).data.department_id == deptId());

        allow create: if isSignedIn() && (
          isAdmin() || request.auth.uid == request.resource.data.uploaded_by_user_id
        );

        allow delete: if isSignedIn() && (
          isAdmin() || request.auth.uid == request.resource.data.uploaded_by_user_id
        );
      }

      match /approvals/{approvalId} {
        allow read: if isSignedIn() && (isAdmin() || get(/databases/$(database)/documents/requests/$(requestId)).data.department_id == deptId());

        allow create: if isSignedIn() && (isAdmin() || isManager())
          && request.resource.data.reviewer_user_id == request.auth.uid;

        allow update, delete: if isSignedIn() && isAdmin();
      }
    }

    // audit_logs
    match /audit_logs/{logId} {
      allow read: if isSignedIn() && (isAdmin() || resource.data.department_id == deptId());
      allow create: if isSignedIn();
      allow update, delete: if false;
    }
  }
}
```

Notlar:
- Bu taslakta `users/{uid}` dokumani yoksa erisim reddedilir; ilk kurulum icin admin kullanici olusturma ihtiyaci vardir.
- `requests` guncellemede field-level kontrol yoktur; gerekiyorsa `request.resource.data.keys().hasOnly([...])` ile kisitlanabilir.
- `approvals` yazimi sonrasi `requests.status` guncellenir ve `updated_at` atilir (transaction/BatchWrite).

## 12) Isveren onboarding akisi (plan)

Amac: Login ekraninda "Isveren misiniz?" butonu ile ilk kurulum / kayit akisinin baslatilmasi. Ilk kayit ile admin kullanici + departman olusturulur ve ana ekrana yonlendirilir.

### Akis ozeti
1. Login ekraninda "Isveren misiniz?" butonu -> Isveren Kayit sayfasina gider.
2. Isveren kayit formu:
   - company_name (opsiyonel, ileride org koleksiyonu eklenebilir)
   - full_name, email, password
   - department_name (ilk departman)
   - phone (opsiyonel)
3. FirebaseAuth ile hesap olusturulur.
4. Firestore yazimlari (batch/transaction):
   - departments/{deptId} (ilk departman)
   - users/{uid} (role=admin, department_id=deptId)
   - audit_logs/{logId} (bootstrap kaydi)
5. Session yuklenir ve admin dashboard'a yonlendirilir.

### Kurallar / guvenlik
- Bootstrap icin sinirli bir allowlist gerekir:
  - users/{uid} create: sadece kendi uid ve role=admin ise (ilk kayit)
  - departments create: sadece ayni requestteki admin tarafindan (ilk kurulum)
- Ilk kurulum tamamlandiktan sonra normal kurallar devrede kalir.
- Opsiyonel: "setup_done" flagi ile tekrarli bootstrap engellenir.

### UI ve sayfalar
- LoginPage: "Isveren misiniz?" butonu.
- EmployerSignupPage: kayit formu + validasyon.
- Basarili kayit sonrasi otomatik login + yonlendirme.

### Gerekli eklemeler
- Yeni route: `/employer-signup`
- Yeni form ve controller/usecase
- Firestore yazimlari icin repository methodu (createEmployerAccount)
- Rules guncellemesi (bootstrap allowlist)

### Riskler / notlar
- Rule tarafinda "ilk admin" kriteri net degilse acik kapisi olabilir.
- Minimum kurulum icin tek admin, tek departman mantigi.
- Ileride `organizations` koleksiyonu eklenirse bu akis oraya tasinir.

## 13) Hiyerarşi ve Kullanıcı Görünürlüğü (Admin/Manager Filtreleme)

Çoklu admin yapısında kullanıcıların birbirine karışmaması için aşağıdaki hiyerarşik yapı uygulanır:

### Görünürlük Kuralları
1.  **Adminler:** Sadece kendi oluşturdukları veya kendilerine bağlı olan kullanıcıları (`manager_id` alanı kendi `uid`'leri olanlar) görebilirler.
2.  **Managerlar:** Sadece kendi departmanlarındaki (`department_id` eşleşen) kullanıcıları görebilirler.
3.  **Sistem Geneli:** Adminler, diğer adminleri veya başka adminlere bağlı kullanıcıları göremezler.

### Veri Yapısı Güncellemeleri
-   `users` koleksiyonundaki her dokümanda `manager_id` alanı zorunludur.
-   Bir admin kullanıcı oluşturulduğunda, bu adminin `uid`'si, oluşturulan kullanıcının `manager_id` alanına yazılır.

### Kod Uygulaması (Presentation Layer)
-   `users_admin_page.dart` içinde `StreamBuilder` kullanılırken, oturum açmış kullanıcının `uid` ve `role` bilgisine göre Firestore sorgusu filtrelenir:
    -   Admin ise: `.where('manager_id', isEqualTo: currentUserUid)`
    -   Manager ise: `.where('department_id', isEqualTo: currentUserDeptId)`

### Firestore Rules Güncellemesi
```rules
match /users/{userId} {
  allow read: if isSignedIn() && (
    isAdmin() && (resource.data.manager_id == request.auth.uid || userId == request.auth.uid) ||
    isManager() && resource.data.department_id == deptId() ||
    userId == request.auth.uid
  );
}
```
