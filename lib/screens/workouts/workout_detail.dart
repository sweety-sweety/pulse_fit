import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/screens/exercise_detail.dart';
import 'package:pulse_fit/screens/workouts/exercise_progress.dart';
import 'package:pulse_fit/services/database.dart';

class WorkoutDetailPage extends StatefulWidget {
  final Workout workout;

  WorkoutDetailPage({required this.workout});

  @override
  _WorkoutDetailPageState createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<Exercise> exercises = [];
  bool isStarted = false;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadWorkoutProgress();
  }

  // Загрузка прогресса из Firebase
  Future<void> _loadWorkoutProgress() async {
    List<Exercise> savedExercises = await _databaseService.loadWorkoutProgress(
      widget.workout.id,
    );
    setState(() {
      exercises =
          savedExercises.isNotEmpty ? savedExercises : widget.workout.exercises;
      isStarted = exercises.any((e) => e.isCompleted);
    });
  }

  // Начать или продолжить тренировку
  void _startOrContinueWorkout() {
    if (exercises.every((e) => e.isCompleted)) {
      // Если все упражнения выполнены — начинаем заново
      setState(() {
        for (var exercise in exercises) {
          exercise.isCompleted = false;
        }
        isStarted = false;
      });

      _databaseService.saveWorkoutProgress(widget.workout.id, exercises);
    }

    setState(() {
      isStarted = true;
    });

    // Найти первое невыполненное упражнение
    Exercise? nextExercise = exercises.firstWhere(
      (e) => !e.isCompleted,
      orElse: () => exercises.first, // Если все выполнены, берем первое
    );

    // Переход на экран упражнения
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExerciseProgressPage(
              title: widget.workout.title,
              caloriesBurned: widget.workout.caloriesBurned,
              exercises: exercises, // Список всех упражнений
              currentIndex: exercises.indexOf(
                nextExercise,
              ), // Индекс текущего упражнения
              exercise: nextExercise, // Передаем текущее упражнение
              onExerciseCompleted: (updatedExercise) {
                _updateExerciseProgress(updatedExercise);
              },
            ),
      ),
    );
  }

  // Обновление прогресса одного упражнения
  void _updateExerciseProgress(Exercise updatedExercise) {
    setState(() {
      int index = exercises.indexWhere((e) => e.id == updatedExercise.id);
      if (index != -1) {
        exercises[index] = updatedExercise;
      }
      isStarted = exercises.any((e) => e.isCompleted);
    });

    _databaseService.saveWorkoutProgress(widget.workout.id, exercises);
  }

  // Завершить всю тренировку
  void _completeWorkout() async {
    setState(() {
      for (var exercise in exercises) {
        exercise.isCompleted = true;
      }
    });

    await _databaseService.saveWorkoutProgress(widget.workout.id, exercises);

    // Добавляем дату завершения
    DateTime now = DateTime.now();
    await _databaseService.addCompletedWorkoutDate(
      widget.workout.id,
      widget.workout.title,
      widget.workout.caloriesBurned,
      now,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Автор: ${widget.workout.author}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        children: [
                          TableRow(
                            children: [
                              _buildTableCell("Кол-во упражнений"),
                              _buildTableCell("Калорий сожжено"),
                              _buildTableCell("Время"),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell(
                                "${widget.workout.exercises.length}",
                              ),
                              _buildTableCell(
                                "${widget.workout.caloriesBurned}",
                              ),
                              _buildTableCell("${widget.workout.duration} мин"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (widget.workout.equipment
                          .where((e) => e.trim().isNotEmpty)
                          .isNotEmpty)
                        Text(
                          "Оборудование: ${widget.workout.equipment.join(', ')}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Упражнения:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          exercise.name,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle:
                            exercise.reps == 0 && exercise.sets == 0
                                ? Text(
                                  "Время выполнения: ${exercise.seconds} сек",
                                )
                                : Text(
                                  "Повторений: ${exercise.reps}, Подходов: ${exercise.sets}",
                                ),
                        trailing: Icon(
                          exercise.isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color:
                              exercise.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ExerciseDetailPage(exercise: exercise),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startOrContinueWorkout,
                  child: Text(
                    exercises.every((e) => e.isCompleted)
                        ? "Начать заново"
                        : exercises.any((e) => e.isCompleted)
                        ? "Продолжить тренировку"
                        : "Начать тренировку",
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeWorkout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Закончить тренировку",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
