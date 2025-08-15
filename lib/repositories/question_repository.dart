import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore;

  QuestionRepository(this._firestore);

  Stream<List<Question>> getQuestionsByCategory(String categoryId) {
    return _firestore
        .collection('questions')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Question.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
}
