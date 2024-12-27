import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  ReservationsPageState createState() => ReservationsPageState();
}

class ReservationsPageState extends State<ReservationsPage> {
  late Map<DateTime, List<String>> _events;
  late Map<DateTime, List<Map<String, dynamic>>> _availability;
  late DateTime _selectedDay;
  final TextEditingController _activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = {};
    _availability = {};
    _selectedDay = DateTime.now();

    // Inițializarea disponibilității pentru câteva zile 
    _initializeAvailability();
  }

  void _initializeAvailability() {
    for (int i = -30; i <= 30; i++) {
      DateTime day = DateTime.now().add(Duration(days: i));
      _availability[day] = List.generate(
        8,
        (index) => {
          "time": "${9 + index}:00 - ${10 + index}:00",
          "isBooked": false,
        },
      );
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
      // Verifică și inițializează disponibilitatea pentru ziua selectată dacă nu există
      _availability.putIfAbsent(
        day,
        () => List.generate(
          8,
          (index) => {
            "time": "${9 + index}:00 - ${10 + index}:00",
            "isBooked": false,
          },
        ),
      );
    });
  }

  void _bookSlot(int index) {
    setState(() {
      _availability[_selectedDay]![index]["isBooked"] = true;
      String timeSlot = _availability[_selectedDay]![index]["time"];
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add("Rezervare: $timeSlot");
    });
  }

  @override
  void dispose() {
    _activityController.dispose(); // Asigură-te că eliberezi resursele
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rezervări'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              enabledDayPredicate: (day) => day.isAfter(DateTime.now().subtract(Duration(days: 1))),
              onDaySelected: _onDaySelected,
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Rezervări:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200, // Înălțime fixă pentru lista de rezervări
              child: Scrollbar(
                thumbVisibility: true, // Vizibilitate permanentă pentru scrollbar
                child: ListView.builder(
                  itemCount: _availability[_selectedDay]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final slot = _availability[_selectedDay]![index];
                    return ListTile(
                      title: Text(slot["time"]),
                      trailing: slot["isBooked"]
                          ? Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => _bookSlot(index),
                              child: Text('Rezervă'),
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}