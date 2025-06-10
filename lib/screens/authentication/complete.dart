import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pulse_fit/domain/user.dart';
import 'package:pulse_fit/services/auth.dart';
import 'package:pulse_fit/main.dart';

class CompleteProfilePage extends StatefulWidget {
  final String userId;

  CompleteProfilePage({required this.userId});

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final AuthService _authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // Контроллер для телефона
  String gender = 'Мужской';
  String errorMessage = '';
  bool isLoading = false;

  String phoneNumber = ''; // Хранение форматированного номера

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Преобразуем рост из см в метры
      double heightInCm = double.tryParse(heightController.text.trim()) ?? 0.0;
      double heightInM = heightInCm / 100.0;

      // Преобразуем номер телефона, если необходимо
      String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''); // Убираем все символы, кроме цифр

      UserModel user = UserModel(
        uid: widget.userId,
        email: _authService.getCurrentUserEmail(),
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 0,
        weight: double.tryParse(weightController.text.trim()) ?? 0.0,
        height: heightInM,
        gender: gender,
        phone: formattedPhone,
      );

      await _authService.updateUserProfile(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка сохранения данных: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заполните профиль')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Аватар, который зависит от пола
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  gender.toLowerCase() == 'женский'
                      ? 'assets/female.png'
                      : 'assets/male.png',
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              // Поле ввода имени
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(), // Прямоугольная форма
                ),
              ),
              SizedBox(height: 10),
              // Поле ввода возраста
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Возраст',
                  border: OutlineInputBorder(), // Прямоугольная форма
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Поле ввода веса
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Вес (кг)',
                  border: OutlineInputBorder(), // Прямоугольная форма
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Поле ввода роста
              TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Рост (см)',
                  border: OutlineInputBorder(), // Прямоугольная форма
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Поле для ввода телефона с форматированием
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    phoneNumber = number.phoneNumber ?? '';
                  });
                },
                initialValue: PhoneNumber(isoCode: 'RU'),
                textFieldController: phoneController,
                inputDecoration: InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false, // Позволяет ввести номер в любом формате
              ),
              SizedBox(height: 10),
              // Поле выбора пола
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Мужской', 'Женский'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      gender = newValue;
                    });
                  }
                },
                decoration: InputDecoration(labelText: 'Пол'),
              ),
              SizedBox(height: 10),
              // Сообщение об ошибке
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 20),
              // Кнопка сохранения
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Сохранить профиль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
