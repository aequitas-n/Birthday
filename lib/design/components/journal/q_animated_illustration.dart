import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A four-drawing loop from a 6×6 atlas. Nine moods occupy 2×2 blocks.
/// The atlas is shared through Flutter's image cache; only this paint layer
/// changes frames. Reduced motion, hidden tabs and background apps pause playback.
class QAnimatedIllustration extends StatefulWidget {
  const QAnimatedIllustration({
    required this.asset,
    this.mood = 'invite',
    this.size = 120,
    this.animate = true,
    this.scene = false,
    this.aspectRatio = 1,
    super.key,
  });

  final String asset;
  final String mood;
  final double size;
  final bool animate;
  final bool scene;
  final double aspectRatio;

  static const moods = [
    'joyful',
    'calm',
    'sad',
    'affection',
    'anxious',
    'frustrated',
    'surprised',
    'neutral',
    'invite',
  ];

  static Rect frameRect(
    ui.Image image,
    String mood,
    int frame, {
    bool scene = false,
  }) {
    if (scene) {
      return Rect.fromLTWH(
        (frame % 2) * image.width / 2,
        (frame ~/ 2) * image.height / 2,
        image.width / 2,
        image.height / 2,
      );
    }
    final index = moods.indexOf(mood);
    final block = index < 0 ? 7 : index;
    final column = (block % 3) * 2 + frame % 2;
    final row = (block ~/ 3) * 2 + frame ~/ 2;
    // Keep neighboring frame edges outside the sampled transparent guard band.
    final width = image.width / 6;
    final height = image.height / 6;
    return Rect.fromLTWH(
      column * width,
      row * height,
      width,
      height,
    ).deflate(width * 0.04);
  }

  @override
  State<QAnimatedIllustration> createState() => _QAnimatedIllustrationState();
}

class _QAnimatedIllustrationState extends State<QAnimatedIllustration>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _playing = false;
  static const _holds = [2100, 450, 500, 550];
  ImageStream? _stream;
  ImageInfo? _image;
  final ValueNotifier<int> _frame = ValueNotifier(0);
  late final ImageStreamListener _listener = ImageStreamListener(
    _loaded,
    onError: (Object error, StackTrace? stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Kin illustrations',
          context: ErrorDescription('loading ${widget.asset}'),
        ),
      );
    },
  );
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _scheduleFrame() {
    _timer = Timer(Duration(milliseconds: _holds[_frame.value]), () {
      if (!mounted || !_playing) return;
      _frame.value = (_frame.value + 1) % 4;
      _scheduleFrame();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
    _syncPlayback();
  }

  @override
  void didUpdateWidget(QAnimatedIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
    _syncPlayback();
  }

  void _resolve() {
    final stream = AssetImage(
      widget.asset,
    ).resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _image?.dispose();
    _image = null;
    _stream = stream;
    stream.addListener(_listener);
  }

  void _loaded(ImageInfo image, bool synchronousCall) {
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
    });
  }

  void _syncPlayback() {
    final media = MediaQuery.maybeOf(context);
    final play =
        widget.animate &&
        _foreground &&
        TickerMode.valuesOf(context).enabled &&
        !(media?.disableAnimations ?? false) &&
        !(media?.accessibleNavigation ?? false);
    if (play == _playing) return;
    _playing = play;
    _timer?.cancel();
    if (play) {
      _scheduleFrame();
    } else {
      _frame.value = 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stream?.removeListener(_listener);
    _image?.dispose();
    _timer?.cancel();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size / widget.aspectRatio,
          child: CustomPaint(
            painter: _SpritePainter(
              _image?.image,
              widget.mood,
              _frame,
              scene: widget.scene,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.image, this.mood, this.frame, {required this.scene})
    : super(repaint: frame);
  final ui.Image? image;
  final String mood;
  final ValueNotifier<int> frame;
  final bool scene;

  @override
  void paint(Canvas canvas, Size size) {
    final atlas = image;
    if (atlas == null) return;
    // A quiet held pose between gestures, instead of constant visual chatter.
    canvas.drawImageRect(
      atlas,
      QAnimatedIllustration.frameRect(atlas, mood, frame.value, scene: scene),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      image != oldDelegate.image ||
      mood != oldDelegate.mood ||
      scene != oldDelegate.scene;
}
