import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/services/auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _workoutsCollection => _db.collection('workouts');
  CollectionReference get _usersCollection => _db.collection('users');

  // Добавление тренировки
  Future<void> addWorkout(Workout workout) async {
    try {
      await _workoutsCollection.add(workout.toJson());
    } catch (e) {
      throw Exception('Ошибка при добавлении тренировки: $e');
    }
  }

  // Получение списка тренировок
  Stream<List<Workout>> getWorkouts() {
    return _workoutsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          return Workout.fromJson(data).copyWith(id: doc.id);
        } else {
          throw Exception('Ошибка загрузки данных тренировки: документ пустой или неверного формата.');
        }
      }).toList();
    });
  }

  // Обновление тренировки
  Future<void> updateWorkout(String workoutId, Workout workout) async {
    try {
      await _workoutsCollection.doc(workoutId).update(workout.toJson());
    } catch (e) {
      throw Exception('Ошибка при обновлении тренировки: $e');
    }
  }

  // Удаление тренировки
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _workoutsCollection.doc(workoutId).delete();
    } catch (e) {
      throw Exception('Ошибка при удалении тренировки: $e');
    }
  }

  // Получение тренировок пользователя
  Stream<List<Workout>> getUserWorkouts(String userId) {
    return _workoutsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Workout.fromJson(doc.data()! as Map<String, dynamic>)).toList();
    });
  }

  Future<Workout> getWorkoutById(String workoutId) async {
    try {
      final doc = await _workoutsCollection.doc(workoutId).get();
      if (doc.exists) {
        return Workout.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Тренировка не найдена');
      }
    } catch (e) {
      throw Exception('Ошибка при загрузке тренировки: $e');
    }
  }

  // ✅ Получение списка избранных тренировок пользователя
  Stream<List<String>> getFavoriteWorkouts() {
    String? userId = _authService.getCurrentUserId();
    if (userId == null) return Stream.value([]);

    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
        if (data != null && data.containsKey('favorites')) {
          return List<String>.from(data['favorites']);
        }
      }
      return [];
    });
  }

  // ✅ Добавление/удаление тренировки в избранное
  Future<void> updateFavoriteWorkout(String workoutId, bool isFavorite) async {
    String? userId = _authService.getCurrentUserId();
    if (userId == null) return;

    DocumentReference userRef = _usersCollection.doc(userId);

    if (isFavorite) {
      await userRef.update({
        'favorites': FieldValue.arrayUnion([workoutId])
      });
    } else {
      await userRef.update({
        'favorites': FieldValue.arrayRemove([workoutId])
      });
      // ❗ Удаляем прогресс тренировки, если пользователь убирает её из избранного
      await userRef.update({
        'workout_progress.$workoutId': FieldValue.delete(),
      });
    }
  }

  Future<void> updateUserProfile(
      String userId,
      String name,
      int age,
      double weight,
      double height,
      String gender,
      ) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final weightEntry = {
      'date': DateTime.now().toIso8601String(),
      'weight': weight,
    };

    await userRef.set({
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'weightHistory': FieldValue.arrayUnion([weightEntry]), // добавление нового значения
    }, SetOptions(merge: true));
  }


  // ✅ Сохранение прогресса тренировки внутри профиля пользователя
  Future<void> saveWorkoutProgress(String workoutId, List<Exercise> exercises) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    List<Map<String, dynamic>> exercisesData = exercises.map((e) => e.toJson()).toList();

    await _usersCollection.doc(userId).update({
      'workout_progress.$workoutId': {
        'exercises': exercisesData,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    });
  }

  // ✅ Загрузка прогресса тренировки
  Future<List<Exercise>> loadWorkoutProgress(String workoutId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      if (data != null && data.containsKey('workout_progress') && data['workout_progress'][workoutId] != null) {
        List<dynamic> exercisesJson = data['workout_progress'][workoutId]['exercises'] ?? [];
        return exercisesJson.map((e) => Exercise.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<void> addCompletedWorkoutDate(
      String workoutId,
      String title,
      int caloriesBurned,
      DateTime date) async {

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("Ошибка: пользователь не авторизован");
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      List<dynamic> completedWorkouts = userDoc.data()?['completedWorkouts'] ?? [];

      // Ищем запись для этой тренировки
      int index = completedWorkouts.indexWhere((w) => w['id'] == workoutId);

      if (index != -1) {
        // Добавляем дату в существующую запись
        (completedWorkouts[index]['dates'] as List).add(date.toIso8601String());
      } else {
        // Создаем новую запись
        completedWorkouts.add({
          'id': workoutId,
          'title': title,
          'caloriesBurned': caloriesBurned,
          'dates': [date.toIso8601String()],
        });
      }

      await userRef.update({'completedWorkouts': completedWorkouts});
    }
  }
}