import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: Text('О приложении')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'PulseFit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    TextSpan(
                      text:
                      ' — это приложение для тренировок и поддержания здоровья. Мы предлагаем пользователям персонализированные тренировки, мониторинг прогресса, а также различные функции для улучшения общего состояния здоровья.\n\n',
                    ),
                    TextSpan(
                      text:
                      'Наша цель — помочь вам достичь ваших целей в фитнесе, будь то снижение веса, улучшение выносливости или поддержание физической формы. Мы обеспечиваем подробные отчеты о вашем прогрессе, план тренировок и рекомендации, которые будут адаптированы под ваши индивидуальные нужды.\n\n',
                    ),
                    TextSpan(
                      text: 'Особенности приложения:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                      '- Персонализированные тренировки и планы питания.\n- Отслеживание прогресса и статистики.\n- Уведомления и напоминания для поддержания мотивации.\n- Поддержка и советы от профессиональных тренеров.\n\n',
                    ),
                    TextSpan(
                      text: 'Компания: PulseFit Inc.\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: 'Версия приложения: 1.0.0\n\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                      'Мы надеемся, что PulseFit поможет вам на пути к более здоровому и активному образу жизни!\n\n',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
