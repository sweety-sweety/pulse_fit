import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'Неделя';
  DateTime _currentDate = DateTime.now();

  List<FlSpot> _weightSpots = [];
  List<FlSpot> _calorieSpots = [];
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _loadData();
  }

  Future<void> _loadData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      List<dynamic> weightHistory = userDoc.data()?['weightHistory'] ?? [];
      List<dynamic> completedWorkouts = userDoc.data()?['completedWorkouts'] ?? [];

      Map<DateTime, double> weightDataMap = {};
      print(weightHistory);
      for (var entry in weightHistory) {
        if (entry['date'] == null || entry['weight'] == null) continue;

        DateTime date;
        var dateValue = entry['date'];
        if (dateValue is String) {
          date = DateTime.parse(dateValue).toLocal();
        }
        else if (dateValue is Timestamp) {
          date = dateValue.toDate();
        }
        else {
          continue;
        }

        weightDataMap[DateTime(date.year, date.month, date.day)] = (entry['weight'] ?? 0).toDouble();
      }


      Map<DateTime, int> calorieDataMap = {};
      Map<DateTime, List<Event>> workoutEvents = {};
      for (var workout in completedWorkouts) {
        String title = workout['title'] ?? 'Без названия';
        int calories = workout['caloriesBurned'] ?? 0;
        List<dynamic> dates = workout['dates'] ?? [];

        for (var d in dates) {
          DateTime date = DateTime.parse(d).toLocal();
          DateTime key = DateTime(date.year, date.month, date.day);

          calorieDataMap[key] = (calorieDataMap[key] ?? 0) + calories;

          workoutEvents.putIfAbsent(key, () => []);
          workoutEvents[key]?.add(Event(title, calories));
        }
      }

      setState(() {
        _events = workoutEvents;
        _updateGraphData(_selectedPeriod, _currentDate, weightDataMap, calorieDataMap);
      });
    }
  }

  void _updateGraphData(String period, DateTime baseDate, Map<DateTime, double> weightMap, Map<DateTime, int> calorieMap) {
    List<FlSpot> weightSpots = [];
    print('TIIIIIMe');
    print(weightSpots);
    List<FlSpot> calorieSpots = [];

    List<DateTime> range = [];

    if (period == 'Неделя') {
      DateTime start = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      for (int i = 0; i < 7; i++) {
        range.add(start.add(Duration(days: i)));
      }
    } else {
      int daysInMonth = DateUtils.getDaysInMonth(baseDate.year, baseDate.month);
      for (int i = 0; i < daysInMonth; i++) {
        range.add(DateTime(baseDate.year, baseDate.month, i + 1));
      }
    }

    double previousWeight = 0;
    List<DateTime> sortedWeightDates = weightMap.keys.toList()..sort();
    DateTime? firstDate = sortedWeightDates.isNotEmpty ? sortedWeightDates.first : null;
    DateTime? lastDate = sortedWeightDates.isNotEmpty ? sortedWeightDates.last : null;

    for (int i = 0; i < range.length; i++) {
      DateTime day = range[i];

      if (weightMap.containsKey(day)) {
        previousWeight = weightMap[day]!;
      } else {
        if (firstDate != null && day.isBefore(firstDate)) {
          previousWeight = weightMap[firstDate]!;
        } else if (lastDate != null && day.isAfter(lastDate)) {
          previousWeight = weightMap[lastDate]!;
        }
      }

      weightSpots.add(FlSpot(i.toDouble(), previousWeight));
      calorieSpots.add(FlSpot(i.toDouble(), calorieMap[day]?.toDouble() ?? 0));
    }


    setState(() {
      _weightSpots = weightSpots;
      _calorieSpots = calorieSpots;
    });
  }

  void _changeDate(int offset) async {
    DateTime newDate;
    if (_selectedPeriod == 'Неделя') {
      newDate = _currentDate.add(Duration(days: 7 * offset));
    } else {
      newDate = DateTime(_currentDate.year, _currentDate.month + offset, 1);
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    List<dynamic> weightHistory = userDoc.data()?['weightHistory'] ?? [];
    List<dynamic> completedWorkouts = userDoc.data()?['completedWorkouts'] ?? [];

    Map<DateTime, double> weightMap = {};
    for (var entry in weightHistory) {
      DateTime date = DateTime.parse(entry['date']).toLocal();
      weightMap[DateTime(date.year, date.month, date.day)] = entry['weight'].toDouble();
    }

    Map<DateTime, int> calorieMap = {};
    for (var workout in completedWorkouts) {
      int calories = workout['caloriesBurned'] ?? 0;
      List<dynamic> dates = workout['dates'] ?? [];
      for (var d in dates) {
        DateTime date = DateTime.parse(d).toLocal();
        DateTime key = DateTime(date.year, date.month, date.day);
        calorieMap[key] = (calorieMap[key] ?? 0) + calories;
      }
    }

    if (!mounted) return;

    setState(() {
      _currentDate = newDate;
      _updateGraphData(_selectedPeriod, newDate, weightMap, calorieMap);
    });
  }

  LineChart _buildLineChart(List<FlSpot> data, String title, Color color) {
    final isWeight = title.contains('Вес');

    double minY = 0;
    double maxY = 1000;
    double interval = isWeight ? 1.0 : 50.0;

    if (data.isNotEmpty) {
      final yValues = data.map((e) => e.y).toList();
      minY = isWeight ? yValues.reduce((a, b) => a < b ? a : b) - 1: 0;
      maxY = isWeight ? yValues.reduce((a, b) => a > b ? a : b) + 1 : yValues.reduce((a, b) => a > b ? a : b);
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= data.length) return SizedBox.shrink();

                DateTime day;
                if (_selectedPeriod == 'Неделя') {
                  DateTime start = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
                  day = start.add(Duration(days: index));
                  return Text(['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][day.weekday - 1], style: TextStyle(fontSize: 12));
                } else {
                  day = DateTime(_currentDate.year, _currentDate.month, index + 1);
                  return Text('${day.day}', style: TextStyle(fontSize: 12));
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: TextStyle(fontSize: 12));
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        gridData: FlGridData(show: true, horizontalInterval: interval),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: color,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, List<FlSpot> data, Color color) {

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => _changeDate(-1), icon: Icon(Icons.arrow_back)),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _changeDate(1), icon: Icon(Icons.arrow_forward)),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: _buildLineChart(data, title, color),
        ),
      ],
    );
  }

  // Функция преобразования номера месяца в его текстовое представление
  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Функция для показа всплывающего окна с названиями тренировок
  void _showWorkoutDetails(BuildContext context, DateTime date) {
    DateTime dayOnly = DateTime(date.year, date.month, date.day);
    List<Event> eventsForDay = _events[dayOnly] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                '${dayOnly.day} ${_getMonthName(dayOnly.month)} ${dayOnly.year}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
            ],
          ),
          content: eventsForDay.isNotEmpty
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: eventsForDay.map((event) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${event.title} (${event.caloriesBurned} ккал)',
                style: TextStyle(fontSize: 16),
              ),
            )).toList(),
          )
              : Text('В этот день тренировок не было'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Статистика')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = 'Неделя';
                      _loadData();
                    });
                  },
                  child: Text('Неделя', style: TextStyle(color: _selectedPeriod == 'Неделя' ? Colors.blue : Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = 'Месяц';
                      _loadData();
                    });
                  },
                  child: Text('Месяц', style: TextStyle(color: _selectedPeriod == 'Месяц' ? Colors.blue : Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildChartSection('Вес (кг)', _weightSpots, Colors.green),
            SizedBox(height: 20),
            _buildChartSection('Калории (ккал)', _calorieSpots, Colors.red),
            SizedBox(height: 30),
            Text('Календарь тренировок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _currentDate,
              eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selectedDay, focusedDay) => _showWorkoutDetails(context, selectedDay),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final int caloriesBurned;

  Event(this.title, this.caloriesBurned);
}
