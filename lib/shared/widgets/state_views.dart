import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shimmer-free skeleton block: a calm placeholder that reserves layout space.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 16, this.width, this.radius = Radii.sm});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.count = 5, this.itemHeight = 72});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ListView.separated(
        padding: const EdgeInsets.all(Gap.lg),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
        itemBuilder: (_, _) => SkeletonBox(height: itemHeight, radius: Radii.lg),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xxl, vertical: Gap.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: AppColors.borderStrong),
              const SizedBox(height: Gap.lg),
              Text(title, style: t.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: Gap.xs + 2),
              Text(
                message,
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: Gap.xl),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      message: 'We could not load this data. Your records are safe.\n$error',
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

/// Compact coloured label used for statuses. Always pairs colour with text
/// so meaning never depends on colour alone.
/// Status shown as a coloured dot plus text on a faint tint. Meaning is in
/// the words; colour only helps scanning.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, required this.background, this.icon});

  final String label;
  final Color color;
  final Color background;

  /// Optional; replaces the dot when set.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 8, 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 12, color: color)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppSnack(
  BuildContext context,
  String message, {
  bool error = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: onAction != null ? 10 : 4),
        action: onAction == null
            ? null
            : SnackBarAction(label: actionLabel ?? 'Undo', textColor: const Color(0xFF9DB8FF), onPressed: onAction),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: error ? const Color(0xFFFFB4AB) : const Color(0xFFA8E6C4),
              size: 20,
            ),
            const SizedBox(width: Gap.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
