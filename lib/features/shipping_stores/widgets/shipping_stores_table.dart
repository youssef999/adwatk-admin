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
    return ListView.separated(
      itemCount: stores.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return ShippingStoreListCard(store: stores[index]);
      },
    );
  }
}

/// بطاقة متجر على صفين: هوية/محفظة ثم مركبة/موقع — بدون سكرول أفقي.
class ShippingStoreListCard extends StatelessWidget {
  const ShippingStoreListCard({super.key, required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShippingStoresController>();
    final balance = controller.walletAmountFor(store);
    final minAlert = controller.minWalletAlertFor(store);
    final vehicleMeta = [
      if (store.vehicleType.trim().isNotEmpty) store.vehicleType,
      if (store.vehicleSizeType.trim().isNotEmpty) store.vehicleSizeType,
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصف 1 — المتجر + المحفظة + الإجراءات
              if (compact)
                _CompactIdentityRow(
                  store: store,
                  balance: balance,
                  minAlert: minAlert,
                  controller: controller,
                )
              else
                _WideIdentityRow(
                  store: store,
                  balance: balance,
                  minAlert: minAlert,
                  controller: controller,
                ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: AppSpacing.md),
              // الصف 2 — المركبة + السائق + الرقم + الموقع
              if (compact)
                _CompactVehicleRow(store: store, vehicleMeta: vehicleMeta)
              else
                _WideVehicleRow(store: store, vehicleMeta: vehicleMeta),
            ],
          );
        },
      ),
    );
  }
}

class ShippingStoreMobileCard extends StatelessWidget {
  const ShippingStoreMobileCard({super.key, required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    return ShippingStoreListCard(store: store);
  }
}

class _WideIdentityRow extends StatelessWidget {
  const _WideIdentityRow({
    required this.store,
    required this.balance,
    required this.minAlert,
    required this.controller,
  });

  final ShippimentStoreModel store;
  final num balance;
  final num? minAlert;
  final ShippingStoresController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                store.email.isEmpty ? '—' : store.email,
                style: AppTextStyles.body2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (store.profileId.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  store.profileId,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _FinanceChip(
          label: 'المحفظة',
          value: _formatAmount(balance),
          color: balance < 0 ? AppColors.error : AppColors.success,
        ),
        const SizedBox(width: AppSpacing.sm),
        _FinanceChip(
          label: 'حد السالب',
          value: _minAlertLabel(minAlert),
          color: minAlert == 0 ? AppColors.error : AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.sm),
        _ActionButtons(store: store, controller: controller),
      ],
    );
  }
}

class _CompactIdentityRow extends StatelessWidget {
  const _CompactIdentityRow({
    required this.store,
    required this.balance,
    required this.minAlert,
    required this.controller,
  });

  final ShippimentStoreModel store;
  final num balance;
  final num? minAlert;
  final ShippingStoresController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    store.email.isEmpty ? '—' : store.email,
                    style: AppTextStyles.body2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (store.profileId.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      store.profileId,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            _ActionButtons(store: store, controller: controller),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _FinanceChip(
              label: 'المحفظة',
              value: _formatAmount(balance),
              color: balance < 0 ? AppColors.error : AppColors.success,
            ),
            _FinanceChip(
              label: 'حد السالب',
              value: _minAlertLabel(minAlert),
              color: minAlert == 0 ? AppColors.error : AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _WideVehicleRow extends StatelessWidget {
  const _WideVehicleRow({
    required this.store,
    required this.vehicleMeta,
  });

  final ShippimentStoreModel store;
  final String vehicleMeta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(
          url: store.vehicleImageUrl,
          name: store.vehicleName.isEmpty ? 'V' : store.vehicleName,
          size: 40,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: _MetaBlock(
            title: store.vehicleName.isEmpty
                ? 'مركبة غير محددة'
                : store.vehicleName,
            subtitle: vehicleMeta.isEmpty ? '—' : vehicleMeta,
          ),
        ),
        Expanded(
          child: _MetaBlock(
            title: 'السائق',
            subtitle: store.vehicleDriverName.isEmpty
                ? '—'
                : store.vehicleDriverName,
          ),
        ),
        Expanded(
          child: _MetaBlock(
            title: 'رقم مميز',
            subtitle: store.vehicleDistinctiveNumber.isEmpty
                ? '—'
                : store.vehicleDistinctiveNumber,
          ),
        ),
        _LocationButton(store: store),
      ],
    );
  }
}

class _CompactVehicleRow extends StatelessWidget {
  const _CompactVehicleRow({
    required this.store,
    required this.vehicleMeta,
  });

  final ShippimentStoreModel store;
  final String vehicleMeta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Avatar(
              url: store.vehicleImageUrl,
              name: store.vehicleName.isEmpty ? 'V' : store.vehicleName,
              size: 40,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetaBlock(
                title: store.vehicleName.isEmpty
                    ? 'مركبة غير محددة'
                    : store.vehicleName,
                subtitle: vehicleMeta.isEmpty ? '—' : vehicleMeta,
              ),
            ),
            _LocationButton(store: store),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MetaBlock(
                title: 'السائق',
                subtitle: store.vehicleDriverName.isEmpty
                    ? '—'
                    : store.vehicleDriverName,
              ),
            ),
            Expanded(
              child: _MetaBlock(
                title: 'رقم مميز',
                subtitle: store.vehicleDistinctiveNumber.isEmpty
                    ? '—'
                    : store.vehicleDistinctiveNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationButton extends StatelessWidget {
  const _LocationButton({required this.store});

  final ShippimentStoreModel store;

  @override
  Widget build(BuildContext context) {
    if (!store.hasLocation) {
      return Text('بدون موقع', style: AppTextStyles.caption);
    }

    return TextButton.icon(
      onPressed: () => MapsLauncher.openLatLng(
        lat: store.lat!,
        lng: store.lng!,
      ),
      icon: const Icon(Icons.map_outlined, size: AppIconSize.sm),
      label: Text(
        '${store.lat!.toStringAsFixed(4)}, ${store.lng!.toStringAsFixed(4)}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FinanceChip extends StatelessWidget {
  const _FinanceChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.info),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.store,
    required this.controller,
  });

  final ShippimentStoreModel store;
  final ShippingStoresController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'إرسال إشعار',
          onPressed: () => controller.openSendNotification(store),
          icon: const Icon(
            Icons.notifications_active_outlined,
            size: AppIconSize.md,
          ),
          color: AppColors.primary,
        ),
        IconButton(
          tooltip: 'المحفظة والحد الأقصى',
          onPressed: () => _openFinance(),
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.success,
          ),
        ),
        IconButton(
          tooltip: 'تعديل',
          onPressed: () => _openEdit(),
          icon: const Icon(Icons.edit_outlined, size: AppIconSize.md),
          color: AppColors.info,
        ),
        IconButton(
          tooltip: 'حذف',
          onPressed: () => _confirmDelete(),
          icon: const Icon(Icons.delete_outline, size: AppIconSize.md),
          color: AppColors.error,
        ),
      ],
    );
  }

  Future<void> _openFinance() async {
    controller.prepareFinance(store);
    await Get.dialog<bool>(
      const ShippingFinanceDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _openEdit() async {
    await controller.prepareEdit(store);
    await Get.dialog<bool>(
      const ShippingStoreFormDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> _confirmDelete() async {
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

String _formatAmount(num value) {
  final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
  return '$text د.ع';
}

String _minAlertLabel(num? minAlert) {
  if (minAlert == null) return '—';
  if (minAlert == 0) return 'مقيد (0)';
  return _formatAmount(minAlert);
}
