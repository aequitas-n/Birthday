import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_collection.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Pick an atmosphere.
///
/// A horizontal run of paper samples rather than a list of names with a
/// checkmark. A collection is a thing you look at, so the control shows the
/// thing: each swatch is painted in that collection's own canvas, hairline and
/// accent, resolved at the brightness currently in force. Choosing "Ocean Mist"
/// from a text list would tell the user nothing about what they were choosing.
class QCollectionPicker extends StatelessWidget {
  const QCollectionPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final QuietCollection selected;
  final ValueChanged<QuietCollection> onSelected;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final metrics = _SwatchMetrics.of(context);

    return SizedBox(
      height: metrics.rowHeight + q.space.xs * 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(vertical: q.space.xs),
        itemCount: QuietCollection.values.length,
        separatorBuilder: (context, index) => SizedBox(width: q.space.md),
        itemBuilder: (context, index) {
          final collection = QuietCollection.values[index];
          return _CollectionSwatch(
            collection: collection,
            colors: QuietColors.of(
              collection,
              dark: q.mode != QuietBrightness.light,
              amoled: q.mode == QuietBrightness.amoled,
            ),
            selected: collection == selected,
            onTap: () => onSelected(collection),
          );
        },
      ),
    );
  }
}

class _CollectionSwatch extends StatelessWidget {
  const _CollectionSwatch({
    required this.collection,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final QuietCollection collection;
  final QuietColors colors;
  final bool selected;
  final VoidCallback onTap;

  static const double selectedRingWidth = 2;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final metrics = _SwatchMetrics.of(context);

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: collection.label,
      selected: selected,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: q.motion.quick,
            curve: q.motion.standard,
            width: metrics.swatch,
            height: metrics.swatch,
            decoration: BoxDecoration(
              color: colors.canvas,
              borderRadius: BorderRadius.circular(q.radius.md),
              border: Border.all(
                color: selected ? q.color.accent : colors.hairlineStrong,
                // The chosen sample is ringed rather than ticked: a checkmark
                // would sit on top of the very thing it is describing.
                width: selected ? selectedRingWidth : context.hairlineWidth,
              ),
            ),
            child: Center(
              child: Container(
                width: metrics.dot,
                height: metrics.dot,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: metrics.gap),
          SizedBox(
            width: metrics.labelWidth,
            height: metrics.labelHeight,
            child: Text(
              collection.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textScaler: context.structuralTextScaler,
              style: q.text.metadata.tinted(
                selected ? q.color.textPrimary : q.color.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Swatch geometry, resolved once so the strip and the swatches inside it
/// cannot disagree about how tall a swatch is.
///
/// Every dimension derives from the text scale, because the name under each
/// sample is real text: a two-line name at 200% must still fit rather than be
/// clipped, and the strip has to know that before it lays anything out.
class _SwatchMetrics {
  const _SwatchMetrics({
    required this.swatch,
    required this.labelWidth,
    required this.labelHeight,
    required this.gap,
  });

  factory _SwatchMetrics.of(BuildContext context) {
    final q = context.quiet;
    final scaler = context.structuralTextScaler;
    final metadata = q.text.metadata;
    final lineHeight = scaler.scale(metadata.fontSize!) * metadata.height!;
    return _SwatchMetrics(
      swatch: scaler.scale(56),
      labelWidth: scaler.scale(76),
      // Two lines, always reserved: names of unequal length would otherwise sit
      // the samples at unequal heights along the strip.
      labelHeight: lineHeight * 2,
      gap: q.space.sm,
    );
  }

  final double swatch;
  final double labelWidth;
  final double labelHeight;
  final double gap;

  double get dot => swatch / 2.6;

  double get rowHeight => swatch + gap + labelHeight;
}
