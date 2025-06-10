import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  // Функция для запуска почтового клиента
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@pulsefit.com',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Не удалось запустить почтовый клиент';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: Text('Политика конфиденциальности')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваша конфиденциальность важна для нас. В этом документе объясняется, как мы собираем, используем и защищаем вашу информацию при использовании нашего приложения.',
                style: TextStyle(fontSize: 16, height: 1.6, color: textColor),
              ),
              SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, height: 1.6, color: textColor),
                  children: [
                    _boldItalic('1. Сбор данных\n'),
                    TextSpan(
                      text:
                      'Мы собираем личные данные, такие как ваше имя, email, возраст, пол, вес, рост, а также информацию о вашем использовании приложения для улучшения качества наших услуг.\n\n',
                    ),
                    _boldItalic('2. Использование данных\n'),
                    TextSpan(
                      text:
                      'Собранные данные могут быть использованы для:\n- Предоставления и улучшения функциональности приложения.\n- Отправки уведомлений, связанных с вашим аккаунтом и использованием приложения.\n- Персонализации вашего опыта.\n\n',
                    ),
                    _boldItalic('3. Защита данных\n'),
                    TextSpan(
                      text:
                      'Мы принимаем разумные меры для защиты вашей информации от несанкционированного доступа, изменения, раскрытия или уничтожения.\n\n',
                    ),
                    _boldItalic('4. Обмен данными\n'),
                    TextSpan(
                      text:
                      'Мы не продаем и не передаем ваши личные данные третьим лицам без вашего согласия, за исключением случаев, предусмотренных законом.\n\n',
                    ),
                    _boldItalic('5. Cookies\n'),
                    TextSpan(
                      text:
                      'Наше приложение может использовать cookies для улучшения работы и предоставления вам лучшего пользовательского опыта.\n\n',
                    ),
                    _boldItalic('6. Ваши права\n'),
                    TextSpan(
                      text:
                      'Вы имеете право запросить информацию о том, какие данные мы о вас собираем, а также запросить удаление или исправление этих данных. Для этого свяжитесь с нами через контактную форму в приложении.\n\n',
                    ),
                    _boldItalic('7. Изменения в политике конфиденциальности\n'),
                    TextSpan(
                      text:
                      'Мы можем обновить данную политику конфиденциальности. В случае изменений мы уведомим вас через приложение или на нашей веб-странице.\n\n',
                    ),
                    _boldItalic('Контакты:\n'),
                    TextSpan(
                      text:
                      'Если у вас есть вопросы или замечания относительно нашей политики конфиденциальности, пожалуйста, свяжитесь с нами через контактную форму в приложении или по электронной почте ',
                    ),
                    TextSpan(
                      text: 'support@pulsefit.com',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _launchEmail,
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _boldItalic(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
    );
  }
}
