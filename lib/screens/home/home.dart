import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pulse_fit/components/filter.dart';
import 'package:pulse_fit/domain/workout.dart';
import 'package:pulse_fit/screens/home/workout_info.dart';
import 'package:pulse_fit/services/database.dart';
import 'package:pulse_fit/services/auth.dart';
import 'package:pulse_fit/components/workout_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  List<Workout> workouts = [];
  List<Workout> filteredWorkouts = [];
  List<String> favoriteWorkouts = [];
  bool isLoading = true;
  String searchQuery = "";
  bool showFavoritesOnly = false;
  double minCalories = 0;
  double maxCalories = 1000;
  double minDuration = 0;
  double maxDuration = 120;
  List<String> selectedDifficulties = [];
  List<String> selectedWorkoutTypes = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _loadFavorites();
  }

  Future<void> _loadWorkouts() async {
    try {
      _databaseService.getWorkouts().listen((workoutList) {
        setState(() {
          workouts = workoutList;
          _filterWorkouts();
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки тренировок: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadFavorites() async {
    String? userId = _authService.getCurrentUserId();
    if (userId == null) return;

    _databaseService.getFavoriteWorkouts().listen((favorites) {
      setState(() {
        favoriteWorkouts = favorites;
        _filterWorkouts();
      });
    });
  }

  void _filterWorkouts() {
    setState(() {
      filteredWorkouts = workouts.where((workout) {
        bool matchesSearchQuery = searchQuery.isEmpty ||
            searchQuery.toLowerCase().split(' ').any((term) =>
            workout.title.toLowerCase().contains(term) ||
                workout.author.toLowerCase().contains(term));

        bool isFavorite = favoriteWorkouts.contains(workout.id);
        bool isNotDraft = workout.isDraft == false;
        bool matchesCalories = workout.caloriesBurned >= minCalories && workout.caloriesBurned <= maxCalories;
        bool matchesDuration = workout.duration >= minDuration && workout.duration <= maxDuration;
        bool matchesDifficulty = selectedDifficulties.isEmpty || selectedDifficulties.any((difficulty) => difficulty == workout.difficulty.name);
        bool matchesWorkoutType = selectedWorkoutTypes.isEmpty || selectedWorkoutTypes.any((type) => type == workout.workoutType.name);

        return matchesSearchQuery &&
            (!showFavoritesOnly || isFavorite) &&
            isNotDraft &&
            matchesCalories &&
            matchesDuration &&
            matchesDifficulty &&
            matchesWorkoutType;
      }).toList();
    });
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterDialog(
          showFavoritesOnly: showFavoritesOnly,
          minCalories: minCalories,
          maxCalories: maxCalories,
          minDuration: minDuration,
          maxDuration: maxDuration,
          selectedDifficulties: selectedDifficulties,
          selectedWorkoutTypes: selectedWorkoutTypes,
          onApply: (
              favoritesOnly,
              minCals,
              maxCals,
              minDur,
              maxDur,
              difficulties,
              workoutTypes,
              ) {
            setState(() {
              showFavoritesOnly = favoritesOnly;
              minCalories = minCals;
              maxCalories = maxCals;
              minDuration = minDur;
              maxDuration = maxDur;
              selectedDifficulties = List.from(difficulties);
              selectedWorkoutTypes = List.from(workoutTypes);
              _filterWorkouts();
            });
          },
        );
      },
    );
  }

  void _toggleFavorite(String workoutId) async {
    User? user = _authService.getCurrentUser();
    if (user == null) return;

    bool isFavorite = favoriteWorkouts.contains(workoutId);
    await _databaseService.updateFavoriteWorkout(workoutId, !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pulse Fitness')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Поиск (Название / Автор)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFiltersDialog,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  _filterWorkouts();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredWorkouts.isEmpty
                ? Center(child: Text('Ничего не найдено'))
                : WorkoutList(
              workouts: filteredWorkouts,
              favoriteWorkouts: favoriteWorkouts,
              onToggleFavorite: _toggleFavorite,
              onWorkoutTap: (workout) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutInfoPage(workout: workout),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
