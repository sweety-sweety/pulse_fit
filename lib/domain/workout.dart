import 'dart:convert';

import 'package:pulse_fit/domain/exercise.dart';

enum Difficulty { easy, medium, hard }
enum WorkoutType { strength, cardio, hiit, yoga }

class Workout {
  final String id;
  final String title;
  final String description;
  final List<int> targetedMuscles;
  final int duration;
  final int caloriesBurned;
  List<Exercise> exercises;
  final String author;
  final Difficulty difficulty;
  final WorkoutType workoutType;
  final List<String> equipment;
  final String goal;
  bool _isCompleted;
  double _progress;
  bool _isDraft;
  bool _isFavorite;
  DateTime _scheduledDate;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.targetedMuscles,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
    required this.author,
    required this.difficulty,
    required this.workoutType,
    required this.equipment,
    required this.goal,
    bool isCompleted = false,
    double progress = 0.0,
    bool isDraft = true,
    bool isFavorite = false,
    DateTime? scheduledDate,
  })  : _isCompleted = isCompleted,
        _progress = progress,
        _isDraft = isDraft,
        _isFavorite = isFavorite,
        _scheduledDate = scheduledDate ?? DateTime.now();

  bool get isCompleted => _isCompleted;
  double get progress => _progress;
  bool get isDraft => _isDraft;
  bool get isFavorite => _isFavorite;
  DateTime get scheduledDate => _scheduledDate;

  set isCompleted(bool value) {
    _isCompleted = value;
  }

  set progress(double value) {
    _progress = value.clamp(0.0, 1.0);
  }

  set isDraft(bool value) {
    _isDraft = value;
  }

  set isFavorite(bool value) {
    _isFavorite = value;
  }

  set scheduledDate(DateTime value) {
    _scheduledDate = value;
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    try {
      return Workout(
        id: json['id'] ?? '', // Защита от null
        title: json['title'] ?? 'Без названия',
        description: json['description'] ?? '',
        targetedMuscles: (json['targetedMuscles'] is String)
            ? List<int>.from(List<dynamic>.from(jsonDecode(json['targetedMuscles'])))
            : List<int>.from(json['targetedMuscles'] ?? []),
        duration: (json['duration'] ?? 0) as int,
        caloriesBurned: (json['caloriesBurned'] ?? 0) as int,
        exercises: (json['exercises'] as List?)?.map((e) => Exercise.fromJson(e)).toList() ?? [],
        author: json['author'] ?? 'Неизвестный',
        difficulty: Difficulty.values.firstWhere(
              (e) => e.toString() == 'Difficulty.${json['difficulty']}',
          orElse: () => Difficulty.easy,
        ),
        workoutType: WorkoutType.values.firstWhere(
              (e) => e.toString() == 'WorkoutType.${json['workoutType']}',
          orElse: () => WorkoutType.cardio,
        ),
        equipment: List<String>.from(json['equipment'] ?? []),
        goal: json['goal'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        progress: (json['progress'] ?? 0.0).toDouble(),
        isDraft: json['isDraft'] ?? true,
        isFavorite: json['isFavorite'] ?? false,
        scheduledDate: json.containsKey('scheduledDate')
            ? DateTime.tryParse(json['scheduledDate']) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print("Ошибка в fromJson(): $e");
      throw Exception("Ошибка при разборе тренировки: $e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetedMuscles': targetedMuscles,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(), // Assuming Exercise class has a toJson method
      'author': author,
      'difficulty': difficulty.toString().split('.').last,
      'workoutType': workoutType.toString().split('.').last,
      'equipment': equipment,
      'goal': goal,
      'isCompleted': isCompleted,
      'progress': progress,
      'isDraft': isDraft,
      'isFavorite': isFavorite,
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }

  // copyWith method
  Workout copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? targetedMuscles,
    int? duration,
    int? caloriesBurned,
    List<Exercise>? exercises,
    String? author,
    Difficulty? difficulty,
    WorkoutType? workoutType,
    List<String>? equipment,
    String? goal,
    bool? isCompleted,
    double? progress,
    bool? isDraft,
    bool? isFavorite,
    DateTime? scheduledDate,
  }) {
    return Workout(
      id: id ?? this.id, // The ID remains the same as this is an immutable field.
      title: title ?? this.title,
      description: description ?? this.description,
      targetedMuscles: targetedMuscles ?? this.targetedMuscles,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exercises: exercises ?? this.exercises,
      author: author ?? this.author,
      difficulty: difficulty ?? this.difficulty,
      workoutType: workoutType ?? this.workoutType,
      equipment: equipment ?? this.equipment,
      goal: goal ?? this.goal,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      isDraft: isDraft ?? this.isDraft,
      isFavorite: isFavorite ?? this.isFavorite,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}
