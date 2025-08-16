class LeaderboardEntry {
  final String userId;
  final String? userName;
  final int score;
  final String categoryId;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.score,
    required this.categoryId,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id) {
    return LeaderboardEntry(
      userId: map['userId'] ?? id,
      userName:
          map['userName'], // optional: you can store userName in quizHistory
      score: map['score'] ?? 0,
      categoryId: map['categoryId'] ?? '',
    );
  }
}
