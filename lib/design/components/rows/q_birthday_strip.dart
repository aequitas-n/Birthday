import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/user_strip_geometry.dart';

/// One birthday row — hanging parchment tag when the theme supplies
/// [AppThemeChrome.birthdayStrip], otherwise a full-width Default paper strip.
class QBirthdayStrip extends StatelessWidget {
  const QBirthdayStrip({
    required this.displayName,
    required this.seed,
    required this.daysUntil,
    this.dateLabel,
    this.countdownText,
    this.photo,
    this.onTap,
    this.heroTag,
    super.key,
  });

  final String displayName;
  final String seed;
  final int daysUntil;

  /// Day + month only, e.g. `7 August`. No location, no ellipsis.
  final String? dateLabel;

  final String? countdownText;
  final ImageProvider? photo;
  final VoidCallback? onTap;
  final Object? heroTag;

  String get _countdown {
    final raw =
        countdownText ??
        switch (daysUntil) {
          0 => 'Today',
          1 => 'Tomorrow',
          _ => '$daysUntil days',
        };
    return raw.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final stripAsset = context.appTheme.assets.chrome.birthdayStrip;
    if (stripAsset == null) {
      return _DefaultPaperStrip(
        displayName: displayName,
        seed: seed,
        daysUntil: daysUntil,
        dateLabel: dateLabel,
        countdown: _countdown,
        photo: photo,
        onTap: onTap,
        heroTag: heroTag,
      );
    }

    return _VintageHangingStrip(
      displayName: displayName,
      seed: seed,
      daysUntil: daysUntil,
      dateLabel: dateLabel,
      countdown: _countdown,
      photo: photo,
      onTap: onTap,
      heroTag: heroTag,
      stripAsset: stripAsset,
      layout: context.appTheme.assets.chrome.birthdayStripLayout ??
          UserStripGeometry.vintage,
    );
  }
}

