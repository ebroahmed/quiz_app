import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepository(this._firestore);

  Stream<List<LeaderboardEntry>> getLeaderboardByCategory(String categoryId) {
    return _firestore
        .collection("quizHistory")
        .where("categoryId", isEqualTo: categoryId)
        .orderBy("score", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LeaderboardEntry.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
