import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class QSearchField extends StatefulWidget {
  const QSearchField({
    this.controller,
    this.focusNode,
    this.placeholder = 'Search',
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<QSearchField> createState() => _QSearchFieldState();
}

class _QSearchFieldState extends State<QSearchField>
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
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _ownedController?.dispose();
    super.dispose();
  }

  TextSelectionControls get _selectionControls =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? cupertinoTextSelectionHandleControls
      : materialTextSelectionHandleControls;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;

    return QSurface(
      level: QuietLevel.sunken,
      radius: q.radius.full,
      padding: EdgeInsets.symmetric(
        horizontal: q.space.md,
        vertical: q.space.md - 2,
      ),
      child: Row(
        children: [
          QGlyphIcon(
            QuietGlyph.search,
            color: c.textTertiary,
            size: context.structuralTextScaler.scale(18),
          ),
          SizedBox(width: q.space.sm),
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? IgnorePointer(
                          child: Text(
                            widget.placeholder,
                            style: q.text.body.tinted(c.textTertiary),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _gestures.buildGestureDetector(
                  child: EditableText(
                    key: editableTextKey,
                    controller: _controller,
                    focusNode: _effectiveFocusNode,
                    autofocus: widget.autofocus,
                    style: q.text.body.tinted(c.textPrimary),
                    cursorColor: c.accent,
                    backgroundCursorColor: c.textTertiary,
                    selectionColor: c.selection,
                    selectionControls: _selectionControls,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorWidth: 1.5,
                    cursorRadius: const Radius.circular(1),
                    rendererIgnoresPointer: true,
                    showSelectionHandles: true,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox(width: QIconButton.target)
                : QIconButton(
                    glyph: QuietGlyph.close,
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                    semanticLabel: 'Clear search',
                    tone: QIconTone.secondary,
                    glyphSize: 18,
                  ),
          ),
        ],
      ),
    );
  }
}
