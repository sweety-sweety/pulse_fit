import 'package:flutter/material.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/screens/workouts/workout_detail.dart';
import 'package:pulse_fit/services/database.dart';
import 'package:pulse_fit/components/my_workout_list.dart'; // Импортируем компонент MyWorkoutList

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<String> favoriteWorkoutIds = []; // Список идентификаторов избранных тренировок
  List<Workout> favoriteWorkouts = []; // Список объектов Workout
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteWorkouts();
  }

  Future<void> _loadFavoriteWorkouts() async {
    try {
      _databaseService.getFavoriteWorkouts().listen((workoutIds) {
        setState(() {
          favoriteWorkoutIds = workoutIds;
        });
        _loadWorkoutsDetails();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки избранных тренировок: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadWorkoutsDetails() async {
    List<Workout> workouts = [];
    for (String workoutId in favoriteWorkoutIds) {
      try {
        final workout = await _databaseService.getWorkoutById(workoutId);
        workouts.add(workout);
      } catch (e) {
        print('Ошибка при загрузке тренировки: $e');
      }
    }
    setState(() {
      favoriteWorkouts = workouts;
      isLoading = false;
    });
  }

  void _showChat() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ChatBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои тренировки'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteWorkouts.isEmpty
          ? Center(child: Text('Нет избранных тренировок'))
          : MyWorkoutList(workouts: favoriteWorkouts), // Используем MyWorkoutList
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chat',
            onPressed: _showChat,
            backgroundColor: Colors.green,
            child: Icon(Icons.chat, color: Colors.white),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'addWorkout',
            onPressed: () {
              Navigator.pushNamed(context, '/addWorkout');
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ChatBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Чат с тренером", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _chatBubble("Привет! Мне нужна помощь.", true),
                _chatBubble("Привет! Как я могу помочь?", false),
                _chatBubble("Мне нужно больше информации о тренировке.", true),
                _chatBubble("Конечно! Я помогу тебе с этим.",false),
                // Можно добавить больше сообщений
              ],
            ),
          ),
          _chatInputField(),
        ],
      ),
    )
    );
  }

  Widget _chatBubble(String message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(color: isSender ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _chatInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Введите сообщение...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Добавить отправку сообщения
            },
          ),
        ],
      ),
    );
  }
}
