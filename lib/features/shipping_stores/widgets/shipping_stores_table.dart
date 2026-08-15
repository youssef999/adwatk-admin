import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/maps_launcher.dart';
import '../../../core/utils/storage_url.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/media/app_network_image.dart';
import '../controllers/shipping_stores_controller.dart';
import '../models/shippiment_store_model.dart';
import 'shipping_finance_dialog.dart';
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
            dataRowMinHeight: 80,
            dataRowMaxHeight: 96,
            columns: const [
              DataColumn(label: Text('المتجر', style: AppTextStyles.h6)),
              DataColumn(label: Text('البريد', style: AppTextStyles.h6)),
              DataColumn(label: Text('المحفظة', style: AppTextStyles.h6)),
              DataColumn(label: Text('حد السالب', style: AppTextStyles.h6)),
              DataColumn(label: Text('المركبة', style: AppTextStyles.h6)),
              DataColumn(label: Text('السائق', style: AppTextStyles.h6)),
              DataColumn(label: Text('رقم مميز', style: AppTextStyles.h6)),
              DataColumn(label: Text('الموقع', style: AppTextStyles.h6)),
              DataColumn(label: Text('إجراءات', style: AppTextStyles.h6)),
            ],
            rows: stores.map((store) {
              final balance = controller.walletAmountFor(store);
              final minAlert = controller.minWalletAlertFor(store);
              final vehicleMeta = [
                if (store.vehicleType.trim().isNotEmpty) store.vehicleType,
                if (store.vehicleSizeType.trim().isNotEmpty)
                  store.vehicleSizeType,
              ].join(' · ');
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        _Avatar(url: store.profileImageUrl, name: store.name),
                        const SizedBox(width: AppSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name.isEmpty ? '—' : store.name,
                                style: AppTextStyles.body1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                store.profileId.isEmpty
                                    ? '—'
                                    : store.profileId,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(store.email, style: AppTextStyles.body2)),
                  DataCell(
                    Text(
                      _formatAmount(balance),
                      style: AppTextStyles.body2.copyWith(
                        color: balance < 0
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      minAlert == null
                          ? '—'
                          : minAlert == 0
                              ? 'مقيد (0)'
                              : _formatAmount(minAlert),
                      style: AppTextStyles.body2.copyWith(
                        color: minAlert == 0
                            ? AppColors.error
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        _Avatar(
                          url: store.vehicleImageUrl,
                          name: store.vehicleName.isEmpty
                              ? store.name
                              : store.vehicleName,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.vehicleName.isEmpty
                                    ? '—'
                                    : store.vehicleName,
                                style: AppTextStyles.body2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                vehicleMeta.isEmpty ? '—' : vehicleMeta,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.info,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      store.vehicleDriverName.isEmpty
                          ? '—'
                          : store.vehicleDriverName,
                      style: AppTextStyles.body2,
                    ),
                  ),
                  DataCell(
                    Text(
                      store.vehicleDistinctiveNumber.isEmpty
                          ? '—'
                          : store.vehicleDistinctiveNumber,
                      style: AppTextStyles.body2,
                    ),
                  ),
                  DataCell(
                    store.hasLocation
                        ? TextButton.icon(
                            onPressed: () => MapsLauncher.openLatLng(
                              lat: store.lat!,
                              lng: store.lng!,
                            ),
                            icon: const Icon(
                              Icons.map_outlined,
                              size: AppIconSize.sm,
                            ),
                            label: Text(
                              '${store.lat!.toStringAsFixed(4)}, '
                              '${store.lng!.toStringAsFixed(4)}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text('—', style: AppTextStyles.caption),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'إرسال إشعار',
                          onPressed: () =>
                              controller.openSendNotification(store),
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            size: AppIconSize.md,
                          ),
                          color: AppColors.primary,
                        ),
                        IconButton(
                          tooltip: 'المحفظة والحد الأقصى',
                          onPressed: () => _openFinance(controller, store),
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.success,
                          ),
                        ),
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

  String _formatAmount(num value) {
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$text د.ع';
  }

  Future<void> _openFinance(
    ShippingStoresController controller,
    ShippimentStoreModel store,
  ) async {
    controller.prepareFinance(store);
    await Get.dialog<bool>(
      const ShippingFinanceDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openEdit(
    ShippingStoresController controller,
    ShippimentStoreModel store,
  ) async {
    await controller.prepareEdit(store);
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
    final balance = controller.walletAmountFor(store);
    final minAlert = controller.minWalletAlertFor(store);
    final vehicleMeta = [
      if (store.vehicleType.trim().isNotEmpty) store.vehicleType,
      if (store.vehicleSizeType.trim().isNotEmpty) store.vehicleSizeType,
      if (store.vehicleDistinctiveNumber.trim().isNotEmpty)
        '#${store.vehicleDistinctiveNumber}',
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'المحفظة: ${_formatAmount(balance)}',
                      style: AppTextStyles.caption.copyWith(
                        color:
                            balance < 0 ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      minAlert == null
                          ? 'الحد الأقصى في السالب: —'
                          : minAlert == 0
                              ? 'الرصيد السالب: مقيد (حد = 0)'
                              : 'الحد الأقصى في السالب: ${_formatAmount(minAlert)}',
                      style: AppTextStyles.caption.copyWith(
                        color: minAlert == 0
                            ? AppColors.error
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Avatar(
                url: store.vehicleImageUrl,
                name: store.vehicleName.isEmpty ? 'V' : store.vehicleName,
                size: 40,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.vehicleName.isEmpty
                          ? 'مركبة غير محددة'
                          : store.vehicleName,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (store.vehicleDriverName.trim().isNotEmpty)
                      Text(
                        'السائق: ${store.vehicleDriverName}',
                        style: AppTextStyles.caption,
                      ),
                    Text(
                      vehicleMeta.isEmpty ? '—' : vehicleMeta,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (store.hasLocation)
                IconButton(
                  tooltip: 'فتح على خرائط جوجل',
                  onPressed: () => MapsLauncher.openLatLng(
                    lat: store.lat!,
                    lng: store.lng!,
                  ),
                  icon: const Icon(Icons.map_outlined),
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Spacer(),
              IconButton(
                tooltip: 'المحفظة والحد الأقصى',
                onPressed: () async {
                  controller.prepareFinance(store);
                  await Get.dialog<bool>(
                    const ShippingFinanceDialog(),
                    barrierDismissible: false,
                  );
                },
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.success,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await controller.prepareEdit(store);
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
                      title: const Text(
                        'حذف متجر الشحن',
                        style: AppTextStyles.h5,
                      ),
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
        ],
      ),
    );
  }

  String _formatAmount(num value) {
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$text د.ع';
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
