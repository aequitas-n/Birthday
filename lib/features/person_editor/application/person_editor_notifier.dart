import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

/// Fast birthday-only editor: name, birthday, location.
class PersonEditorState {
  const PersonEditorState({
    required this.id,
    this.name = '',
    this.birthDay = '',
    this.birthMonth,
    this.birthYear = '',
    this.location,
    this.showErrors = false,
    this.isSaving = false,
  });

  final String id;
  final String name;
  final String birthDay;
  final int? birthMonth;
  final String birthYear;
  final CityRecord? location;
  final bool showErrors;
  final bool isSaving;

  PersonEditorState copyWith({
    String? id,
    String? name,
    String? birthDay,
    Object? birthMonth = _sentinel,
    String? birthYear,
    Object? location = _sentinel,
    bool? showErrors,
    bool? isSaving,
  }) {
    return PersonEditorState(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth == _sentinel
          ? this.birthMonth
          : birthMonth as int?,
      birthYear: birthYear ?? this.birthYear,
      location: location == _sentinel ? this.location : location as CityRecord?,
      showErrors: showErrors ?? this.showErrors,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  bool get isValid =>
      nameError == null && birthdayError == null && locationError == null;

  String? get nameError {
    if (!showErrors) return null;
    return name.trim().isEmpty ? 'Add a name.' : null;
  }

  String? get birthdayError {
    if (!showErrors) return null;
    final day = int.tryParse(birthDay);
    if (day == null || birthMonth == null) return 'Pick a birthday.';
    final maxDay = DateTime(2024, birthMonth! + 1, 0).day;
    if (day < 1 || day > maxDay) return 'Pick a real date.';
    final year = birthYear.trim().isEmpty ? null : int.tryParse(birthYear);
    if (birthYear.trim().isNotEmpty && year == null) {
      return 'Use 4 digits for the year.';
    }
    return null;
  }

  String? get locationError {
    if (!showErrors) return null;
    return location == null ? 'Choose where they live.' : null;
  }

  PartialDate? get birthday {
    final day = int.tryParse(birthDay);
    final year = birthYear.trim().isEmpty ? null : int.tryParse(birthYear);
    if (day == null || birthMonth == null) return null;
    if (day < 1 || day > DateTime(2024, birthMonth! + 1, 0).day) return null;
    return PartialDate(month: birthMonth!, day: day, year: year);
  }
}

class PersonEditorNotifier extends Notifier<PersonEditorState> {
  @override
  PersonEditorState build() {
    return _freshState(ref);
  }

  void setName(String value) => state = state.copyWith(name: value);
  void setBirthDay(String value) => state = state.copyWith(birthDay: value);
  void setBirthMonth(int month) => state = state.copyWith(birthMonth: month);
  void setBirthYear(String value) => state = state.copyWith(birthYear: value);
  void setLocation(CityRecord location) =>
      state = state.copyWith(location: location);

  void reset() {
    state = _freshState(ref);
  }

  Future<Person?> save() async {
    state = state.copyWith(showErrors: true);
    if (!state.isValid || state.birthday == null) {
      return null;
    }

    state = state.copyWith(isSaving: true);
    try {
      final clock = ref.read(clockProvider);
      final now = clock.now();
      final saved = await ref
          .read(personRepositoryProvider)
          .save(
            Person(
              id: state.id,
              displayName: state.name,
              birthday: state.birthday!,
              location: LocationModel(
                label: state.location!.label,
                timezone: TimezoneModel(state.location!.ianaTimezone),
              ),
              sortKey: '',
              createdAt: now,
              updatedAt: now,
            ),
          );
      try {
        await ref.read(notificationCoordinatorProvider).synchronize();
      } on Object {
        // Reminder sync is best-effort; never fail the person save.
      }

      state = _freshState(ref);
      return saved;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}

final personEditorProvider =
    NotifierProvider<PersonEditorNotifier, PersonEditorState>(
      PersonEditorNotifier.new,
    );

const _sentinel = Object();

PersonEditorState _freshState(Ref ref) =>
    PersonEditorState(id: ref.read(idGeneratorProvider).next());
