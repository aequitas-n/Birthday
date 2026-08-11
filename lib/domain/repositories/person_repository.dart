import 'package:kin/domain/models/person.dart';

abstract interface class PersonRepository {
  Stream<List<Person>> watchAll();
  Stream<Person?> watchById(String id);
  Future<Person> save(Person person);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<List<Person>> search(String query);
}
