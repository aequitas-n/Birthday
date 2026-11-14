/// Organizational bucket for a personal reminder on a day.
///
/// Exact LocalClockTime is authoritative; day-part ranges are defaults only.
enum ReminderDayPart {
  anytime,
  morning,
  afternoon,
  evening;

  static ReminderDayPart fromStorage(String value) {
    return values.firstWhere(
      (entry) => entry.storageValue == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unknown reminder day part.',
      ),
    );
  }

  String get storageValue => name;

  String get label => switch (this) {
    ReminderDayPart.anytime => 'Anytime',
    ReminderDayPart.morning => 'Morning',
    ReminderDayPart.afternoon => 'Afternoon',
    ReminderDayPart.evening => 'Evening',
  };

  String get emptyInvitation => switch (this) {
    ReminderDayPart.anytime => 'Anytime today works',
    ReminderDayPart.morning => "What's on your morning list?",
    ReminderDayPart.afternoon => "What's happening today?",
    ReminderDayPart.evening => 'End the day your way',
  };

  /// Suggested clock time when creating under this section.
  ///
  /// The user may override freely — including times outside this suggestion.
  String get defaultLocalTime => switch (this) {
    ReminderDayPart.anytime => '12:00',
    ReminderDayPart.morning => '08:00',
    ReminderDayPart.afternoon => '14:00',
    ReminderDayPart.evening => '19:00',
  };
}
