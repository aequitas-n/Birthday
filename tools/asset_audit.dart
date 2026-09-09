// ignore_for_file: avoid_print
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

/// Forensic audit of theme assets.
void main() {
  final root = Directory(r'e:\~Work\Birthday\assets');
  final rows = <_Row>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    final rel = path
        .substring(root.path.length)
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    final bytes = entity.readAsBytesSync();
    final size = bytes.length;
    final ext = path.split('.').last.toLowerCase();
    final digest = sha256.convert(bytes).toString().substring(0, 16);

    if (const {'png', 'jpg', 'jpeg', 'webp', 'gif'}.contains(ext)) {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        rows.add(_Row(rel: rel, size: size, ext: ext, digest: digest));
        continue;
      }
      final hasAlphaChannel = decoded.numChannels >= 4;
      var usesTransparency = false;
      if (hasAlphaChannel) {
        // Sample a grid — full scan is too slow for ~3k PNGs.
        const steps = 48;
        final dx = (decoded.width / steps).ceil().clamp(1, decoded.width);
        final dy = (decoded.height / steps).ceil().clamp(1, decoded.height);
        outer:
        for (var y = 0; y < decoded.height; y += dy) {
          for (var x = 0; x < decoded.width; x += dx) {
            if (decoded.getPixel(x, y).a < 255) {
              usesTransparency = true;
              break outer;
            }
          }
        }
      }
      rows.add(
        _Row(
          rel: rel,
          size: size,
          ext: ext,
          digest: digest,
          w: decoded.width,
          h: decoded.height,
          hasAlphaChannel: hasAlphaChannel,
          usesTransparency: usesTransparency,
          numChannels: decoded.numChannels,
          megapixels: (decoded.width * decoded.height) / 1e6,
        ),
      );
    } else {
      rows.add(_Row(rel: rel, size: size, ext: ext, digest: digest));
    }
  }

  rows.sort((a, b) => b.size.compareTo(a.size));

  print('=== ALL ASSETS (largest first) ===');
  for (final r in rows) {
    if (r.w != null) {
      print(
        '${r.rel}\t${r.size}\t${(r.size / 1e6).toStringAsFixed(2)}MB\t'
        '${r.w}x${r.h}\t${r.megapixels!.toStringAsFixed(2)}MP\t'
        'ch=${r.numChannels}\talphaCh=${r.hasAlphaChannel}\t'
        'transparent=${r.usesTransparency}\tsha=${r.digest}',
      );
    } else {
      print('${r.rel}\t${r.size}\t${(r.size / 1e6).toStringAsFixed(2)}MB\tsha=${r.digest}');
    }
  }

  int sumExt(String e) =>
      rows.where((r) => r.ext == e).fold(0, (a, r) => a + r.size);
  final total = rows.fold(0, (a, r) => a + r.size);
  print('\n=== TOTALS ===');
  print('TOTAL\t$total\t${(total / 1e6).toStringAsFixed(2)} MB');
  print('PNG\t${sumExt("png")}\t${(sumExt("png") / 1e6).toStringAsFixed(2)} MB');
  print('JPG\t${sumExt("jpg") + sumExt("jpeg")}');
  print('WEBP\t${sumExt("webp")}');
  print('SVG\t${sumExt("svg")}');
  print('TTF\t${sumExt("ttf")}\t${(sumExt("ttf") / 1e6).toStringAsFixed(2)} MB');
  print('TXT\t${sumExt("txt")}');

  print('\n=== BYTE-IDENTICAL (sha256) ===');
  final byDigest = <String, List<_Row>>{};
  for (final r in rows) {
    byDigest.putIfAbsent(r.digest, () => []).add(r);
  }
  var foundDup = false;
  for (final entry in byDigest.entries) {
    if (entry.value.length > 1) {
      foundDup = true;
      print('${entry.key}: ${entry.value.map((e) => e.rel).toList()}');
    }
  }
  if (!foundDup) print('(none)');

  print('\n=== TOP 20 BY PIXEL DIMENSIONS ===');
  final byPx = rows.where((r) => r.w != null).toList()
    ..sort((a, b) => (b.w! * b.h!).compareTo(a.w! * a.h!));
  for (final r in byPx.take(20)) {
    print('${r.rel}\t${r.w}x${r.h}\t${r.megapixels!.toStringAsFixed(2)}MP\t${(r.size / 1e6).toStringAsFixed(2)}MB');
  }
}

class _Row {
  _Row({
    required this.rel,
    required this.size,
    required this.ext,
    required this.digest,
    this.w,
    this.h,
    this.hasAlphaChannel,
    this.usesTransparency,
    this.numChannels,
    this.megapixels,
  });

  final String rel;
  final int size;
  final String ext;
  final String digest;
  final int? w;
  final int? h;
  final bool? hasAlphaChannel;
  final bool? usesTransparency;
  final int? numChannels;
  final double? megapixels;
}
