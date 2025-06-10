import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/screens/workouts/workout_detail.dart';
import 'package:pulse_fit/services/database.dart';

class MyWorkoutList extends StatefulWidget {
  final List<Workout> workouts;

  MyWorkoutList({required this.workouts});

  @override
  _MyWorkoutListState createState() => _MyWorkoutListState();
}

class _MyWorkoutListState extends State<MyWorkoutList> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, double> progressMap = {}; // Хранит прогресс для каждого воркаута

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // Загружает прогресс из базы данных
  Future<void> _loadProgress() async {
    Map<String, double> newProgressMap = {};
    for (var workout in widget.workouts) {
      double progress = await _calculateProgress(workout);
      newProgressMap[workout.id] = progress;
    }
    setState(() {
      progressMap = newProgressMap;
    });
  }

  // Функция для получения цвета в зависимости от сложности тренировки
  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.amber;
      case Difficulty.hard:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Функция для расчета прогресса с учетом данных из базы
  Future<double> _calculateProgress(Workout workout) async {
    List<Exercise> savedExercises = await _databaseService.loadWorkoutProgress(workout.id);
    if (savedExercises.isEmpty) return 0.0;

    int completedExercises = savedExercises.where((e) => e.isCompleted).length;
    return completedExercises / savedExercises.length;
  }

  // Функция для получения цвета прогресса в зависимости от процента
  Color _getProgressColor(double progress) {
    if (progress < 0.26) {
      return Colors.red;
    } else if (progress < 0.51) {
      return Colors.orange;
    } else if (progress < 0.76) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  // Метод для получения цвета по типу тренировки
  Color _getWorkoutTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.cardio:
        return Colors.blue;
      case WorkoutType.strength:
        return Colors.pink;
      case WorkoutType.hiit:
        return Colors.purple;
      case WorkoutType.yoga:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.workouts.length,
      itemBuilder: (context, index) {
        final workout = widget.workouts[index];
        double progress = progressMap[workout.id] ?? 0.0;

        return GestureDetector(
          onTap: () async {
            // Переход на экран с деталями тренировки
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutDetailPage(workout: workout),
              ),
            );
            _loadProgress(); // Обновляем прогресс после возвращения
          },
          child: Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 10,
                    height: 80,
                    color: _getDifficultyColor(workout.difficulty),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${workout.exercises.length} упражнений, ${workout.duration} мин",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          workout.workoutType.name,
                          style: TextStyle(fontSize: 14, color: _getWorkoutTypeColor(workout.workoutType)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: DashedCircularProgressBar.aspectRatio(
                      aspectRatio: 1,
                      progress: progress * 100,
                      startAngle: 225,
                      sweepAngle: 270,
                      foregroundColor: _getProgressColor(progress),
                      backgroundColor: const Color(0xffeeeeee),
                      foregroundStrokeWidth: 15,
                      backgroundStrokeWidth: 15,
                      animation: true,
                      seekSize: 6,
                      seekColor: const Color(0xffeeeeee),
                      child: Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
