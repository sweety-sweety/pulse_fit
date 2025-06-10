import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/domain/user.dart';
import 'package:pulse_fit/screens/workouts/add_exercise.dart';
import 'package:pulse_fit/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'muscle_selection.dart';

class AddWorkoutPage extends StatefulWidget {
  @override
  _AddWorkoutPageState createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController equipmentController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  List<Exercise> exercises = [];
  bool isDraft = true;
  bool isLoading = false;
  Difficulty selectedDifficulty = Difficulty.medium;
  WorkoutType selectedWorkoutType = WorkoutType.strength;
  List<int> selectedMuscleIndexes = [];

  Future<void> _saveWorkout() async {
    setState(() => isLoading = true);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Пользователь не авторизован')));
      setState(() => isLoading = false);
      return;
    }

    // Загружаем данные пользователя
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
    UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

    // Генерируем ID для тренировки
    final workoutId = _db.collection('workouts').doc().id;

    final workout = Workout(
      id: workoutId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      duration: int.tryParse(durationController.text.trim()) ?? 0,
      caloriesBurned: int.tryParse(caloriesController.text.trim()) ?? 0,
      exercises: exercises,
      isDraft: isDraft,
      author: user.name,
      scheduledDate: DateTime.now(),
      difficulty: selectedDifficulty,
      workoutType: selectedWorkoutType,
      equipment: equipmentController.text.split(','),
      goal: goalController.text.trim(),
      targetedMuscles: selectedMuscleIndexes,
    );

    try {
      // Сохраняем тренировку в базе данных как черновик
      await DatabaseService().addWorkout(workout);

      // Переход на экран добавления упражнений с передачей ID тренировки
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExercisePage(workoutId: workoutId),
        ),
      );

      // Если упражнения были добавлены, добавляем их к текущей тренировке
      if (result != null) {
        setState(() => exercises.add(result));
      }

      setState(() => isLoading = false);
      Navigator.pop(
        context,
      ); // Возвращаемся на предыдущий экран после добавления упражнений
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить тренировку')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Название тренировки',
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
                ElevatedButton(
                  onPressed: () async {
                    print(selectedMuscleIndexes);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MuscleSelectionPage(
                              resetOnStart: selectedMuscleIndexes.isEmpty,
                              initialSelection: selectedMuscleIndexes,
                            ),
                      ),
                    );
                    if (result != null && result is List<int>) {
                      setState(() {
                        selectedMuscleIndexes = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text('Выбрать мышцы'),
                ),
                if (selectedMuscleIndexes.isNotEmpty)
                  Text('Выбрано мышц: ${selectedMuscleIndexes.length}'),
                SizedBox(height: 10),
                TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    labelText: 'Длительность (мин)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Калории (ккал)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedDifficulty,
                  onChanged:
                      (value) => setState(() => selectedDifficulty = value!),
                  items:
                      Difficulty.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.toString().split('.').last),
                            ),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText: 'Сложность',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  value: selectedWorkoutType,
                  onChanged:
                      (value) => setState(() => selectedWorkoutType = value!),
                  items:
                      WorkoutType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.toString().split('.').last),
                            ),
                          )
                          .toList(),
                  decoration: InputDecoration(
                    labelText: 'Тип тренировки',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: equipmentController,
                  decoration: InputDecoration(
                    labelText: 'Инвентарь (через запятую)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: goalController,
                  decoration: InputDecoration(
                    labelText: 'Цель тренировки',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Передаем workoutId в AddExercisePage
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddExercisePage(
                              workoutId: _db.collection('workouts').doc().id,
                            ),
                      ),
                    );
                    if (result != null) {
                      setState(() => exercises.add(result));
                    }
                  },
                  child: Text('Добавить упражнение'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.reps} повторений, ${exercise.sets} подходов, ${exercise.weight} кг',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => setState(() => exercises.removeAt(index)),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        // ElevatedButton(
                        //   onPressed: _saveWorkout,
                        //   child: Text('Сохранить как черновик'),
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.white,
                        //     backgroundColor: Colors.blue,
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => isDraft = false);
                            _saveWorkout();
                          },
                          child: Text('Опубликовать'),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
