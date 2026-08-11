import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StoredAudioWrite {
  const StoredAudioWrite({
    required this.id,
    required this.relativePath,
    required this.bytes,
  });

  final String id;
  final String relativePath;
  final int bytes;
}

/// File-backed Journal audio (mirrors LocalImageStore for photographs).
abstract interface class AudioStore {
  Future<StoredAudioWrite> putBytes(
    List<int> bytes, {
    String extension = 'm4a',
  });

  Future<StoredAudioWrite> putFile(
    File source, {
    String extension = 'm4a',
  });

  Future<String> createTempRecordingPath({String extension = 'm4a'});

  Future<File> resolve(String relativePath);

  Future<void> delete(String relativePath);
}

class LocalAudioStore implements AudioStore {
  const LocalAudioStore();

  static const folderName = 'journal_audio';

  @override
  Future<StoredAudioWrite> putBytes(
    List<int> bytes, {
    String extension = 'm4a',
  }) async {
    final digest = sha256.convert(bytes).toString();
    final relativePath = p.join(folderName, '$digest.$extension');
    final file = await resolve(relativePath);
    if (!file.existsSync()) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
    }
    return StoredAudioWrite(
      id: digest,
      relativePath: relativePath,
      bytes: bytes.length,
    );
  }

  @override
  Future<StoredAudioWrite> putFile(
    File source, {
    String extension = 'm4a',
  }) async {
    final bytes = await source.readAsBytes();
    return putBytes(bytes, extension: extension);
  }

  @override
  Future<String> createTempRecordingPath({String extension = 'm4a'}) async {
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, folderName));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final name = const Uuid().v4();
    return p.join(dir.path, '$name.$extension');
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
}
