import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/calendar_provider.dart';
import 'package:mspaa/screens/act_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _mostrarTodas = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);

    return Scaffold(
      body: calendarProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔹 Cargando datos
          : Column(
              children: [
                TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    DateTime fechaNormalizada = DateTime.utc(day.year, day.month, day.day);
                    return calendarProvider.events[fechaNormalizada] ?? [];
                  },
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
                      // ignore: deprecated_member_use
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
                Expanded(child: _buildEventList(calendarProvider)),
              ],
            ),
    );
  }

  Widget _buildEventList(CalendarProvider calendarProvider) {
    final eventos = calendarProvider.events[_selectedDay] ?? [];
    final mostrarEventos = _mostrarTodas ? eventos : eventos.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mostrarEventos.length,
            itemBuilder: (context, index) {
              final actividad = mostrarEventos[index];

              // ✅ Obtener el nombre del tipo de actividad
              String tipoActividad = actividad['tipo_actividad']?['tpAct_nombre'] ?? "Sin tipo";

              return ListTile(
                leading: const Icon(Icons.event, color: Colors.green),
                title: Text(tipoActividad),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  List<dynamic> insumos = actividad['ciclo']?['insumos'] ?? [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(
                        titulo: actividad['tipo_actividad']['tpAct_nombre'] ?? "Sin título",
                        fecha: actividad['act_fecha'] ?? "Fecha desconocida",
                        estado: (actividad['act_estado'] == 1)
                            ? "Pendiente"
                            : (actividad['act_estado'] == 2)
                                ? "En curso"
                                : "Completado",
                        descripcion: actividad['act_desc'] ?? "No hay detalles disponibles.",
                        ciclo: (actividad['ciclo'] != null && actividad['ciclo']['ci_id'] != null)
                            ? "Ciclo: ${actividad['ciclo']['ci_id']}"
                            : "Sin ciclo",
                        lote: (actividad['ciclo'] != null && actividad['ciclo']['lote'] != null)
                            ? actividad['ciclo']['lote']['lot_nombre']
                            : "Sin lote",
                        insumos: insumos.map((insumo) {
                          return {
                            "ins_desc": insumo["ins_desc"],
                            "ins_cant": insumo.containsKey("ins_cant") ? insumo["ins_cant"].toString() : "No especificado",
                          };
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (eventos.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _mostrarTodas = !_mostrarTodas;
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
