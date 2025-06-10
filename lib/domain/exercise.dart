class Exercise {
  final String id;
  final String workoutId;
  final String videoUrl;
  final String name;
  final String description;
  final String muscleGroupImage;
  final int reps;
  final int sets;
  final int weight;
  final int seconds;
  final String goal;
  final String type;
  bool isCompleted;

  Exercise({
    required this.id,
    required this.workoutId,
    required this.videoUrl,
    required this.name,
    required this.description,
    required this.muscleGroupImage,
    this.reps = 0,
    this.sets = 0,
    this.weight = 0,
    this.seconds = 0,
    this.goal = "Общая физическая подготовка",
    this.type = "Базовое",
    this.isCompleted = false,
  });

  Exercise copyWith({bool? isCompleted}) {
    return Exercise(
      id: id,
      workoutId: workoutId,
      videoUrl: videoUrl,
      name: name,
      description: description,
      muscleGroupImage: muscleGroupImage,
      reps: reps,
      sets: sets,
      weight: weight,
      seconds: seconds,
      goal: goal,
      type: type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      workoutId: json['workoutId'],
      videoUrl: json['videoUrl'],
      name: json['name'],
      description: json['description'],
      muscleGroupImage: json['muscleGroupImage'],
      reps: json['reps'] ?? 0,
      sets: json['sets'] ?? 0,
      weight: json['weight'] ?? 0,
      seconds: json['seconds'] ?? 0,
      goal: json['goal'] ?? "Общая физическая подготовка",
      type: json['type'] ?? "Базовое",
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'videoUrl': videoUrl,
      'name': name,
      'description': description,
      'muscleGroupImage': muscleGroupImage,
      'reps': reps,
      'sets': sets,
      'weight': weight,
      'seconds': seconds,
      'goal': goal,
      'type': type,
      'isCompleted': isCompleted,
    };
  }
}
