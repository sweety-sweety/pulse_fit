import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/exercise.dart';

class AddExercisePage extends StatefulWidget {
  final String workoutId; // Добавляем переменную для workoutId

  AddExercisePage({
    required this.workoutId,
  }); // Конструктор с параметром workoutId

  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController muscleGroupImageController =
      TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController secondsController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveExercise() async {
    setState(() => isLoading = true);

    final exercise = Exercise(
      id: _db.collection('exercises').doc().id,
      workoutId: widget.workoutId,
      videoUrl: videoUrlController.text.trim(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      muscleGroupImage: muscleGroupImageController.text.trim(),
      reps: int.tryParse(repsController.text.trim()) ?? 0,
      sets: int.tryParse(setsController.text.trim()) ?? 0,
      weight: int.tryParse(weightController.text.trim()) ?? 0,
      seconds: int.tryParse(secondsController.text.trim()) ?? 0,
      goal:
          goalController.text.trim().isNotEmpty
              ? goalController.text.trim()
              : "Общая физическая подготовка",
      type:
          typeController.text.trim().isNotEmpty
              ? typeController.text.trim()
              : "Базовое",
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить упражнение')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: videoUrlController,
                  decoration: InputDecoration(
                    labelText: 'Ссылка на видео',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // увеличиваем количество строк для описания
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(
                    labelText: 'Повторения',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: setsController,
                  decoration: InputDecoration(
                    labelText: 'Подходы',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Используемый вес (кг)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: secondsController,
                  decoration: InputDecoration(
                    labelText: 'Время выполнения (сек)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: goalController,
                  decoration: InputDecoration(
                    labelText: 'Цель',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Тип упражнения',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveExercise,
                  child: Text('Сохранить упражнение'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
