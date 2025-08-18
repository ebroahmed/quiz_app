import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/quiz_history_model.dart';

class QuizHistoryRepository {
  final FirebaseFirestore _firestore;

  QuizHistoryRepository(this._firestore);

  Stream<List<QuizHistoryModel>> getUserHistory(String userId) {
    return _firestore
        .collection("quiz_results")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => QuizHistoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
