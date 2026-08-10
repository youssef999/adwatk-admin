import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../buttons/app_button.dart';

class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({
    super.key,
    required this.recipientLabel,
    required this.hasFcmToken,
    required this.onSend,
  });

  final String recipientLabel;
  final bool hasFcmToken;
  final Future<bool> Function(String title, String body) onSend;

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    final ok = await widget.onSend(
      _titleController.text,
      _bodyController.text,
    );
    if (!mounted) return;
    if (ok) {
      Get.back(result: true);
      return;
    }
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('إرسال إشعار', style: AppTextStyles.h5),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'إلى: ${widget.recipientLabel}',
                style: AppTextStyles.body2,
              ),
              if (!widget.hasFcmToken) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'تحذير: لا يوجد FCM token — سيتم حفظ الإشعار فقط بدون Push.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'عنوان الإشعار',
                ),
                textInputAction: TextInputAction.next,
                enabled: !_isSending,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'النص',
                  hintText: 'محتوى الإشعار',
                ),
                minLines: 3,
                maxLines: 5,
                enabled: !_isSending,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'إلغاء',
                      variant: AppButtonVariant.outlined,
                      onPressed: _isSending ? null : () => Get.back(result: false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'إرسال',
                      icon: Icons.send_outlined,
                      isLoading: _isSending,
                      onPressed: _isSending ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
