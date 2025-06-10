import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Переключатели для настройки уведомлений
  bool _notifyOnTraining = true;
  bool _notifyOnProgress = true;
  bool _notifyOnReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Уведомления'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Сохранить настройки
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Настройки сохранены!'),
                  backgroundColor: Colors.green, // Зеленый фон
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Закругленные углы
                  ),
                  behavior:
                      SnackBarBehavior
                          .floating, // Чтобы снэкбар не перекрывал элементы
                  margin: EdgeInsets.all(16), // Отступ от краев экрана
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildTile('Настройки звука уведомлений', () {
              // Перейти к настройкам звука
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SoundSettingsPage()),
              );
            }),
            Divider(),
            _buildSwitchTile('Уведомления о тренировках', _notifyOnTraining, (
              bool value,
            ) {
              setState(() {
                _notifyOnTraining = value;
              });
            }),
            Divider(),
            _buildSwitchTile('Уведомления о прогрессе', _notifyOnProgress, (
              bool value,
            ) {
              setState(() {
                _notifyOnProgress = value;
              });
            }),
            Divider(),
            _buildSwitchTile(
              'Уведомления о достижении цели',
              _notifyOnReminders,
              (bool value) {
                setState(() {
                  _notifyOnReminders = value;
                });
              },
            ),
            Divider(),

            // Дополнительные варианты настроек уведомлений без переключателей
            _buildTile('Напоминания о тренировках', () {
              // Перейти к странице настройки уведомлений о достижении цели
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalNotificationsPage(),
                ),
              );
            }),
            Divider(),
            _buildTile('Настройки вида уведомлений', () {
              // Перейти к настройкам звука
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SoundSettingsPage()),
              );
            }),
            Divider(),
            _buildTile('Частота уведомлений', () {
              // Перейти к настройкам частоты уведомлений
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationFrequencyPage(),
                ),
              );
            }),
            Divider(),

            // Кнопка для сброса настроек
            _buildTile(
              'Сбросить настройки',
              () {
                setState(() {
                  _notifyOnTraining = true;
                  _notifyOnProgress = true;
                  _notifyOnReminders = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Настройки сброшены!'),
                    backgroundColor: Colors.green, // Зеленый фон
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Закругленные углы
                    ),
                    behavior:
                        SnackBarBehavior
                            .floating, // Чтобы снэкбар не перекрывал элементы
                    margin: EdgeInsets.all(16), // Отступ от краев экрана
                  ),
                );
              },
              titleStyle: TextStyle(
                color: Colors.red,
              ), // Красный цвет для текста
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для создания переключателей
  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  // Виджет для создания обычных элементов
  Widget _buildTile(String title, VoidCallback onTap, {TextStyle? titleStyle}) {
    return ListTile(
      title: Text(title, style: titleStyle), // Применяем стиль
      onTap: onTap,
    );
  }
}

// Пример экранов, на которые можно перейти из настроек (вы можете добавить их как новые страницы)

class GoalNotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Уведомления о достижении цели')),
      body: Center(child: Text('Настройки уведомлений о достижении цели')),
    );
  }
}

class SoundSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройки звука уведомлений')),
      body: Center(child: Text('Настройки звука уведомлений')),
    );
  }
}

class NotificationFrequencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Частота уведомлений')),
      body: Center(child: Text('Настройки частоты уведомлений')),
    );
  }
}
