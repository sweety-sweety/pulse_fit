import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/exercise.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise;

  ExerciseDetailPage({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Видео или изображение группы мышц
              Center(
                child: exercise.videoUrl.isNotEmpty
                    ? Container(
                  height: 200,
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.play_circle_fill, size: 50, color: Colors.blue)),
                )
                    : exercise.muscleGroupImage.isNotEmpty
                    ? Image.network(exercise.muscleGroupImage, height: 200, fit: BoxFit.cover)
                    : SizedBox.shrink(),
              ),
              SizedBox(height: 16),
              Text(
                "Описание:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                exercise.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Характеристики упражнения:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (exercise.reps > 0) Text("Повторения: ${exercise.reps}", style: TextStyle(fontSize: 16)),
              if (exercise.sets > 0) Text("Подходы: ${exercise.sets}", style: TextStyle(fontSize: 16)),
              if (exercise.weight > 0) Text("Вес: ${exercise.weight} кг", style: TextStyle(fontSize: 16)),
              if (exercise.seconds > 0) Text("Время выполнения: ${exercise.seconds} сек", style: TextStyle(fontSize: 16)),
              if (exercise.goal.isNotEmpty) Text("Цель: ${exercise.goal}", style: TextStyle(fontSize: 16)),
              if (exercise.type.isNotEmpty) Text("Тип: ${exercise.type}", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
