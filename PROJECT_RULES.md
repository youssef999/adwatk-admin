# قواعد المشروع — Flutter Web Admin Dashboard

هذا الملف هو المرجع الرسمي لأي AI Agent (Claude Code / Cursor / غيره) يعمل على هذا المشروع.
الهدف: **لوحة تحكم Flutter Web احترافية، سريعة، متسقة بصريًا، ومنظمة الكود** — لا تعمل أي مهمة قبل قراءة هذا الملف بالكامل.

---

## 0) المبدأ العام

- لا تُنفّذ أي شاشة أو feature قبل التأكد من الالتزام بـ **نظام التصميم (Design System)** الموحّد أدناه.
- لا تخترع ألوانًا أو مقاسات أو Widgets جديدة عشوائيًا — استخدم ما هو معرّف في `lib/core/theme` و`lib/core/constants`.
- الأولوية دائمًا: **الأداء (Performance) > الاتساق البصري (Consistency) > سرعة الإنجاز**.
- لا تفترض متطلبات غير مذكورة. إذا كانت هناك ميزة غير واضحة، اسأل أو اكتب TODO بدل الافتراض العشوائي.
- كل feature تُبنى تدريجيًا: **Design tokens → Models → Controller → Widgets الصغيرة → تجميعها في Page**. لا تقفز مباشرة لكتابة صفحة كاملة دفعة واحدة.

---

## 1) نظام التصميم (Design System) — إلزامي قبل أي UI

يجب إنشاء/الحفاظ على الملفات التالية كمصدر وحيد للحقيقة (Single Source of Truth):

```
lib/core/theme/
  app_colors.dart
  app_text_styles.dart
  app_spacing.dart
  app_radius.dart
  app_icons.dart
  app_theme.dart   // ThemeData الكامل (Light/Dark)
```

### 1.1 الألوان (Colors)
- تعريف كامل داخل `AppColors` (class ثابت static const) يشمل:
  - `primary`, `primaryLight`, `primaryDark`
  - `secondary`
  - `background`, `surface`, `card`
  - `success`, `warning`, `error`, `info`
  - `textPrimary`, `textSecondary`, `textDisabled`
  - `border`, `divider`, `shadow`
  - نسخة كاملة لـ **Dark Mode** بنفس الأسماء (لا تكرار منطق الألوان داخل الـ Widgets).
- **ممنوع** كتابة `Color(0xFF...)` مباشرة داخل أي Widget. كل لون يُستدعى من `AppColors`.

### 1.2 المقاسات (Spacing & Sizing)
- نظام spacing موحّد بمضاعفات ثابتة (4/8 scale مثلاً):
  ```dart
  class AppSpacing {
    static const xs = 4.0;
    static const sm = 8.0;
    static const md = 16.0;
    static const lg = 24.0;
    static const xl = 32.0;
    static const xxl = 48.0;
  }
  ```
- نظام Radius موحّد: `AppRadius.sm / md / lg / full`.
- Typography scale موحّد عبر `AppTextStyles` (h1..h6, body1, body2, caption, button) — لا تستخدم `TextStyle` inline إلا لحالات استثنائية موثّقة.
- **ممنوع** كتابة أرقام padding/margin عشوائية (`EdgeInsets.all(13)`) — استخدم `AppSpacing`.

### 1.3 الأيقونات (Icons)
- استخدم مجموعة أيقونات واحدة فقط في كل المشروع (حدد مسبقًا: Material Icons أو مجموعة icon pack واحدة مثل `lucide_icons` أو `phosphor_flutter`) — **لا تخلط بين أكثر من مصدر أيقونات**.
- أحجام الأيقونات موحّدة عبر ثوابت: `AppIconSize.sm (16) / md (20) / lg (24) / xl (32)`.

### 1.4 المكوّنات الأساسية المشتركة (Shared UI Kit)
قبل بناء أي صفحة، تأكد من وجود مكتبة widgets أساسية مُعاد استخدامها في كل مكان:
```
lib/shared/widgets/
  buttons/       (AppButton, IconButton variants)
  inputs/        (AppTextField, AppDropdown, AppSearchField)
  cards/         (AppCard, StatCard, ChartCard)
  tables/        (AppDataTable)
  feedback/      (AppLoader, AppEmptyState, AppErrorState, AppSnackbar)
  layout/        (AppScaffold, Sidebar, TopBar, ResponsiveWrapper)
```
لا تعيد بناء زر أو حقل إدخال جديد من الصفر داخل صفحة — استخدم/طوّر المكوّن المشترك.

---

## 2) إدارة الحالة — GetX (قاعدة صارمة)

- المكتبة: **GetX**، لكن بأسلوب **Imperative** فقط:
  - استخدم `GetBuilder<Controller>` + `update()`.
  - **ممنوع نهائيًا**:
    - `.obs`
    - `Obx(...)`
    - `GetX<Controller>(...)` widget
    - أي reactive state داخل شجرة الـ widgets
  - عند تحديث الحالة داخل الـ Controller، استدعِ `update()` (أو `update(['id'])` لتحديث جزء محدد فقط باستخدام `id` في `GetBuilder`).
