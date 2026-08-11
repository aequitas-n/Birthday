import 'package:kin/domain/models/profile.dart';

abstract interface class ProfileRepository {
  Stream<List<RelationshipProfile>> watchAll();
  Stream<RelationshipProfile?> watchForPerson(String personId);
  Future<RelationshipProfile?> readForPerson(String personId);
  Future<RelationshipProfile> save(RelationshipProfile profile);
  Future<void> softDelete(String id);
}
