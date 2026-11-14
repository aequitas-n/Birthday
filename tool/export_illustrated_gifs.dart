// Rebuild shareable loops from the exact drawings used by Flutter.
// Run: dart run tool/export_illustrated_gifs.dart
import 'dart:io';

import 'package:image/image.dart' as img;

const _themes = [
  'vintage',
  'neon',
  'retro',
  'comic',
  'botanical',
  'seaside',
  'midnight',
];
const _moods = [
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
const _durations = [210, 45, 50, 55]; // Hundredths of a second.

void main() {
  var count = 0;
  for (final theme in _themes) {
    final atlas = img.decodePng(
      File('assets/themes/Illustrated/$theme/moods.png').readAsBytesSync(),
    )!;
    for (var mood = 0; mood < _moods.length; mood++) {
      _export(atlas, theme, _moods[mood], mood, 6, 6, 216, 216);
      count++;
    }
    final scene = img.decodePng(
      File('assets/themes/Illustrated/$theme/scene.png').readAsBytesSync(),
    )!;
    _export(scene, theme, 'scene', 0, 2, 2, 324, 216);
    count++;
    stdout.writeln('$theme: nine character loops and one ambient scene');
  }
  stdout.writeln(
    '$count GIFs in artwork/animated/, with PNG stills in artwork/stills/',
  );
}

void _export(
  img.Image atlas,
  String theme,
  String name,
  int block,
  int columns,
  int rows,
  int width,
  int height,
) {
  final quantizer = img.NeuralQuantizer(atlas, numberOfColors: 255);
  final palette = img.PaletteUint8(256, 4);
  for (var index = 0; index < 255; index++) {
    palette.setRgba(
      index,
      quantizer.palette.getRed(index),
      quantizer.palette.getGreen(index),
      quantizer.palette.getBlue(index),
      255,
    );
  }
  palette.setRgba(255, 0, 0, 0, 0);
  final directory = Directory('artwork/animated/$theme')
    ..createSync(recursive: true);
  final stills = Directory('artwork/stills/$theme')
    ..createSync(recursive: true);
  final gif = img.GifEncoder();
  for (var frame = 0; frame < 4; frame++) {
    final column = (block % (columns ~/ 2)) * 2 + frame % 2;
    final row = (block ~/ (columns ~/ 2)) * 2 + frame ~/ 2;
    final x = (column * atlas.width / columns).round();
    final y = (row * atlas.height / rows).round();
    final crop = img.copyCrop(
      atlas,
      x: x,
      y: y,
      width: ((column + 1) * atlas.width / columns).round() - x,
      height: ((row + 1) * atlas.height / rows).round() - y,
    );
    final inset = columns == 6 ? (crop.width * 0.04).round() : 0;
    final isolated = inset == 0
        ? crop
        : img.copyCrop(
            crop,
            x: inset,
            y: inset,
            width: crop.width - inset * 2,
            height: crop.height - inset * 2,
          );
    final scaled = img.copyResize(
      isolated,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );
    if (frame == 0) {
      File('${stills.path}/$name.png').writeAsBytesSync(img.encodePng(scaled));
    }
    final indexed = img.Image(
      width: width,
      height: height,
      numChannels: 1,
      palette: palette,
    );
    for (final pixel in scaled) {
      indexed.setPixelIndex(
        pixel.x,
        pixel.y,
        pixel.a < 100
            ? 255
            : quantizer.getColorIndexRgb(
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ),
      );
    }
    gif.addFrame(indexed, duration: _durations[frame]);
  }
  final bytes = gif.finish()!;
  File('${directory.path}/$name.gif').writeAsBytesSync(bytes);
  final decoded = img.decodeGif(bytes)!;
  if (decoded.numFrames != 4 ||
      decoded.frames.any(
        (frame) => frame.width != width || frame.height != height,
      )) {
    throw StateError('Invalid loop: $theme/$name');
  }
}
