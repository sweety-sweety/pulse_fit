import 'package:flutter/material.dart';
import 'package:pulse_fit/services/database.dart'; // Импортируем DatabaseService

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final int initialAge;
  final double initialWeight;
  final double initialHeight;
  final String initialGender;
  final String userId; // Добавляем ID пользователя

  EditProfilePage({
    required this.initialName,
    required this.initialAge,
    required this.initialWeight,
    required this.initialHeight,
    required this.initialGender,
    required this.userId,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'Мужской';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _ageController.text = widget.initialAge.toString();
    _weightController.text = widget.initialWeight.toString();
    _heightController.text = (widget.initialHeight * 100).toStringAsFixed(0); // только целое число
    _gender = widget.initialGender;
  }

  // Метод для сохранения профиля
  void _saveProfile() async {
    String newName = _nameController.text;
    int newAge = int.tryParse(_ageController.text) ?? widget.initialAge;
    double newWeight = double.tryParse(_weightController.text) ?? widget.initialWeight;
    double newHeight = double.tryParse(_heightController.text) ?? widget.initialHeight * 100;

    // Обновляем данные пользователя в Firestore
    await DatabaseService().updateUserProfile(
      widget.userId,
      newName,
      newAge,
      newWeight,
      newHeight / 100, // возвращаем значение в метры
      _gender,
    );

    // Возвращаем обновленные данные на экран профиля
    Navigator.pop(context, {
      'name': newName,
      'age': newAge,
      'weight': newWeight,
      'height': newHeight / 100,
      'gender': _gender,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование профиля'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Имя',
                labelStyle: theme.textTheme.bodyLarge,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Возраст',
                labelStyle: theme.textTheme.bodyLarge,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Вес (кг)',
                labelStyle: theme.textTheme.bodyLarge,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Рост (см)',
                labelStyle: theme.textTheme.bodyLarge,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Только целые числа
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text('Пол', style: theme.textTheme.bodyLarge),
            DropdownButton<String>(
              value: _gender,
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: <String>['Мужской', 'Женский']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: theme.textTheme.bodyMedium),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}