/// Default: warm paper band spanning the content width (~90% of screen).
class _DefaultPaperStrip extends StatelessWidget {
  const _DefaultPaperStrip({
    required this.displayName,
    required this.seed,
    required this.daysUntil,
    required this.countdown,
    this.dateLabel,
    this.photo,
    this.onTap,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final int daysUntil;
  final String countdown;
  final String? dateLabel;
  final ImageProvider? photo;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.on(QuietSurfaceKind.paper);
    final emphasized = daysUntil == 0;

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: [
        displayName,
        if (dateLabel != null) dateLabel!,
        countdown,
      ].join(', '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: q.journal.paper,
          borderRadius: BorderRadius.circular(q.radius.md),
          border: Border.all(
            color: q.journal.edge,
            width: context.hairlineWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: q.journal.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: q.space.base,
            vertical: q.space.md,
          ),
          child: Row(
            children: [
              _StripPortrait(
                displayName: displayName,
                seed: seed,
                photo: photo,
                heroTag: heroTag,
                diameter: QAvatarSize.md.diameter,
              ),
              SizedBox(width: q.space.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: context.nameTextScaler,
                      style: paper.inked(q.text.personName),
                    ),
                    if (dateLabel != null && dateLabel!.isNotEmpty) ...[
                      SizedBox(height: q.space.xs),
                      Text(
                        dateLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: context.structuralTextScaler,
                        style: paper.inked(
                          q.text.uiMetadata,
                          tone: QuietInkTone.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: q.space.sm),
              _DefaultCountdown(
                label: countdown,
                emphasized: emphasized,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultCountdown extends StatelessWidget {
  const _DefaultCountdown({
    required this.label,
    required this.emphasized,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = emphasized ? q.color.accent : q.journal.inkMuted;
    final fill = emphasized ? q.color.accentWash : q.journal.paperSunken;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(q.radius.sm),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: q.space.md,
          vertical: q.space.xs + 1,
        ),
        child: Text(
          label,
          textScaler: context.structuralTextScaler,
          style: q.text.stampLabel.copyWith(color: ink),
        ),
      ),
    );
  }
}

/// Theme hanging tag: content laid out in the visible paper of user-strip.
class _VintageHangingStrip extends StatelessWidget {
  const _VintageHangingStrip({
    required this.displayName,
    required this.seed,
    required this.daysUntil,
    required this.countdown,
    required this.stripAsset,
    required this.layout,
    this.dateLabel,
    this.photo,
    this.onTap,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final int daysUntil;
  final String countdown;
  final String stripAsset;
  final UserStripLayout layout;
  final String? dateLabel;
  final ImageProvider? photo;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final geo = layout;

    return QPressable(
      onTap: onTap,
      radius: q.radius.sm,
      semanticLabel: [
        displayName,
        if (dateLabel != null) dateLabel!,
        countdown,
      ].join(', '),
      child: AspectRatio(
        aspectRatio: geo.aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final stripTop = h * geo.stripTop;
            final stripBottom = h * geo.stripBottom;
            final stripH = (stripBottom - stripTop).clamp(1.0, h);
            final contentLeft = w * geo.contentLeft;
            final contentRight = w * geo.contentRight;
            final contentTop = stripTop + stripH * geo.contentPadY;
            final contentBottom = stripBottom - stripH * geo.contentPadY;
            final contentH = (contentBottom - contentTop).clamp(1.0, h);
            // Neon bars are short — size the portrait to the band, with a little
            // slack so borders/type never trip a 1px overflow.
            final avatarSize = geo.chainStack
                ? (contentH * 0.92).clamp(32.0, 56.0)
                : (contentH * 0.72).clamp(32.0, 52.0);
            final photoGap = w * geo.contentGap;
            final stampGap = w * geo.countdownGap;
            final denseHud = !geo.chainStack;

            final cache = QuietDisplayImage.cacheSize(
              context,
              Size(w, h),
              fit: BoxFit.fill,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  stripAsset,
                  fit: BoxFit.fill,
                  cacheWidth: cache.$1,
                  cacheHeight: cache.$2,
                  gaplessPlayback: true,
                ),
                Positioned(
                  left: contentLeft,
                  right: w - contentRight,
                  top: contentTop,
                  height: contentH,
                  child: denseHud
                      ? _NeonHudStripBody(
                          displayName: displayName,
                          seed: seed,
                          dateLabel: dateLabel,
                          countdown: countdown,
                          daysUntil: daysUntil,
                          photo: photo,
                          heroTag: heroTag,
                          avatarSize: avatarSize,
                          photoGap: photoGap,
                          stampGap: stampGap,
                          paper: paper,
                        )
                      : _VintageTagStripBody(
                          displayName: displayName,
                          seed: seed,
                          dateLabel: dateLabel,
                          countdown: countdown,
                          daysUntil: daysUntil,
                          photo: photo,
                          heroTag: heroTag,
                          avatarSize: avatarSize,
                          photoGap: photoGap,
                          stampGap: stampGap,
                          paper: paper,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Neon HUD: avatar left; name + date stack; countdown pinned to the plate's
/// right edge — fills the bar without a stranded middle void or overflow.
class _NeonHudStripBody extends StatelessWidget {
  const _NeonHudStripBody({
    required this.displayName,
    required this.seed,
    required this.countdown,
    required this.daysUntil,
    required this.avatarSize,
    required this.photoGap,
    required this.stampGap,
    required this.paper,
    this.dateLabel,
    this.photo,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final String countdown;
  final int daysUntil;
  final double avatarSize;
  final double photoGap;
  final double stampGap;
  final QuietSurfaceInk paper;
  final String? dateLabel;
  final ImageProvider? photo;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final nameStyle = paper.inked(q.text.personName).copyWith(height: 1);
    final dateStyle = paper
        .inked(q.text.uiMetadata, tone: QuietInkTone.secondary)
        .copyWith(height: 1);

    return Row(
      children: [
        _StripPortrait(
          displayName: displayName,
          seed: seed,
          photo: photo,
          heroTag: heroTag,
          diameter: avatarSize,
        ),
        SizedBox(width: photoGap),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: context.nameTextScaler,
                              style: nameStyle,
                            ),
                          ),
                          SizedBox(width: stampGap),
                          _StampCountdown(
                            label: countdown,
                            emphasized: daysUntil == 0,
                          ),
                        ],
                      ),
                      if (dateLabel != null && dateLabel!.isNotEmpty)
                        Text(
                          dateLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: context.structuralTextScaler,
                          style: dateStyle,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Vintage parchment tag: name/date left, stamp anchored to the right edge.
class _VintageTagStripBody extends StatelessWidget {
  const _VintageTagStripBody({
    required this.displayName,
    required this.seed,
    required this.countdown,
    required this.daysUntil,
    required this.avatarSize,
    required this.photoGap,
    required this.stampGap,
    required this.paper,
    this.dateLabel,
    this.photo,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final String countdown;
  final int daysUntil;
  final double avatarSize;
  final double photoGap;
  final double stampGap;
  final QuietSurfaceInk paper;
  final String? dateLabel;
  final ImageProvider? photo;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Row(
      children: [
        _StripPortrait(
          displayName: displayName,
          seed: seed,
          photo: photo,
          heroTag: heroTag,
          diameter: avatarSize,
        ),
        SizedBox(width: photoGap),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: context.nameTextScaler,
                  style: paper.inked(q.text.personName),
                ),
                if (dateLabel != null && dateLabel!.isNotEmpty) ...[
                  SizedBox(height: q.space.hair),
                  Text(
                    dateLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    textScaler: context.structuralTextScaler,
                    style: paper.inked(
                      q.text.uiMetadata,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: stampGap),
        _StampCountdown(
          label: countdown,
          emphasized: daysUntil == 0,
        ),
      ],
    );
  }
}

/// Stacks strips — Vintage chain overlap, or Default spaced paper cards.
class QBirthdayStripChain extends StatelessWidget {
  const QBirthdayStripChain({
    required this.children,
    this.hangFromDivider = true,
    super.key,
  });

  final List<Widget> children;

  /// Align the first chain head with the layout edge above (month divider).
  final bool hangFromDivider;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final chrome = context.appTheme.assets.chrome;
    final stripLayout = chrome.birthdayStripLayout;
    final usesStripAsset = chrome.birthdayStrip != null;
    final chainStack = stripLayout?.chainStack ?? false;

    if (!usesStripAsset || !chainStack) {
      final gap = context.quiet.space.sm;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    final geo = stripLayout ?? UserStripGeometry.vintage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = geo.renderedHeightForWidth(width);
        final advance = geo.chainAdvance(height);
        final n = children.length;
        final pullUp = hangFromDivider ? height * geo.chainTopY : 0.0;
        final totalHeight = height + (n - 1) * advance - pullUp;

        return SizedBox(
          width: width,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < n; i++)
                Positioned(
                  top: i * advance - pullUp,
                  left: 0,
                  width: width,
                  height: height,
                  child: children[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StripPortrait extends StatelessWidget {
  const _StripPortrait({
    required this.displayName,
    required this.seed,
    required this.diameter,
    this.photo,
    this.heroTag,
  });

  final String displayName;
  final String seed;
  final double diameter;
  final ImageProvider? photo;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: q.journal.ink.withValues(alpha: 0.28),
          width: context.hairlineWidth * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: q.journal.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: diameter,
          child: OverflowBox(
            maxWidth: diameter,
            maxHeight: diameter,
            child: Transform.scale(
              scale: diameter / QAvatarSize.md.diameter,
              child: QAvatar(
                displayName: displayName,
                seed: seed,
                photo: photo,
                heroTag: heroTag,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Countdown label — plain stamp type, no box.
class _StampCountdown extends StatelessWidget {
  const _StampCountdown({
    required this.label,
    required this.emphasized,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = emphasized ? q.color.accent : q.journal.ink.withValues(alpha: 0.72);

    return Text(
      label,
      textScaler: context.structuralTextScaler,
      style: q.text.stampLabel.copyWith(
        color: ink,
        height: 1,
      ),
    );
  }
}
