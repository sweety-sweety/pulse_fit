import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pulse_fit/main.dart';
import 'package:pulse_fit/screens/authentication/register.dart';
import 'package:pulse_fit/services/auth.dart';
import 'package:pulse_fit/domain/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      UserModel? user = await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        setState(() {
          errorMessage = 'Неверный email или пароль.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Что-то пошло не так. Попробуйте снова.',
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите ваш email для восстановления пароля.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ссылка для восстановления отправлена на $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось отправить письмо. Проверьте email.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    // TODO: реализовать Google Sign-In через AuthService
    print('Google Sign-In');
  }

  Future<void> _signInWithFacebook() async {
    // TODO: реализовать Facebook Sign-In через AuthService
    print('Facebook Sign-In');
  }

  Future<void> _signInWithVK() async {
    // TODO: реализовать VK Sign-In
    print('VK Sign-In');
  }

  Widget _buildSocialButton({
    required String assetPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetPath,
        height: 24,
        color: isDark ? Colors.white70 : null,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Авторизация')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PulseFit',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _signIn, child: Text('Войти')),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Нет аккаунта? Зарегистрируйтесь!'),
              ),
              Divider(height: 40),
              Text("или войдите через", style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSocialButton(
                    assetPath: 'assets/google.svg',
                    label: 'Google',
                    onPressed: _signInWithGoogle,
                  ),
                  _buildSocialButton(
                    assetPath: 'assets/facebook.svg',
                    label: 'Facebook',
                    onPressed: _signInWithFacebook,
                  ),
                  _buildSocialButton(
                    assetPath: 'assets/vk.svg',
                    label: 'VK',
                    onPressed: _signInWithVK,
                  ),
                ],
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: _resetPassword,
                child: Text(
                  'Восстановить пароль',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
