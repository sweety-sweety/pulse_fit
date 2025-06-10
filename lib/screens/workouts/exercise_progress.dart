import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/services/database.dart';

class ExerciseProgressPage extends StatefulWidget {
  final String title;
  final int caloriesBurned;
  final Exercise exercise;
  final Function(Exercise) onExerciseCompleted;
  final List<Exercise> exercises;
  final int currentIndex;

  ExerciseProgressPage({
    required this.title,
    required this.caloriesBurned,
    required this.exercise,
    required this.onExerciseCompleted,
    required this.exercises,
    required this.currentIndex,
  });

  @override
  _ExerciseProgressPageState createState() => _ExerciseProgressPageState();
}

class _ExerciseProgressPageState extends State<ExerciseProgressPage> {
  final DatabaseService _databaseService = DatabaseService();
  Timer? _timer;
  int _remainingTime = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.exercise.seconds;
  }

  void _toggleTimer() {
    setState(() {
      if (_isTimerRunning) {
        _timer?.cancel();
      } else {
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (_remainingTime > 0) {
            setState(() {
              _remainingTime--;
            });
          } else {
            _timer?.cancel();
            _isTimerRunning = false;
          }
        });
      }
      _isTimerRunning = !_isTimerRunning;
    });
  }

  void _completeExercise() {
    // Обновляем упражнение, помечая его как выполненное
    widget.exercise.isCompleted = true;
    widget.onExerciseCompleted(widget.exercise);
    Navigator.pop(context);
  }

  Future<void> _nextExercise() async {
    // Обновляем упражнение, помечая его как выполненное
    widget.exercise.isCompleted = true;
    widget.onExerciseCompleted(widget.exercise);

    if (widget.currentIndex < widget.exercises.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseProgressPage(
            title: widget.title,
            caloriesBurned: widget.caloriesBurned,
            exercise: widget.exercises[widget.currentIndex + 1],
            onExerciseCompleted: widget.onExerciseCompleted,
            exercises: widget.exercises,
            currentIndex: widget.currentIndex + 1,
          ),
        ),
      );
    } else {
      DateTime now = DateTime.now();
      await _databaseService.addCompletedWorkoutDate(widget.exercise.workoutId,  widget.title, widget.caloriesBurned, now);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.exercise.videoUrl.isNotEmpty
                    ? Container(
                  height: 200,
                  color: Colors.black12,
                  child: Center(
                    child: Icon(Icons.play_circle_fill, size: 50, color: Colors.blue),
                  ),
                )
                    : widget.exercise.muscleGroupImage.isNotEmpty
                    ? Image.network(widget.exercise.muscleGroupImage, height: 200, fit: BoxFit.cover)
                    : SizedBox.shrink(),
              ),
              SizedBox(height: 16),
              Text(
                "Описание:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.exercise.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              if (widget.exercise.seconds > 0)
                Column(
                  children: [
                    Text(
                      "Оставшееся время:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$_remainingTime сек",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _toggleTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTimerRunning ? Colors.red : Colors.green,
                        ),
                        child: Text(_isTimerRunning ? "Остановить таймер" : "Запустить таймер"),
                      ),
                    ),
                  ],
                ),
              if (widget.exercise.seconds == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Повторений: ${widget.exercise.reps}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Подходов: ${widget.exercise.sets}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeExercise,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Завершить упражнение"),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextExercise,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("Следующее упражнение", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
