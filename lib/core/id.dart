import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class IdGenerator {
  const IdGenerator();

  static const Uuid _uuid = Uuid();

  String next() => _uuid.v7();
}

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  return const IdGenerator();
});
