import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Numeric PIN entry with large 64dp keys, haptic feedback, and an
/// error shake. Calls [onCompleted] when [length] digits are entered.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.length = 4,
    this.errorText,
    this.busy = false,
    this.onBiometric,
    this.dark = false,
  });

  final Future<void> Function(String pin) onCompleted;
  final int length;
  final String? errorText;
  final bool busy;
  final VoidCallback? onBiometric;
  final bool dark;

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 360));

  @override
  void didUpdateWidget(PinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && widget.errorText != oldWidget.errorText) {
      _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  void clear() => setState(() => _pin = '');

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _press(String digit) async {
    if (widget.busy || _pin.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += digit);
    if (_pin.length == widget.length) {
      final value = _pin;
      await widget.onCompleted(value);
      if (mounted) setState(() => _pin = '');
    }
  }

  void _backspace() {
    if (widget.busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.dark ? Colors.white : AppColors.textPrimary;
    final dotOff = widget.dark ? Colors.white.withValues(alpha: 0.28) : AppColors.border;
    final dotOn = widget.dark ? Colors.white : AppColors.primary;
    final errorColor = widget.dark ? const Color(0xFFFFB4AB) : AppColors.danger;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final t = _shake.value;
            final dx = t == 0 ? 0.0 : 10 * (1 - t) * (((t * 8).floor().isEven) ? 1 : -1);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Semantics(
            label: '${_pin.length} of ${widget.length} digits entered',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.length, (i) {
                final filled = i < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 9),
                  width: filled ? 16 : 14,
                  height: filled ? 16 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? dotOn : Colors.transparent,
                    border: Border.all(color: filled ? dotOn : dotOff, width: 2),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Center(
            child: widget.busy
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: dotOn))
                : Text(
                    widget.errorText ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: errorColor, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
          ),
        ),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) _key(d, fg)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.onBiometric == null
                ? const SizedBox(width: 88, height: 72)
                : _iconKey(Icons.fingerprint_rounded, 'Unlock with fingerprint', widget.onBiometric!, fg),
            _key('0', fg),
            _iconKey(Icons.backspace_outlined, 'Delete digit', _backspace, fg),
          ],
        ),
      ],
    );
  }

  Widget _key(String digit, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: widget.dark ? Colors.white.withValues(alpha: 0.08) : AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _press(digit),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: Text(digit, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: fg)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, String label, VoidCallback onTap, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: IconButton(
        tooltip: label,
        onPressed: widget.busy ? null : onTap,
        iconSize: 26,
        style: IconButton.styleFrom(fixedSize: const Size(64, 64), foregroundColor: fg),
        icon: Icon(icon),
      ),
    );
  }
}

/// Re-asks for the owner PIN before a sensitive operation.
/// Returns true only when the correct PIN is entered.
Future<bool> confirmOwnerPin(
  BuildContext context, {
  required Future<bool?> Function(String pin) verify,
  String title = 'Confirm with PIN',
  String message = 'Enter your PIN to continue.',
  int length = 4,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ConfirmPinSheet(verify: verify, title: title, message: message, length: length),
  );
  return result ?? false;
}

class _ConfirmPinSheet extends StatefulWidget {
  const _ConfirmPinSheet({required this.verify, required this.title, required this.message, required this.length});

  final Future<bool?> Function(String pin) verify;
  final String title;
  final String message;
  final int length;

  @override
  State<_ConfirmPinSheet> createState() => _ConfirmPinSheetState();
}

class _ConfirmPinSheetState extends State<_ConfirmPinSheet> {
  String? _error;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: t.titleLarge),
            const SizedBox(height: Gap.xs),
            Text(widget.message, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: Gap.xl),
            PinPad(
              length: widget.length,
              busy: _busy,
              errorText: _error,
              onCompleted: (pin) async {
                setState(() {
                  _busy = true;
                  _error = null;
                });
                final ok = await widget.verify(pin);
                if (!context.mounted) return;
                if (ok == true) {
                  Navigator.of(context).pop(true);
                } else {
                  setState(() {
                    _busy = false;
                    _error = ok == null ? 'Too many attempts. Try again shortly.' : 'Incorrect PIN';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
