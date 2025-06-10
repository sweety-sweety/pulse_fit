import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/workout.dart';

class WorkoutList extends StatelessWidget {
  final List<Workout> workouts;
  final List<String> favoriteWorkouts;
  final Function(String) onToggleFavorite;
  final Function(Workout) onWorkoutTap;

  WorkoutList({
    required this.workouts,
    required this.favoriteWorkouts,
    required this.onToggleFavorite,
    required this.onWorkoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        bool isFavorite = favoriteWorkouts.contains(workout.id);

        return GestureDetector(
          onTap: () => onWorkoutTap(workout), // Открытие WorkoutInfoPage
          child: Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                            SizedBox(height: 4),
                            Text(
                              "Автор: ${workout.author}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => onToggleFavorite(workout.id!),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTag(
                        workout.difficulty.name,
                        _getDifficultyColor(workout.difficulty),
                      ),
                      _buildTag(
                        workout.workoutType.name,
                        _getWorkoutTypeColor(workout.workoutType),
                      ),
                      _buildTag("${workout.duration} мин", Colors.blueGrey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Метод для получения цвета по сложности
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
