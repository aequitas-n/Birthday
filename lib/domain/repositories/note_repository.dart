import 'package:kin/domain/models/note.dart';

abstract interface class NoteRepository {
  /// Notes for a person via their optional profile. Empty when no profile.
  Stream<List<Note>> watchForPerson(String personId);
  Stream<List<Note>> watchForProfile(String profileId);
  Future<Note> save(Note note);
  Future<void> retire(String id, {required bool value});
  Future<void> reorder({
    required String profileId,
    required List<String> noteIdsInOrder,
  });
  Future<void> softDelete(String id);
}
