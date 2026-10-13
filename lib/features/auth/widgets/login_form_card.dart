import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/branding/app_logo.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AutofillGroup(
        child: GetBuilder<AuthController>(
          id: AuthController.formId,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(variant: AppLogoVariant.full, height: 88, showTagline: true),
              const SizedBox(height: AppSpacing.lg),
              Text(
                controller.loginAsModerator
                    ? 'تسجيل دخول المشرفين'
                    : 'تسجيل دخول الإدارة',
                textAlign: TextAlign.center,
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                controller.loginAsModerator
                    ? 'حساب مشرف الشحن الذي أنشأه الأدمن.'
                    : 'هذه اللوحة مخصصة لحسابات الأدمن والمشرفين.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'البريد الإلكتروني',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !controller.isSubmitting,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'كلمة المرور',
                controller: controller.passwordController,
                obscureText: controller.obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !controller.isSubmitting,
                onSubmitted: (_) => controller.signIn(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: AppIconSize.md,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CheckboxListTile(
                value: controller.loginAsModerator,
                onChanged: controller.isSubmitting
                    ? null
                    : controller.setLoginAsModerator,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text('دخول كمشرف', style: AppTextStyles.body1),
                subtitle: Text(
                  'للمشرفين على المندوبين والشحن',
                  style: AppTextStyles.caption,
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ErrorBanner(message: controller.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'دخول',
                icon: Icons.login,
                isExpanded: true,
                isLoading: controller.isSubmitting,
                onPressed: controller.signIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: AppIconSize.md, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body2.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
