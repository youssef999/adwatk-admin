import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../shared/widgets/feedback/app_error_state.dart';
import '../../../shared/widgets/feedback/app_loader.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../controllers/moderators_controller.dart';
import '../models/moderator_model.dart';
import '../widgets/moderator_form_dialog.dart';
import '../widgets/moderator_list_item.dart';

class ModeratorsPage extends StatelessWidget {
  const ModeratorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'المشرفون',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppButton(
            label: 'إضافة مشرف',
            icon: Icons.add,
            onPressed: _openCreate,
          ),
        ),
      ],
      body: GetBuilder<ModeratorsController>(
        id: ModeratorsController.listId,
        builder: (controller) {
          if (controller.isLoading && controller.moderators.isEmpty) {
            return const AppLoader(message: 'جاري تحميل المشرفين...');
          }

          if (controller.errorMessage != null &&
              controller.moderators.isEmpty) {
            return AppErrorState(
              message: controller.errorMessage!,
              onRetry: controller.listen,
            );
          }

          if (controller.moderators.isEmpty) {
            return AppEmptyState(
              title: 'لا يوجد مشرفون',
              subtitle: 'أضف مشرف شحن ليتابع المندوبين ومحافظ الشحن',
              icon: Icons.admin_panel_settings_outlined,
              actionLabel: 'إضافة مشرف',
              onAction: _openCreate,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${controller.moderators.length} مشرف — يرون أقسام الشحن فقط',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.moderators.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final moderator = controller.moderators[index];
                    return ModeratorListItem(
                      moderator: moderator,
                      isToggling: controller.togglingId == moderator.id,
                      onEdit: () => _openEdit(moderator),
                      onToggleActive: () => controller.toggleActive(moderator),
                      onDelete: () => controller.confirmDelete(moderator),
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
    Get.find<ModeratorsController>().prepareCreate();
    await Get.dialog<bool>(
      const ModeratorFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openEdit(ModeratorModel moderator) async {
    Get.find<ModeratorsController>().prepareEdit(moderator);
    await Get.dialog<bool>(
      const ModeratorFormDialog(),
      barrierDismissible: false,
    );
  }
}
