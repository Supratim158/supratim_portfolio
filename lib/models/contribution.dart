/// A single contribution data point for the heatmap.
class ContributionDay {
  final DateTime date;
  final int count;
  final int level; // 0-4 intensity
  final String color; // hex color from API

  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
    this.color = '',
  });

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    final count = json['contributionCount'] ?? json['count'] ?? 0;
    return ContributionDay(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      count: count,
      level: json['level'] ?? json['contributionLevel'] ?? _countToLevel(count),
      color: json['color'] ?? '',
    );
  }

  /// Map contribution count to a 0-4 level for heatmap coloring.
  static int _countToLevel(int count) {
    if (count == 0) return 0;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    if (count <= 5) return 3;
    return 4;
  }
}

/// Aggregated contribution data.
/// Parses the real API response format:
/// {user: {contributionsCollection: {contributionCalendar: {totalContributions, weeks: [...]}}}}
class ContributionData {
  final int totalContributions;
  final int currentStreak;
  final int longestStreak;
  final List<ContributionDay> days;
  final List<List<ContributionDay>> weeks;

  const ContributionData({
    required this.totalContributions,
    required this.currentStreak,
    required this.longestStreak,
    required this.days,
    required this.weeks,
  });

  factory ContributionData.fromJson(Map<String, dynamic> json) {
    // Navigate the nested structure:
    // json.user.contributionsCollection.contributionCalendar
    Map<String, dynamic>? calendar;

    if (json.containsKey('user')) {
      final user = json['user'] as Map<String, dynamic>?;
      final collection = user?['contributionsCollection'] as Map<String, dynamic>?;
      calendar = collection?['contributionCalendar'] as Map<String, dynamic>?;
    } else if (json.containsKey('contributionCalendar')) {
      calendar = json['contributionCalendar'] as Map<String, dynamic>?;
    } else {
      // Fallback: assume flat structure
      calendar = json;
    }

    final totalContributions = calendar?['totalContributions'] ?? json['total'] ?? 0;

    // Parse weeks → days
    final weeksList = (calendar?['weeks'] ?? json['weeks'] ?? []) as List;
    final allDays = <ContributionDay>[];
    final allWeeks = <List<ContributionDay>>[];

    for (final week in weeksList) {
      final weekDays = <ContributionDay>[];
      final contributionDays =
          (week['contributionDays'] ?? week['days'] ?? []) as List;
      for (final day in contributionDays) {
        final cd = ContributionDay.fromJson(day);
        weekDays.add(cd);
        allDays.add(cd);
      }
      allWeeks.add(weekDays);
    }

    // If no explicit streaks, compute from daily data
    final currentStreak = json['currentStreak'] ?? _computeCurrentStreak(allDays);
    final longestStreak = json['longestStreak'] ?? _computeLongestStreak(allDays);

    return ContributionData(
      totalContributions: totalContributions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      days: allDays,
      weeks: allWeeks,
    );
  }

  /// Compute current streak (consecutive days ending today with contributions > 0).
  static int _computeCurrentStreak(List<ContributionDay> days) {
    if (days.isEmpty) return 0;
    // Sort descending by date
    final sorted = List<ContributionDay>.from(days)
      ..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    for (final d in sorted) {
      if (d.count > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Compute longest streak of consecutive days with contributions > 0.
  static int _computeLongestStreak(List<ContributionDay> days) {
    if (days.isEmpty) return 0;
    final sorted = List<ContributionDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));
    int longest = 0;
    int current = 0;
    for (final d in sorted) {
      if (d.count > 0) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }
}