- كل Controller يرث من `GetxController` ويوضع في:
  ```
  lib/features/<feature_name>/controllers/<feature>_controller.dart
  ```
- الحقن يتم عبر `Get.lazyPut()` داخل `Binding` مخصص لكل feature (`<feature>_binding.dart`) — لا تستخدم `Get.put()` مباشرة داخل الـ UI.
- لا تضع Business logic أو API calls داخل الـ Widgets — كل ذلك في الـ Controller أو Service/Repository.
- استخدم `id` في `GetBuilder` لتقليل rebuild غير الضروري عند التحديثات الجزئية (مثال: تحديث صف واحد في جدول بدل الجدول كامل).

---

## 3) هيكلة المشروع (Project Structure)

```
lib/
  core/
    theme/
    constants/
    utils/
    routes/
    network/           // dio client, interceptors
    errors/
  shared/
    widgets/
    models/
  features/
    dashboard/
      controllers/
      models/
      widgets/
      pages/
      bindings/
    users/
      ...
  main.dart
```

- كل feature معزول في مجلده الخاص (Feature-first architecture)، وليس Layer-first عام.
- الملفات المشتركة فقط توضع في `shared/`.

---

## 4) قواعد بناء الـ Widgets (مهم جدًا)

- **لا تكتب صفحة كاملة كـ Widget واحد ضخم.** قسّم الصفحة منطقيًا (مثال: Header, StatsRow, ChartSection, RecentActivityTable) كل قسم Widget منفصل.
- **لكن أيضًا لا تُفرط في التقسيم.** لا تنشئ ملف منفصل لكل عنصر صغير تافه (مثل نص واحد أو أيقونة واحدة). اجمع العناصر المترابطة منطقيًا في نفس الـ Widget طالما حجمه معقول (إرشاد تقريبي: لا يتجاوز ~150–200 سطر للـ Widget الواحد).
- القاعدة الذهبية: **"كل ما يُستخدم أو يتغيّر معًا، يوضع معًا. كل ما هو قابل لإعادة الاستخدام في مكان آخر، يُفصل."**
- لا تضع كل الـ widgets الفرعية لصفحة داخل ملف الصفحة نفسه — كل Widget مستقل منطقيًا (أكبر من عنصر تافه) في ملفه الخاص داخل `features/<feature>/widgets/`.
- استخدم `const` constructors في كل مكان ممكن لتقليل الـ rebuilds.

---

## 5) الاستجابة والتخطيط (Responsive Layout)

- Dashboard يجب أن يعمل بشكل صحيح على: Desktop (≥1200), Tablet (600–1199), Mobile (<600) — استخدم `LayoutBuilder` / breakpoints موحّدة من `core/constants/breakpoints.dart`.
- Sidebar قابل للطي (collapsible) على الشاشات الصغيرة.
- الجداول تتحول لعرض بطاقات (cards) على الموبايل عند الحاجة.

---

## 6) الأداء (Flutter Web Performance)

- تجنّب rebuild الشجرة كاملة — استفد من `GetBuilder` + `id` كما سبق.
- استخدم `ListView.builder` / `DataTable2` أو مكافئ lazy-loading للقوائم/الجداول الكبيرة، وليس `Column` مع map.
- الصور: استخدم `cached_network_image` مع تحديد أحجام واضحة لتفادي layout shift.
- تفعيل `--wasm` أو `CanvasKit` حسب متطلبات المشروع (يُحدَّد لاحقًا) — لا تفترض.

---

## 7) قواعد التسمية (Naming Conventions)

- Files: `snake_case.dart`
- Classes/Widgets: `PascalCase`
- Variables/functions: `camelCase`
- Controllers: `<Feature>Controller`
- Models: `<Entity>Model`
- Constants: `UPPER_SNAKE_CASE` أو `camelCase` ثابت حسب النوع (اتفق على نمط واحد فقط والتزم به).

---

## 8) أسلوب عمل الـ Agent (Workflow)

1. اقرأ هذا الملف بالكامل قبل أي تعديل.
2. عند إضافة feature جديدة: ابدأ بـ Model → Repository/Service → Controller → Widgets الصغيرة → Page → Binding → Route.
3. لا تُنشئ كميات كبيرة من الملفات دفعة واحدة بدون داعٍ — أنشئ فقط ما هو مطلوب فعليًا للمهمة الحالية.
4. عند التعديل على Widget موجود، حافظ على نفس نمط الكود والتسمية المستخدم في المشروع، ولا تعيد كتابته بأسلوب مختلف.
5. إذا كانت المهمة تتطلب قرار تصميم غير معرّف (لون جديد، مقاس جديد)، أضِفه أولًا إلى `core/theme` ثم استخدمه — لا تكتبه inline.
6. لا تحذف أو تُعدّل كودًا خارج نطاق المهمة المطلوبة دون تنويه صريح.

---

## ملاحظة أخيرة
هذه القواعد ثابتة وتُطبَّق على كل الميزات القادمة في هذا المشروع (لوحة الإحصائيات، إدارة المستخدمين، الجداول، التقارير... إلخ) والتي سيتم تفصيلها لاحقًا. أي كود جديد يجب أن يكون متسقًا 100% مع هذا النظام.
