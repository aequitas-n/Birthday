import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/search_strip_geometry.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// People search field printed onto [VintageDiaryAssets.search].
///
/// Flat parchment strip under the Birthdays/People tabs — not the hanging
/// [VintageDiaryAssets.userStrip] tag.
class QPeopleSearchStrip extends StatefulWidget {
  const QPeopleSearchStrip({
    this.controller,
    this.focusNode,
    this.placeholder = 'Search people',
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<QPeopleSearchStrip> createState() => _QPeopleSearchStripState();
}

class _QPeopleSearchStripState extends State<QPeopleSearchStrip>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  TextEditingController? _ownedController;
  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  final FocusNode _focusNode = FocusNode();
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleText);
  }

  @override
  void didUpdateWidget(covariant QPeopleSearchStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleText);
      _ownedController?.removeListener(_handleText);
      if (widget.controller == null) {
        _ownedController ??= TextEditingController();
      } else {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _controller.addListener(_handleText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleText);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleText() => setState(() {});

  TextSelectionControls get _selectionControls =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? cupertinoTextSelectionHandleControls
      : materialTextSelectionHandleControls;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;

    return QuietControlSurfaceScope(
      surface: QuietControlSurface.parchment,
      child: AspectRatio(
        aspectRatio: SearchStripGeometry.aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final fieldLeft = w * SearchStripGeometry.contentLeft;
            final fieldRight = w * (1 - SearchStripGeometry.contentRight);
            final fieldTop = h * SearchStripGeometry.contentPadY;
            final fieldHeight =
                h * (1 - SearchStripGeometry.contentPadY * 2);

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  VintageDiaryAssets.search,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
                Positioned(
                  left: fieldLeft,
                  right: fieldRight,
                  top: fieldTop,
                  height: fieldHeight,
                  child: Row(
                    children: [
                      QGlyphIcon(
                        QuietGlyph.search,
                        color: paper.secondary,
                        size: context.structuralTextScaler.scale(18),
                      ),
                      SizedBox(width: q.space.sm),
                      Expanded(
                        child: _gestures.buildGestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: EditableText(
                            key: editableTextKey,
                            controller: _controller,
                            focusNode: _effectiveFocusNode,
                            style: paper.inked(q.text.uiBody),
                            cursorColor: paper.primary,
                            backgroundCursorColor: paper.secondary,
                            selectionColor: q.color.selection,
                            selectionControls: _selectionControls,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            autocorrect: false,
                            enableSuggestions: false,
                            maxLines: 1,
                            onChanged: widget.onChanged,
                            onSubmitted: widget.onSubmitted,
                          ),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        QIconButton(
                          glyph: QuietGlyph.close,
                          tone: QIconTone.secondary,
                          glyphSize: 16,
                          onPressed: () {
                            _controller.clear();
                            widget.onChanged?.call('');
                          },
                          semanticLabel: 'Clear search',
                        ),
                    ],
                  ),
                ),
                if (_controller.text.isEmpty)
                  Positioned(
                    left:
                        fieldLeft +
                        context.structuralTextScaler.scale(18) +
                        q.space.sm,
                    right: fieldRight,
                    top: fieldTop,
                    height: fieldHeight,
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: context.structuralTextScaler,
                          style: paper.inked(
                            q.text.uiBody,
                            tone: QuietInkTone.secondary,
                          ),
                        ),
                      ),
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
