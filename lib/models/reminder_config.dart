class ReminderConfig {
  final int dueDateDay;          // Tanggal jatuh tempo (1–28)
  final bool notify7DaysBefore;
  final bool notify3DaysBefore;
  final bool notifyOnDueDate;
  final bool isEnabled;

  const ReminderConfig({
    this.dueDateDay = 25,
    this.notify7DaysBefore = false,
    this.notify3DaysBefore = true,
    this.notifyOnDueDate = true,
    this.isEnabled = true,
  });

  factory ReminderConfig.defaults() => const ReminderConfig();

  ReminderConfig copyWith({
    int? dueDateDay,
    bool? notify7DaysBefore,
    bool? notify3DaysBefore,
    bool? notifyOnDueDate,
    bool? isEnabled,
  }) =>
      ReminderConfig(
        dueDateDay:          dueDateDay ?? this.dueDateDay,
        notify7DaysBefore:   notify7DaysBefore ?? this.notify7DaysBefore,
        notify3DaysBefore:   notify3DaysBefore ?? this.notify3DaysBefore,
        notifyOnDueDate:     notifyOnDueDate ?? this.notifyOnDueDate,
        isEnabled:           isEnabled ?? this.isEnabled,
      );

  /// Offset hari aktif untuk scheduling notifikasi
  List<int> get activeDayOffsets => [
    if (notify7DaysBefore) 7,
    if (notify3DaysBefore) 3,
    if (notifyOnDueDate) 0,
  ];
}
