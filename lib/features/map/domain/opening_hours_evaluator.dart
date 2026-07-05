import '../../../shared/models/store_place.dart';

class OpeningHoursResult {
  const OpeningHoursResult({
    required this.status,
    required this.label,
    this.timeHint,
    this.confidenceLabel = 'Podatak iz OpenStreetMap-a',
  });

  final StoreOpenStatus status;
  final String label;
  final String? timeHint;
  final String confidenceLabel;
}

class OpeningHoursEvaluator {
  OpeningHoursResult evaluate(String? openingHours, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final raw = openingHours?.trim();

    if (raw == null || raw.isEmpty) {
      return const OpeningHoursResult(
        status: StoreOpenStatus.unknown,
        label: 'Radno vrijeme nije dostupno',
        confidenceLabel: 'Nepotvrđeno',
      );
    }

    final lower = raw.toLowerCase();
    if (lower == '24/7') {
      return const OpeningHoursResult(
        status: StoreOpenStatus.open,
        label: 'Otvoreno 24 sata',
        timeHint: '24/7',
      );
    }

    if (lower.contains('off') && !_containsTimeRange(lower)) {
      return const OpeningHoursResult(
        status: StoreOpenStatus.closed,
        label: 'Zatvoreno',
      );
    }

    final todaysRanges = _rangesForDate(raw, current);
    final nowMinutes = current.hour * 60 + current.minute;

    for (final range in todaysRanges) {
      if (range.contains(nowMinutes)) {
        return OpeningHoursResult(
          status: StoreOpenStatus.open,
          label: 'Otvoreno do ${_formatMinutes(range.end)}',
          timeHint: _remainingText(range.end - nowMinutes),
        );
      }
    }

    final nextToday = todaysRanges.where((r) => r.start > nowMinutes).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (nextToday.isNotEmpty) {
      return OpeningHoursResult(
        status: StoreOpenStatus.closed,
        label: 'Zatvoreno · otvara u ${_formatMinutes(nextToday.first.start)}',
      );
    }

    for (var offset = 1; offset <= 7; offset++) {
      final day = current.add(Duration(days: offset));
      final ranges = _rangesForDate(raw, day)..sort((a, b) => a.start.compareTo(b.start));
      if (ranges.isNotEmpty) {
        final prefix = offset == 1 ? 'sutra' : _weekdayLabel(day.weekday).toLowerCase();
        return OpeningHoursResult(
          status: StoreOpenStatus.closed,
          label: 'Zatvoreno · otvara $prefix u ${_formatMinutes(ranges.first.start)}',
        );
      }
    }

    return OpeningHoursResult(
      status: StoreOpenStatus.unknown,
      label: 'Radno vrijeme treba provjeriti',
      confidenceLabel: 'Nepotvrđeno',
    );
  }

  List<_TimeRange> _rangesForDate(String raw, DateTime date) {
    final dayIndex = date.weekday; // 1=Mon, 7=Sun
    final rules = raw.split(';').map((r) => r.trim()).where((r) => r.isNotEmpty);
    final ranges = <_TimeRange>[];

    for (final rule in rules) {
      final lower = rule.toLowerCase();
      if (lower.contains('ph off') || lower == 'off') continue;

      if (!_ruleAppliesToDay(rule, dayIndex)) continue;
      ranges.addAll(_extractRanges(rule));
    }

    return ranges;
  }

  bool _ruleAppliesToDay(String rule, int weekday) {
    final hasDayToken = RegExp(r'\b(Mo|Tu|We|Th|Fr|Sa|Su)\b').hasMatch(rule);
    if (!hasDayToken) return _containsTimeRange(rule);

    final dayPart = rule.split(RegExp(r'\d{1,2}:\d{2}')).first;
    final tokens = dayPart.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);

    for (final token in tokens) {
      final rangeMatch = RegExp(r'\b(Mo|Tu|We|Th|Fr|Sa|Su)\s*-\s*(Mo|Tu|We|Th|Fr|Sa|Su)\b').firstMatch(token);
      if (rangeMatch != null) {
        final start = _dayNumber(rangeMatch.group(1)!);
        final end = _dayNumber(rangeMatch.group(2)!);
        if (_weekdayInRange(weekday, start, end)) return true;
        continue;
      }

      final singleDays = RegExp(r'\b(Mo|Tu|We|Th|Fr|Sa|Su)\b').allMatches(token);
      for (final match in singleDays) {
        if (_dayNumber(match.group(1)!) == weekday) return true;
      }
    }

    return false;
  }

  List<_TimeRange> _extractRanges(String rule) {
    final matches = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})').allMatches(rule);
    return matches.map((match) {
      final start = _parseTime(match.group(1)!);
      var end = _parseTime(match.group(2)!);
      if (end <= start) end += 24 * 60;
      return _TimeRange(start, end);
    }).toList();
  }

  bool _containsTimeRange(String value) => RegExp(r'\d{1,2}:\d{2}\s*-\s*\d{1,2}:\d{2}').hasMatch(value);

  int _parseTime(String value) {
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _formatMinutes(int minutes) {
    final normalized = minutes % (24 * 60);
    final h = (normalized ~/ 60).toString().padLeft(2, '0');
    final m = (normalized % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _remainingText(int minutes) {
    if (minutes <= 0) return 'Zatvara uskoro';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return 'Zatvara za $mins min';
    if (mins == 0) return 'Otvoreno još $hours h';
    return 'Otvoreno još $hours h $mins min';
  }

  bool _weekdayInRange(int day, int start, int end) {
    if (start <= end) return day >= start && day <= end;
    return day >= start || day <= end;
  }

  int _dayNumber(String token) {
    switch (token) {
      case 'Mo':
        return DateTime.monday;
      case 'Tu':
        return DateTime.tuesday;
      case 'We':
        return DateTime.wednesday;
      case 'Th':
        return DateTime.thursday;
      case 'Fr':
        return DateTime.friday;
      case 'Sa':
        return DateTime.saturday;
      case 'Su':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Ponedjeljak';
      case DateTime.tuesday:
        return 'Utorak';
      case DateTime.wednesday:
        return 'Srijeda';
      case DateTime.thursday:
        return 'Četvrtak';
      case DateTime.friday:
        return 'Petak';
      case DateTime.saturday:
        return 'Subota';
      case DateTime.sunday:
        return 'Nedjelja';
      default:
        return 'Uskoro';
    }
  }
}

class _TimeRange {
  const _TimeRange(this.start, this.end);

  final int start;
  final int end;

  bool contains(int minutes) => minutes >= start && minutes < end;
}
