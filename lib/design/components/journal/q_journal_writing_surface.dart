import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/surfaces/q_diary_well.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Diary writing well on the dark vintage canvas — cream outline, open page.
///
/// Uses [QuietSurfaceKind.canvas] ink from the theme (transparent fill, cream
/// border + type). Do not hardcode cream/brown here.
class QJournalWritingSurface extends StatefulWidget {
  const QJournalWritingSurface({
    this.controller,
    this.focusNode,
    this.placeholder = 'Write what you want to remember.',
    this.minLines = 8,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final int minLines;
  final bool autofocus;
  final bool enabled;
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
    final style = q.inked(q.text.journalWriting);
    final empty = _controller.text.isEmpty;
    final focused = _focus.hasFocus;

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focus,
      style: style,
      cursorColor: q.color.accent,
      backgroundCursorColor: q.color.canvas,
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
      child: QDiaryWell(
        focused: focused,
        child: Stack(
          children: [
            if (empty)
              IgnorePointer(
                child: Text(
                  widget.placeholder,
                  style: q.inked(
                    q.text.journalWriting,
                    tone: QuietInkTone.secondary,
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
    );
  }
}
