import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Sign out button widget
class SignOutButton extends StatelessWidget {
  const SignOutButton({
    super.key,
    required this.isSigningOut,
    required this.onPressed,
    required this.isArabic,
  });

  final bool isSigningOut;
  final VoidCallback onPressed;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isSigningOut ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md - 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSigningOut)
              SizedBox(
                width: AppDimensions.iconSM,
                height: AppDimensions.iconSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.error,
                ),
              )
            else
              const Icon(Icons.logout, size: AppDimensions.iconSM),
            const SizedBox(width: AppDimensions.sm - 2),
            Text(
              isSigningOut ? l10n.signingOut : l10n.signOut,
              style: (isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ))
                  .copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
