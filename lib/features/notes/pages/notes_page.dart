import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/note_list_item.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'الملاحظات',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppButton(
            label: 'إضافة ملاحظة',
            icon: Icons.note_add_outlined,
            onPressed: _openCreate,
          ),
        ),
      ],
      body: GetBuilder<NotesController>(
        id: NotesController.listId,
        builder: (controller) {
          if (controller.isLoading && controller.notes.isEmpty) {
            return const AppLoader(message: 'جاري تحميل الملاحظات...');
          }

          if (controller.errorMessage != null && controller.notes.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.loadNotes,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'بحث بالعنوان أو التفاصيل أو الجهة...',
                  hintStyle: AppTextStyles.body2,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.filteredNotes.length} ملاحظة',
                      style: AppTextStyles.body2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'تحديث',
                    onPressed: controller.loadNotes,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: controller.notes.isEmpty
                    ? AppEmptyState(
                        title: 'لا توجد ملاحظات',
                        subtitle: 'أضف ملاحظة جديدة للعملاء أو التجار أو الشحن',
                        icon: Icons.sticky_note_2_outlined,
                        actionLabel: 'إضافة ملاحظة',
                        onAction: _openCreate,
                      )
                    : controller.filteredNotes.isEmpty
                        ? const AppEmptyState(
                            title: 'لا نتائج',
                            subtitle: 'جرّب كلمات بحث أخرى',
                            icon: Icons.search_off,
                          )
                        : ListView.separated(
                            itemCount: controller.filteredNotes.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              return NoteListItem(
                                note: controller.filteredNotes[index],
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreate() async {
    final controller = Get.find<NotesController>();
    controller.prepareCreate();
    await Get.dialog<bool>(
      const NoteFormDialog(),
      barrierDismissible: false,
    );
  }
}
