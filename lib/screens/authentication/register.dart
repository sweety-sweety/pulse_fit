import 'package:flutter/material.dart';
import 'package:pulse_fit/screens/authentication/complete.dart';
import 'package:pulse_fit/services/auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isLoading = false;

  // Функция для проверки пароля
  bool _isPasswordValid(String password) {
    // Проверка на минимум 8 символов
    if (password.length < 8) {
      return false;
    }
    // Проверка на наличие хотя бы одной строчной буквы
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return false;
    }
    // Проверка на наличие хотя бы одной заглавной буквы
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return false;
    }
    // Проверка на наличие хотя бы одной цифры
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return false;
    }
    return true;
  }

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      // Если пароли не совпадают
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пароли не совпадают!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
        ),
      );
      return;
    }

    if (! _isPasswordValid(passwordController.text)) {
      // Если пароль не соответствует требованиям
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пароль должен быть не менее 8 символов, включать строчные и заглавные латинские буквы, а также цифры.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await _authService.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfilePage(userId: user.uid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка регистрации. Попробуйте снова.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 6,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = 'Ошибка регистрации. Попробуйте снова.';
      // Проверка ошибки на существующий email
      if (e.toString().contains('email address is already in use')) {
        errorMessage = 'Пользователь с таким адресом электронной почты уже зарегистрирован.';
      }

      // Показываем SnackBar с ошибкой
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Название приложения PulseFit
                Text(
                  'PulseFit',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 40),
                // Поле ввода email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(), // Прямоугольная форма
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                // Поле ввода пароля
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(), // Прямоугольная форма
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                // Поле ввода повторного пароля
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Повторите пароль',
                    border: OutlineInputBorder(), // Прямоугольная форма
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                // Кнопка регистрации
                isLoading
                    ? Center(
                  child: CircularProgressIndicator(),
                ) // Индикатор загрузки
                    : ElevatedButton(
                  onPressed: _register,
                  child: Text('Зарегистрироваться'),
                ),
                // Ссылка на страницу входа
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
