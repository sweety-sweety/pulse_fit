import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse_fit/domain/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Поток для отслеживания состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Регистрация пользователя
  Future<UserModel?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Пароль должен быть не менее 6 символов.',
        );
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,  // Теперь email добавляется в модель пользователя
          name: '',
          age: 0,
          weight: 0.0,
          height: 0.0,
          gender: '',
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Ошибка регистрации: ${e.toString()}',
      );
    }
  }

  // Вход пользователя
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        return await getUserProfile(user.uid);
      }
      return null;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'login-failed',
        message: 'Ошибка входа: ${e.toString()}',
      );
    }
  }

  // Выход пользователя
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Получение данных пользователя из Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Ошибка получения профиля: ${e.toString()}');
    }
  }

  // Обновление профиля пользователя
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Ошибка обновления профиля: ${e.toString()}');
    }
  }

  // Получение текущего пользователя
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ✅ Метод для получения `userId`
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  String getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email ?? ''; // Возвращает почту или пустую строку
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
