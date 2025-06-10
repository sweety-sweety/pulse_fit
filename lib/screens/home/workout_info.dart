import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/domain/exercise.dart';
import 'package:pulse_fit/services/database.dart';
import 'package:pulse_fit/screens/exercise_detail.dart';
import 'package:pulse_fit/svg/models.dart';
import 'package:pulse_fit/svg/svg_painter.dart';
import 'package:pulse_fit/svg/utils.dart';

class WorkoutInfoPage extends StatefulWidget {
  final Workout workout;

  const WorkoutInfoPage({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutInfoPageState createState() => _WorkoutInfoPageState();
}

class _WorkoutInfoPageState extends State<WorkoutInfoPage> {
  late List<Exercise> exercises;
  final DatabaseService _databaseService = DatabaseService();
  List<PathSvgItem>? _muscleItems;
  Size? _muscleSize;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    exercises = widget.workout.exercises;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadWorkoutProgress(),
        _loadMuscleImage(),
      ]);
    } catch (e) {
      print("Ошибка загрузки данных: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWorkoutProgress() async {
    final savedExercises = await _databaseService.loadWorkoutProgress(widget.workout.id);
    if (savedExercises.isNotEmpty) {
      setState(() => exercises = savedExercises);
    }
  }

  Future<void> _loadMuscleImage() async {
    try {
      final vectorImage = await getVectorImage(context, 'assets/muscles.svg');
      final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

      final items = vectorImage.items.asMap().map((i, item) {
        final isTargeted = widget.workout.targetedMuscles.contains(i);
        final isBackground = item.fill == Colors.white;

        return MapEntry(
          i,
          item.copyWith(
            originalFill: item.fill,
            fill: isBackground && isDarkTheme
                ? Theme.of(context).cardColor
                : isTargeted && item.fill != Colors.white && item.fill != Theme.of(context).cardColor
                ? _getMuscleColor(widget.workout.difficulty)
                : item.fill,
          ),
        );
      }).values.toList();

      setState(() {
        _muscleItems = items;
        _muscleSize = vectorImage.size;
      });
    } catch (e) {
      print("Ошибка загрузки изображения мышц: $e");
    }
  }

  Color _getMuscleColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildMuscleImage() {
    if (_muscleItems == null || _muscleSize == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Задействованные мышцы:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
              ),
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 2.0,
                child: Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _muscleSize!.width,
                      height: _muscleSize!.height,
                      child: Stack(
                        children: [
                          for (int index = 0; index < _muscleItems!.length; index++)
                            SvgPainterImage(
                              item: _muscleItems![index],
                              size: _muscleSize!,
                              onTap: () {},
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Цель: ${widget.workout.goal}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Тип тренировки: ${widget.workout.workoutType.toString().split('.').last}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Сложность: ${widget.workout.difficulty.toString().split('.').last}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children: [
                    _buildTableCell("Упражнения"),
                    _buildTableCell("Калории"),
                    _buildTableCell("Время"),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell("${widget.workout.exercises.length}"),
                    _buildTableCell("${widget.workout.caloriesBurned}"),
                    _buildTableCell("${widget.workout.duration} мин"),
                  ],
                ),
              ],
            ),
            if (widget.workout.equipment.where((e) => e.trim().isNotEmpty).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Оборудование: ${widget.workout.equipment.join(', ')}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
          ],
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildExerciseCards() {
    return List.generate(exercises.length, (index) {
      final exercise = exercises[index];
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            exercise.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: (exercise.reps != 0 && exercise.sets != 0)
              ? Text("${exercise.sets} x ${exercise.reps} повторений")
              : (exercise.seconds != 0 && exercise.reps != 0)
              ? Text("${exercise.seconds} сек x ${exercise.reps} повторений")
              : Text("${exercise.seconds} сек"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailPage(exercise: exercise),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Автор: ${widget.workout.author}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildWorkoutInfoCard(),
              const SizedBox(height: 16),
              _buildMuscleImage(),
              const SizedBox(height: 16),
              Text(
                "Упражнения:",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildExerciseCards(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
