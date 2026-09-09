import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class QSettingRow extends StatelessWidget {
  const QSettingRow({
    required this.label,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    super.key,
  }) : assert(
         value == null || trailing == null,
         'Use either a text value or a trailing widget, not both.',
       );

  final String label;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    final body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: q.layout.settingRowHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: q.text.body.tinted(context.controlInk),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: q.space.hair),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: q.text.caption.tinted(context.controlInkSecondary),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: q.space.md),
            if (value != null)
              Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: context.structuralTextScaler,
                style: q.text.label.tinted(context.controlInkSecondary),
              ),
            if (trailing != null) trailing!,
            if (showChevron) ...[
              SizedBox(width: q.space.xs),
              QGlyphIcon(
                QuietGlyph.chevronRight,
                color: context.controlInkMuted,
                size: context.structuralTextScaler.scale(18),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return body;
    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: label,
      child: body,
    );
  }
}
