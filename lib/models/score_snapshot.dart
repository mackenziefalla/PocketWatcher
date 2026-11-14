/// The user's PocketWatcher Score on a given day.
class ScoreSnapshot {
  final DateTime date;
  final int score;

  const ScoreSnapshot({
    required this.date,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'score': score,
    };
  }

  factory ScoreSnapshot.fromMap(Map<String, dynamic> map) {
    return ScoreSnapshot(
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      score: (map['score'] as num?)?.toInt() ?? 0,
    );
  }
}