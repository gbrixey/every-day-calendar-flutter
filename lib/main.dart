import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Every Day',
      theme: ThemeData(primaryColor: Colors.white),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final _currentYear = DateTime.now().year;
  List<int> _selectedDays;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadStoredData().then((selectedDays) {
      setState(() {
        _selectedDays = selectedDays;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_currentYear"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 12,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final day = (index ~/ 12) + 1;
          final month = (index % 12) + 1;
          return CalendarDay(
            day: day,
            month: month,
            isSelected: _selectedDays.contains(index),
            onTap: () {
              setState(() {
                if (_selectedDays.contains(index)) {
                  _selectedDays.remove(index);
                } else {
                  _selectedDays.add(index);
                }
              });
              _storeData();
            },
          );
        },
        itemCount: (12 * 31),
        padding: EdgeInsets.all(4),
        controller: _scrollController,
      )
    );
  }

  Future<List<int>> _loadStoredData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final year = preferences.getInt('year');
    if (year != _currentYear) {
      preferences.setInt('year', _currentYear);
      preferences.setString('selectedDays', '[]');
      return [];
    }
    final selectedDaysString = preferences.getString('selectedDays');
    return selectedDaysString.split(',').map((string) => int.parse(string)).toList();
  }

  _storeData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final selectedDaysString = _selectedDays.map((i) => '$i').join(',');
    preferences.setString('selectedDays', selectedDaysString);
  }
}

class CalendarDay extends StatelessWidget {
  CalendarDay({this.day, this.month, this.isSelected, this.onTap});

  final int day;
  final int month;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    if (day > daysInMonth(month, today.year)) {
      // Return an empty view
      return SizedBox();
    }
    var color;
    if (isSelected) {
      color = Color(0xFFFDCF00);
    } else if (month == today.month && day == today.day) {
      color = Color(0xFFD5F3FD);
    } else if (month < today.month || (month == today.month && day < today.day)) {
      color = Color(0xFFE6E6E6);
    } else {
      color = Colors.white;
    }
    return GestureDetector(
      onTap: onTap,
      child: PhysicalModel(
        borderRadius: BorderRadius.circular(100),
        color: color,
        child: Container (
          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(100)),
          child: Center(
            child: Text('$day'),
          ),
        ),
      ),
    );
  }
}

int daysInMonth(int month, int year) {
  switch (month) {
    case 2:
      return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    case 4:
    case 6:
    case 9:
    case 11:
      return 30;
    default:
      return 31;
  }
}
