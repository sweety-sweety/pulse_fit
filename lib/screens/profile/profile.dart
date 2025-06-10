import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse_fit/domain/user.dart';
import 'package:pulse_fit/screens/profile/edit.dart';
import 'package:pulse_fit/screens/authentication/login.dart';
import 'package:pulse_fit/screens/profile/setting.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Загрузка профиля из Firestore
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
        });
      }
    }
  }

  // Рассчитываем индекс массы тела (ИМТ)
  double get _bmi {
    if (_userModel == null) return 0.0;
    return _userModel!.weight / (_userModel!.height * _userModel!.height);
  }

  // Открытие окна с увеличенной фотографией
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        _userModel!.gender.toLowerCase() == 'женский'
                            ? 'assets/female.png'
                            : 'assets/male.png',
                        fit: BoxFit.cover,
                        width: 250,
                        height: 250,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Изменить фотографию'),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Выбор изображения из галереи
  Future<void> _pickImage() async {
  }

  // Получаем цвет в зависимости от уровня
  Color _getLevelColor(String level) {
    switch (level) {
      case 'Начинающий':
        return Colors.green;
      case 'Средний':
        return Colors.blue;
      case 'Продвинутый':
        return Colors.orange;
      case 'Эксперт':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  // Обновление профиля с новыми данными
  void _updateProfile(Map<String, dynamic> updatedData) {
    setState(() {
      _userModel!.name = updatedData['name'];
      _userModel!.age = updatedData['age'];
      _userModel!.weight = updatedData['weight'];
      _userModel!.height = updatedData['height'];
      _userModel!.gender = updatedData['gender'];
    });
  }

  // Выход из профиля
  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    if (_userModel == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Карточка с аватаркой и именем
            Card(
              elevation: 5,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () => _showImageDialog(context),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_userModel!.gender.toLowerCase() == 'женский'
                        ? 'assets/female.png'
                        : 'assets/male.png') as ImageProvider,
                  ),
                ),
                title: Text(_userModel!.name),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(text: 'Уровень: '),
                      TextSpan(
                        text: _userModel!.level,
                        style: TextStyle(color: _getLevelColor(_userModel!.level)),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          initialName: _userModel!.name,
                          initialAge: _userModel!.age,
                          initialWeight: _userModel!.weight,
                          initialHeight: _userModel!.height,
                          initialGender: _userModel!.gender,
                          userId: _userModel!.uid,
                        ),
                      ),
                    );
                    if (updatedData != null) {
                      _updateProfile(updatedData);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Карточка персональных данных
            Card(
              elevation: 5,
              child: Column(
                children: [
                  ListTile(title: Text('Персональные данные', style: Theme.of(context).textTheme.titleLarge)),
                  Divider(),
                  ListTile(title: Text('Возраст: ${_userModel!.age}')),
                  ListTile(title: Text('Email: ${_userModel!.email}')),
                  ListTile(title: Text('Телефон: ${_userModel!.phone}')),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Карточка информации о теле
            Card(
              elevation: 5,
              child: Column(
                children: [
                  ListTile(title: Text('Информация о теле', style: Theme.of(context).textTheme.titleLarge)),
                  Divider(),
                  ListTile(title: Text('Пол: ${_userModel!.gender}')),
                  ListTile(title: Text('Рост: ${_userModel!.height.toStringAsFixed(2)} м')),
                  ListTile(title: Text('Вес: ${_userModel!.weight} кг')),
                  ListTile(title: Text('ИМТ: ${_bmi.toStringAsFixed(2)}')),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Кнопка выхода
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Выйти из профиля'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
