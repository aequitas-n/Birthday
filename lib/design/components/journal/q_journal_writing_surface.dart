import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Diary writing surface — open paper page, not a Material field.
class QJournalWritingSurface extends StatefulWidget {
  const QJournalWritingSurface({
    this.controller,
    this.focusNode,
    this.placeholder = 'Write what you want to remember.',
    this.minLines = 8,
    this.autofocus = false,
    this.enabled = true,
    this.bordered = false,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final int minLines;
  final bool autofocus;
  final bool enabled;

  /// When false (default), the well is open paper with only a quiet rule —
  /// not an outlined box.
  final bool bordered;
  final ValueChanged<String>? onChanged;

  @override
  State<QJournalWritingSurface> createState() => _QJournalWritingSurfaceState();
}

class _QJournalWritingSurfaceState extends State<QJournalWritingSurface>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _onText() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  void _onFocus() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final style = q.text.archiveBodyLarge.tinted(j.ink);
    final empty = _controller.text.isEmpty;
    final focused = _focus.hasFocus;

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focus,
      style: style,
      cursorColor: q.color.accent,
      backgroundCursorColor: j.paper,
      maxLines: null,
      minLines: widget.minLines,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      autofocus: widget.autofocus,
      readOnly: !widget.enabled,
      onChanged: widget.onChanged,
      selectionColor: q.color.selection,
      cursorOpacityAnimates: !context.prefersReducedMotion,
      selectionControls: defaultTargetPlatform == TargetPlatform.iOS
          ? cupertinoTextSelectionHandleControls
          : materialTextSelectionHandleControls,
    );

    return Semantics(
      textField: true,
      label: 'Story',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: j.paper,
          border: widget.bordered
              ? Border.all(
                  color: focused ? q.color.accent : j.edge,
                  width: focused ? 1.5 : context.hairlineWidth,
                )
              : Border(
                  bottom: BorderSide(
                    color: focused ? j.edge : j.rule,
                    width: focused ? 1 : context.hairlineWidth,
                  ),
                ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            widget.bordered ? q.space.md : 0,
            q.space.sm,
            widget.bordered ? q.space.md : 0,
            q.space.md,
          ),
          child: Stack(
            children: [
              if (empty)
                IgnorePointer(
                  child: Text(
                    widget.placeholder,
                    style: q.text.archiveBodyLarge.tinted(
                      j.inkMuted.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              _gestures.buildGestureDetector(
                behavior: HitTestBehavior.translucent,
                child: editable,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
