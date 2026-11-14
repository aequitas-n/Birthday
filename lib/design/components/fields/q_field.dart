import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A sunken well with a floating eyebrow.
///
/// Not an outlined box, and not a Material underline. Labels sit above as
/// eyebrows rather than animating into a border notch — that notch is one of
/// the most recognisable Material signatures.
///
/// Built on [EditableText] rather than `TextField`, because `TextField` brings
/// the entire Material input look with it. Platform text-selection handles are
/// borrowed, since those are OS conventions rather than product design.
///
/// See docs/08-components.md §2.
class QField extends StatefulWidget {
  const QField({
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.helper,
    this.error,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.showHelperLine = true,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Rendered as an eyebrow above the well.
  final String? label;

  final String? placeholder;

  /// Persistent guidance. Space for this line is always reserved so an error
  /// appearing never shifts the layout.
  final String? helper;

  /// Non-null puts the field in its error state. Validation fires on blur or
  /// submit, never per keystroke.
  final String? error;

  final bool enabled;
  final bool autofocus;

  /// Multiline fields grow to this many lines, then scroll internally.
  final int maxLines;

  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool showHelperLine;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  static const double singleLineHeight = 48;
  static const double disabledOpacity = 0.38;
  static const double focusBorderWidth = 1.5;

  @override
  State<QField> createState() => _QFieldState();
}

class _QFieldState extends State<QField>
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
  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  final FocusNode _focusNode = FocusNode();
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _effectiveFocusNode.hasFocus;
    if (focused == _focused) return;
    setState(() => _focused = focused);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
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
    final i = q.interactive;
    final onParchment = context.isParchmentControls;
    final hasError = widget.error != null;

    final fill = onParchment
        ? (_focused ? i.inputFocused : i.input)
        : (_focused ? c.canvas : c.sunken);

    final textColor = onParchment ? i.ink : c.textPrimary;
    // Field eyebrows must read as clearly as body copy on parchment sheets —
    // secondary/muted browns wash out on cream and look "missing".
    final labelColor = onParchment ? i.ink : c.textSecondary;
    final placeholderColor = onParchment ? i.inkSecondary : c.textTertiary;

    // The border is always present at a constant width, and only its colour
    // changes. A border contributes to the shape's dimensions, so varying its
    // width or presence between states would shift the layout — which is
    // exactly what the reserved helper line exists to prevent.
    final borderColor = hasError
        ? c.danger
        : _focused
        ? (onParchment ? i.accent : c.accent)
        : (onParchment ? i.inputBorder : fill);

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _effectiveFocusNode,
      readOnly: !widget.enabled,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: [
        ...?widget.inputFormatters,
        if (widget.maxLength != null)
          LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      textAlign: widget.textAlign,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      style: q.text.bodyLg.tinted(textColor),
      cursorColor: onParchment ? i.accent : c.accent,
      backgroundCursorColor: placeholderColor,
      selectionColor: c.selection,
      selectionControls: _selectionControls,
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(1),
      cursorOpacityAnimates: !context.prefersReducedMotion,
      // The gesture detector below owns pointer handling.
      rendererIgnoresPointer: true,
      showSelectionHandles: true,
    );

    final well = DecoratedBox(
      decoration: ShapeDecoration(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(q.radius.sm)),
          side: BorderSide(
            color: borderColor,
            width: QField.focusBorderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: q.space.md + 2,
          vertical: q.space.md,
        ),
        child: Stack(
          children: [
            if (widget.placeholder != null)
              _Placeholder(
                controller: _controller,
                text: widget.placeholder!,
                style: q.text.bodyLg.tinted(placeholderColor),
              ),
            _gestures.buildGestureDetector(child: editable),
          ],
        ),
      ),
    );

    return Opacity(
      opacity: widget.enabled ? 1 : QField.disabledOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!.toUpperCase(),
              textScaler: context.structuralTextScaler,
              style: q.text.eyebrow.tinted(labelColor),
            ),
            SizedBox(height: q.space.sm),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.maxLines == 1 ? QField.singleLineHeight : 0,
            ),
            child: well,
          ),
          if (widget.showHelperLine) ...[
            // Reserved at build time, so an error never moves the layout.
            SizedBox(height: q.space.sm - 2),
            _HelperLine(
              message: widget.error ?? widget.helper,
              isError: hasError,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown only while the field is empty. Rebuilt from the controller so it
/// disappears on the first keystroke without the parent needing to know.
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.controller,
    required this.text,
    required this.style,
  });

  final TextEditingController controller;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => value.text.isEmpty
          ? IgnorePointer(child: Text(text, style: style, maxLines: 1))
          : const SizedBox.shrink(),
    );
  }
}

class _HelperLine extends StatelessWidget {
  const _HelperLine({required this.message, required this.isError});

  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final style = q.text.caption.tinted(
      isError
          ? q.color.danger
          : (context.isParchmentControls
                ? q.interactive.inkSecondary
                : q.color.textTertiary),
    );

    return SizedBox(
      height: context.structuralTextScaler.scale(16),
      child: message == null
          ? null
          : Text(
              message!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: context.structuralTextScaler,
              style: style,
            ),
    );
  }
}
