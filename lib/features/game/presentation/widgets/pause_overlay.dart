import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/app_widgets.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResumePressed,
    required this.onRestartPressed,
  });

  final VoidCallback onResumePressed;
  final VoidCallback onRestartPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.scrim,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppPanel(
              padding: const EdgeInsets.all(AppSpacing.xl),
              radius: AppRadii.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppColors.coral,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Paused',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Take a breath, then jump back in.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Resume',
                      icon: Icons.play_arrow_rounded,
                      onPressed: onResumePressed,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: AppSecondaryButton(
                      label: 'New Game',
                      icon: Icons.refresh_rounded,
                      onPressed: onRestartPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
