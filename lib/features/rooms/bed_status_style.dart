import 'package:flutter/material.dart';

import '../../core/database/enums.dart';
import '../../core/theme/app_colors.dart';

/// Colour + icon per bed status. Icons ensure meaning is not colour-only.
extension BedStatusStyle on BedStatus {
  Color get color => switch (this) {
        BedStatus.available => AppColors.bedAvailable,
        BedStatus.occupied => AppColors.bedOccupied,
        BedStatus.reserved => AppColors.bedReserved,
        BedStatus.maintenance => AppColors.bedMaintenance,
      };

  Color get soft => switch (this) {
        BedStatus.available => AppColors.successSoft,
        BedStatus.occupied => AppColors.primary.withValues(alpha: 0.08),
        BedStatus.reserved => AppColors.infoSoft,
        BedStatus.maintenance => AppColors.warningSoft,
      };

  IconData get icon => switch (this) {
        BedStatus.available => Icons.check_circle_outline_rounded,
        BedStatus.occupied => Icons.person_rounded,
        BedStatus.reserved => Icons.bookmark_outline_rounded,
        BedStatus.maintenance => Icons.build_outlined,
      };
}
