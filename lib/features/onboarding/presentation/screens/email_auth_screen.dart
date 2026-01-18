import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/premium_button.dart';
import '../../../../presentation/widgets/premium_text_field.dart';

/// Premium email authentication screen for sign in and sign up
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({
    super.key,
    this.isSignUp = false,
  });

  final bool isSignUp;

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late bool _isSignUp;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Listen to auth state changes
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      next.whenData((state) {
        if (state is AuthAuthenticated) {
          context.go(Routes.personalization);
        } else if (state is AuthError) {
          _showErrorSnackBar(context, state.failure.message);
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(theme, l10n),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme, l10n),
                const SizedBox(height: AppDimensions.spacingXL),
                _buildFormFields(l10n),
                const SizedBox(height: AppDimensions.spacingMD),
                _buildSubmitButton(l10n),
                const SizedBox(height: AppDimensions.spacingLG),
                _buildToggleButton(theme, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
        tooltip: l10n.back,
      ),
      title: Text(
        _isSignUp ? l10n.createAccount : l10n.signIn,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isSignUp ? Icons.person_add_outlined : Icons.login,
            size: 40,
            color: AppColors.primary,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 300.ms),
        const SizedBox(height: AppDimensions.spacingLG),
        Text(
          _isSignUp ? l10n.createYourAccount : l10n.welcomeBack,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),
        const SizedBox(height: AppDimensions.spacingSM),
        Text(
          _isSignUp
              ? l10n.enterDetailsToGetStarted
              : l10n.enterCredentialsToSignIn,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildFormFields(AppLocalizations l10n) {
    return Column(
      children: [
        // Name field (sign up only)
        if (_isSignUp) ...[
          PremiumTextField(
            controller: _nameController,
            label: l10n.displayName,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            animationDelay: 300.ms,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
        ],

        // Email field
        PremiumTextField(
          controller: _emailController,
          label: l10n.email,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return l10n.invalidEmail;
            }
            return null;
          },
          animationDelay: _isSignUp ? 400.ms : 300.ms,
        ),
        const SizedBox(height: AppDimensions.spacingMD),

        // Password field
        PremiumTextField(
          controller: _passwordController,
          label: l10n.password,
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction:
              _isSignUp ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: _isSignUp ? null : (_) => _submit(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondaryLight,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            tooltip: _obscurePassword ? l10n.showPassword : l10n.hidePassword,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.passwordRequired;
            }
            if (value.length < 6) {
              return l10n.passwordTooShort;
            }
            return null;
          },
          animationDelay: _isSignUp ? 500.ms : 400.ms,
        ),
        const SizedBox(height: AppDimensions.spacingMD),

        // Confirm password field (sign up only)
        if (_isSignUp) ...[
          PremiumTextField(
            controller: _confirmPasswordController,
            label: l10n.confirmPassword,
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondaryLight,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              tooltip:
                  _obscureConfirmPassword ? l10n.showPassword : l10n.hidePassword,
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return l10n.passwordsDoNotMatch;
              }
              return null;
            },
            animationDelay: 600.ms,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
        ],

        // Forgot password (sign in only)
        if (!_isSignUp) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                l10n.forgotPassword,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: AppDimensions.spacingSM),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return PremiumButton.primary(
      text: _isSignUp ? l10n.createAccount : l10n.signIn,
      isLoading: _isLoading,
      onPressed: _submit,
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 400.ms);
  }

  Widget _buildToggleButton(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isSignUp = !_isSignUp);
            _formKey.currentState?.reset();
          },
          child: Text(
            _isSignUp ? l10n.signIn : l10n.signUp,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (_isSignUp) {
        await ref.read(authStateProvider.notifier).signUpWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : null,
            );
      } else {
        await ref.read(authStateProvider.notifier).signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController(text: _emailController.text);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(l10n.resetPassword),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.resetPasswordDescription,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.textSecondaryLight),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                final success = await ref
                    .read(authStateProvider.notifier)
                    .sendPasswordResetEmail(email);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            success
                                ? l10n.resetEmailSent
                                : l10n.failedToSendResetEmail,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor:
                        success ? AppColors.success : theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    ).then((_) {
      emailController.dispose();
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
