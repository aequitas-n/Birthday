import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StoredImageWrite {
  const StoredImageWrite({
    required this.id,
    required this.relativePath,
    required this.bytes,
  });

  final String id;
  final String relativePath;
  final int bytes;
}

abstract interface class ImageStore {
  Future<StoredImageWrite> putJpeg(Uint8List bytes);
  Future<File> resolve(String relativePath);
  Future<void> delete(String relativePath);
  Future<void> deleteOrphans(Set<String> retainedRelativePaths);
}

class LocalImageStore implements ImageStore {
  const LocalImageStore();

  static const _folderName = 'photos';

  @override
  Future<StoredImageWrite> putJpeg(Uint8List bytes) async {
    final digest = sha256.convert(bytes).toString();
    final relativePath = p.join(_folderName, '$digest.jpg');
    final file = await resolve(relativePath);
    if (!file.existsSync()) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }
    return StoredImageWrite(
      id: digest,
      relativePath: relativePath,
      bytes: bytes.lengthInBytes,
    );
  }

  @override
  Future<File> resolve(String relativePath) async {
    final root = await getApplicationDocumentsDirectory();
    return File(p.join(root.path, relativePath));
  }

  @override
  Future<void> delete(String relativePath) async {
    final file = await resolve(relativePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteOrphans(Set<String> retainedRelativePaths) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, _folderName));
    if (!directory.existsSync()) return;

    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final relativePath = p.join(_folderName, p.basename(entity.path));
      if (!retainedRelativePaths.contains(relativePath)) {
        await entity.delete();
      }
    }
  }
}
