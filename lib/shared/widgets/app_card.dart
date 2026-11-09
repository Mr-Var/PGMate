import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Hairline-bordered surface. Cards group content; they are not decoration.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(Gap.lg), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase label used above sections and figures.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTheme.eyebrow.copyWith(color: color ?? AppColors.textMuted),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing, this.count});

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Flexible(
              child: Semantics(header: true, child: Eyebrow(count != null && count! > 0 ? '$title · $count' : title)),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A labelled figure: label, large tabular value, optional caption.
/// [tone] colours a small marker so semantics never rely on the number alone.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.tone,
    this.valueColor,
  });

  /// Kept for call-site compatibility; the refined style shows no icon.
  final IconData? icon;
  final String label;
  final String value;
  final String? caption;
  final Color? tone;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$label: $value${caption == null ? '' : ', $caption'}',
      excludeSemantics: true,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md + 2, Gap.lg, Gap.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (tone != null) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(child: Eyebrow(label)),
              ],
            ),
            const SizedBox(height: Gap.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTheme.figure(22, color: valueColor)),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Key/value row used in detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.strong = false, this.valueColor});
  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: Gap.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (strong ? t.titleSmall : t.bodyMedium)?.copyWith(
                fontFeatures: AppTheme.tabular,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
