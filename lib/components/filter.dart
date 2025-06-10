import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final bool showFavoritesOnly;
  final double minCalories;
  final double maxCalories;
  final double minDuration;
  final double maxDuration;
  final List<String> selectedDifficulties;
  final List<String> selectedWorkoutTypes;
  final Function(bool, double, double, double, double, List<String>, List<String>) onApply;

  FilterDialog({
    required this.showFavoritesOnly,
    required this.minCalories,
    required this.maxCalories,
    required this.minDuration,
    required this.maxDuration,
    required this.selectedDifficulties,
    required this.selectedWorkoutTypes,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool showFavoritesOnly;
  late double minCalories;
  late double maxCalories;
  late double minDuration;
  late double maxDuration;
  late List<String> selectedDifficulties;
  late List<String> selectedWorkoutTypes;

  @override
  void initState() {
    super.initState();
    showFavoritesOnly = widget.showFavoritesOnly;
    minCalories = widget.minCalories;
    maxCalories = widget.maxCalories;
    minDuration = widget.minDuration;
    maxDuration = widget.maxDuration;
    selectedDifficulties = List.from(widget.selectedDifficulties);
    selectedWorkoutTypes = List.from(widget.selectedWorkoutTypes);
  }

  void _toggleDifficulty(String difficulty) {
    setState(() {
      if (selectedDifficulties.contains(difficulty)) {
        selectedDifficulties.remove(difficulty);
      } else {
        selectedDifficulties.add(difficulty);
      }
    });
  }

  void _toggleWorkoutType(String workoutType) {
    setState(() {
      if (selectedWorkoutTypes.contains(workoutType)) {
        selectedWorkoutTypes.remove(workoutType);
      } else {
        selectedWorkoutTypes.add(workoutType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Фильтры'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text("Только избранные"),
              value: showFavoritesOnly,
              onChanged: (value) => setState(() => showFavoritesOnly = value),
            ),
            SizedBox(height: 16),
            Text("Калории: ${minCalories.toInt()} - ${maxCalories.toInt()}"),
            RangeSlider(
              min: 0,
              max: 1000,
              values: RangeValues(minCalories, maxCalories),
              onChanged: (values) => setState(() {
                minCalories = values.start;
                maxCalories = values.end;
              }),
            ),
            SizedBox(height: 16),
            Text("Длительность (мин): ${minDuration.toInt()} - ${maxDuration.toInt()}"),
            RangeSlider(
              min: 0,
              max: 120,
              values: RangeValues(minDuration, maxDuration),
              onChanged: (values) => setState(() {
                minDuration = values.start;
                maxDuration = values.end;
              }),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Сложность", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Column(
              children: ['easy', 'medium', 'hard'].map((difficulty) {
                return CheckboxListTile(
                  title: Text(difficulty),
                  value: selectedDifficulties.contains(difficulty),
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleDifficulty(difficulty);
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Тип тренировки", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Column(
              children: ['strength', 'cardio', 'hiit', 'yoga'].map((workoutType) {
                return CheckboxListTile(
                  title: Text(workoutType),
                  value: selectedWorkoutTypes.contains(workoutType),
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleWorkoutType(workoutType);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              showFavoritesOnly = false;
              minCalories = 0;
              maxCalories = 1000;
              minDuration = 0;
              maxDuration = 120;
              selectedDifficulties = [];
              selectedWorkoutTypes = [];
            }
            );
            widget.onApply(
              showFavoritesOnly,
              minCalories,
              maxCalories,
              minDuration,
              maxDuration,
              selectedDifficulties,
              selectedWorkoutTypes,
            );
            Navigator.pop(context);
          },
          child: Text('Сбросить', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(width: 8),
        TextButton(
          onPressed: () {
            widget.onApply(
              showFavoritesOnly,
              minCalories,
              maxCalories,
              minDuration,
              maxDuration,
              selectedDifficulties,
              selectedWorkoutTypes,
            );
            Navigator.pop(context);
          },
          child: Text('Применить', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
