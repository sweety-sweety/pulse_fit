import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_fit/screens/authentication/login.dart';
import 'package:pulse_fit/screens/profile/notification.dart';
import 'package:pulse_fit/screens/profile/privacy_policy.dart';
import 'package:pulse_fit/screens/profile/about_app.dart';
import '../../services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _passwordController = TextEditingController();

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удаление профиля'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Вы уверены, что хотите удалить профиль? Это действие нельзя отменить. Введите ваш пароль для подтверждения.',
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  if (_passwordController.text.isEmpty) {
                    showAppSnackBar(context, "Пожалуйста, введите пароль", isError: true);
                    return;
                  }
                  await _deleteProfile(_passwordController.text);
                },
                child: Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      print("Ошибка при удалении профиля: $e");
      showAppSnackBar(context, "Ошибка: ${e.toString()}", isError: true);
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Сменить пароль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Текущий пароль'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Новый пароль'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Подтвердите новый пароль'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword != confirmPassword) {
                showAppSnackBar(context, 'Новый пароль не совпадает', isError: true);
                return;
              }

              if (!_isPasswordValid(newPassword)) {
                showAppSnackBar(
                  context,
                  'Пароль должен содержать минимум 8 символов, заглавную и строчную буквы, и цифру',
                  isError: true,
                );
                return;
              }

              await _changePassword(currentPassword, newPassword);
              Navigator.pop(context);
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        showAppSnackBar(context, 'Пароль успешно изменён');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showAppSnackBar(context, 'Неверно введён текущий пароль', isError: true);
      } else {
        print("Ошибка при смене пароля: $e");
        showAppSnackBar(context, 'Ошибка: ${e.message}', isError: true);
      }
    } catch (e) {
      print("Ошибка при смене пароля: $e");
      showAppSnackBar(context, "Неизвестная ошибка", isError: true);
    }
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) return false;
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) return false;
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) return false;
    return true;
  }

  void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройки')),
      body: ListView(
        children: [
          _buildTile(
            'Уведомления',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            ),
          ),
          _buildThemeTile(),
          _buildTile(
            'Политика конфиденциальности',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
            ),
          ),
          _buildTile(
            'О приложении',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutAppPage()),
            ),
          ),
          ListTile(
            title: Text(
              'Сменить пароль',
              style: TextStyle(color: Colors.green[800]),
            ),
            onTap: _showChangePasswordDialog,
          ),
          ListTile(
            title: Text(
              'Удалить профиль',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _confirmDeleteProfile,
          ),
        ].expand((widget) => [widget, Divider()]).toList(),
      ),
    );
  }

  Widget _buildTile(String title, VoidCallback onTap) {
    return ListTile(title: Text(title), onTap: onTap);
  }

  Widget _buildThemeTile() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Получение текущей системной темы
        final Brightness systemBrightness = MediaQuery.of(context).platformBrightness;

        // Определяем, активна ли тёмная тема
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
            (themeProvider.themeMode == ThemeMode.system && systemBrightness == Brightness.dark);

        return ListTile(
          title: Text('Тема приложения'),
          trailing: Switch(
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        );
      },
    );
  }
}
