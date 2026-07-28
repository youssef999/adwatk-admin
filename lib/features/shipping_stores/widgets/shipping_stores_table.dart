import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../controllers/shipping_stores_controller.dart';
import '../models/shippiment_store_model.dart';
import 'shipping_store_form_dialog.dart';

class ShippingStoresTable extends StatelessWidget {
  const ShippingStoresTable({super.key, required this.stores});

  final List<ShippimentStoreModel> stores;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShippingStoresController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width - 320,
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.background,
            ),
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            columns: const [
              DataColumn(label: Text('المتجر', style: AppTextStyles.h6)),
              DataColumn(label: Text('البريد', style: AppTextStyles.h6)),
              DataColumn(label: Text('profileId', style: AppTextStyles.h6)),
              DataColumn(label: Text('التقييم', style: AppTextStyles.h6)),
              DataColumn(label: Text('حجم المركبة', style: AppTextStyles.h6)),
              DataColumn(label: Text('تاريخ الإنشاء', style: AppTextStyles.h6)),
              DataColumn(label: Text('إجراءات', style: AppTextStyles.h6)),
            ],
            rows: stores.map((store) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        _Avatar(url: store.profileImageUrl, name: store.name),
                        const SizedBox(width: AppSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            store.name.isEmpty ? '—' : store.name,
                            style: AppTextStyles.body1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(store.email, style: AppTextStyles.body2)),
                  DataCell(Text(store.profileId, style: AppTextStyles.caption)),
                  DataCell(
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: AppIconSize.sm,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('${store.rate}', style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        store.vehicleSizeType.isEmpty
                            ? '—'
                            : store.vehicleSizeType,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      DateFormatUtils.format(store.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'تعديل',
                          onPressed: () => _openEdit(controller, store),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: AppIconSize.md,
                          ),
                          color: AppColors.info,
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () => _confirmDelete(controller, store),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: AppIconSize.md,
                          ),
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(
    ShippingStoresController controller,
    ShippimentStoreModel store,
  ) async {
    controller.prepareEdit(store);
    await Get.dialog<bool>(
      const ShippingStoreFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete(
    ShippingStoresController controller,
    ShippimentStoreModel store,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف متجر الشحن', style: AppTextStyles.h5),
        content: Text(
          'هل تريد حذف "${store.name}"؟',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'حذف',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteStore(store);
    }
  }
}

class ShippingStoreMobileCard extends StatelessWidget {
  const ShippingStoreMobileCard({super.key, required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShippingStoresController>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(url: store.profileImageUrl, name: store.name, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name.isEmpty ? '—' : store.name,
                  style: AppTextStyles.h6,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(store.email, style: AppTextStyles.body2),
                const SizedBox(height: AppSpacing.xs),
                Text(store.profileId, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: AppIconSize.sm,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('${store.rate}', style: AppTextStyles.caption),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      store.vehicleSizeType,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              controller.prepareEdit(store);
              await Get.dialog<bool>(
                const ShippingStoreFormDialog(),
                barrierDismissible: false,
              );
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.info),
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('حذف متجر الشحن', style: AppTextStyles.h5),
                  content: Text(
                    'هل تريد حذف "${store.name}"؟',
                    style: AppTextStyles.body2,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        'حذف',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await controller.deleteStore(store);
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.name,
    this.size = 40,
  });

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: size,
        height: size,
        child: !StorageUrl.isUsable(url)
            ? Container(
                color: AppColors.info.withValues(alpha: 0.12),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name.characters.first : '?',
                  style: AppTextStyles.h6.copyWith(color: AppColors.info),
                ),
              )
            : AppNetworkImage(
                url: url,
                fit: BoxFit.cover,
                memCacheWidth: 96,
                errorWidget: Container(
                  color: AppColors.background,
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
      ),
    );
  }
}
