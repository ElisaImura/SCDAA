import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _mostrarTodas = false;

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 2, 10): ["Siembra de soja", "Fertilización", "Inspección", "Riego", "Cosecha", "Otra tarea extra"],
    DateTime.utc(2025, 2, 15): ["Riego programado"],
    DateTime.utc(2025, 2, 20): ["Aplicación de fertilizante"],
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _events[day] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildEventList()), // Se asegura que la lista ocupe el espacio disponible
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _events[_selectedDay] ?? [];
    final mostrarEventos = _mostrarTodas ? events : events.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Evita conflictos con el ScrollView
            itemCount: mostrarEventos.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.event, color: Colors.green),
                title: Text(mostrarEventos[index]),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              );
            },
          ),
          if (events.length > 4) // Solo muestra el botón si hay más de 4 eventos
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _mostrarTodas = !_mostrarTodas;
                  });

                  // Espera a que el estado se actualice y luego hace scroll hasta el final
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                child: Text(_mostrarTodas ? "Mostrar menos" : "Mostrar más"),
              ),
            ),
        ],
      ),
    );
  }
}
