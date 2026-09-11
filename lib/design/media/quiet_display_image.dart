import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Display-size decode hints for [ImageProvider] / [Image.asset].
///
/// Themes and screens keep using semantic assets; this only limits how large a
/// bitmap Flutter materializes. Visual crop / [BoxFit] / layout stay unchanged.
///
/// Decode target = logical display extent × [MediaQuery.devicePixelRatio].
///
/// Important: for [BoxFit.cover] / [BoxFit.contain], only **one** of
/// cacheWidth/cacheHeight is set so the codec preserves intrinsic aspect ratio.
/// Passing both forces [ResizeImagePolicy.exact], which stretches the bitmap
/// before [BoxFit] runs and changes the visible crop.
///
/// Prefer [Image.asset]'s `cacheWidth`/`cacheHeight` for theme asset paths.
/// Use [at] / [maybeAt] for [FileImage] / [MemoryImage] user photos.
abstract final class QuietDisplayImage {
  QuietDisplayImage._();

  /// Physical pixels for a logical extent at the ambient device pixel ratio.
  static int px(BuildContext context, double logical) {
    if (logical <= 0 || !logical.isFinite) return 1;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return math.max(1, (logical * dpr).round());
  }

  /// True when [constraints] give a usable finite box for decode sizing.
  static bool hasBoundedBox(BoxConstraints constraints) {
    return constraints.maxWidth.isFinite &&
        constraints.maxHeight.isFinite &&
        constraints.maxWidth > 0 &&
        constraints.maxHeight > 0;
  }

  /// Wraps [provider] to decode near the given logical display size.
  ///
  /// Pass at least one of [logicalWidth] / [logicalHeight]. When both are
  /// given, aspect is preserved by sizing against the longer edge (cover-safe).
  static ImageProvider at(
    ImageProvider provider, {
    required BuildContext context,
    double? logicalWidth,
    double? logicalHeight,
  }) {
    assert(
      logicalWidth != null || logicalHeight != null,
      'QuietDisplayImage.at requires at least one logical dimension',
    );
    final sized = _aspectPreservingPx(
      context,
      width: logicalWidth,
      height: logicalHeight,
    );
    return ResizeImage(
      provider,
      width: sized.$1,
      height: sized.$2,
    );
  }

  /// Like [at], but no-ops when [constraints] are unbounded.
  static ImageProvider maybeAt(
    ImageProvider provider, {
    required BuildContext context,
    required BoxConstraints constraints,
    double scale = 1,
  }) {
    if (!hasBoundedBox(constraints)) return provider;
    return at(
      provider,
      context: context,
      logicalWidth: constraints.maxWidth * scale,
      logicalHeight: constraints.maxHeight * scale,
    );
  }

  /// Decode hints for [Image.asset] covering / containing [logical] box.
  ///
  /// [fit] must match the widget's [BoxFit]:
  /// - [BoxFit.fill]: both dimensions (exact resize matches fill stretch)
  /// - cover / contain / others: one dimension so aspect is preserved
  ///
  /// [scale] > 1 when the painted image is later magnified (e.g. nav zoom).
  static (int? width, int? height) cacheSize(
    BuildContext context,
    Size logical, {
    double scale = 1,
    BoxFit fit = BoxFit.cover,
  }) {
    final s = scale < 1 ? 1.0 : scale;
    final w = logical.width * s;
    final h = logical.height * s;

    if (fit == BoxFit.fill) {
      return (px(context, w), px(context, h));
    }

    return _aspectPreservingPx(context, width: w, height: h);
  }

  /// Preserve intrinsic aspect: size by the longer logical edge only.
  static (int? width, int? height) _aspectPreservingPx(
    BuildContext context, {
    double? width,
    double? height,
  }) {
    final w = width;
    final h = height;
    if (w != null && h != null) {
      if (w >= h) {
        return (px(context, w), null);
      }
      return (null, px(context, h));
    }
    if (w != null) return (px(context, w), null);
    return (null, px(context, h!));
  }
}
