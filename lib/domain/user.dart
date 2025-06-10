class UserModel {
  final String uid;
  final String email;
  String name;
  int age;
  double weight;
  double height;
  String gender;
  String phone;
  String level;

  UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.age = 0,
    this.weight = 0.0,
    this.height = 0.0,
    this.gender = '',
    this.phone = '',
    this.level = 'Начинающий',
  });

  // Преобразование в Map (для Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'phone': phone,
      'level': level,
    };
  }

  // Создание объекта из Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      level: map['level'] ?? 'Начинающий',
    );
  }

 void updateLevel(int completedWorkouts) {
    if (completedWorkouts >= 100) {
      level = 'Эксперт';
    } else if (completedWorkouts >= 50) {
      level = 'Продвинутый';
    } else if (completedWorkouts >= 10) {
      level = 'Средний';
    } else {
      level = 'Начинающий';
    }
  }
}
