import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/activity_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  bool mostrarTodasLasTareas = false;

  @override
  void initState() {
    super.initState();
    // Llamamos al método que obtiene los ciclos activos cuando la pantalla se carga
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    activityProvider.fetchCiclosActivos(); // Llama a la función que obtiene los ciclos activos
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    String fechaHoy = DateFormat('EEEE, d MMMM y', 'es').format(DateTime.now());

    // Obtener los ciclos activos desde el provider
    List<String> ciclosActivos = activityProvider.ciclosActivos
        .map<String>((ciclo) => ciclo['ci_nombre'] ?? "Sin nombre") // Obtener el nombre del ciclo
        .toList();

    List<Widget> proximasTareas = activityProvider.tareas.map((tarea) {
      return _buildCard(tarea['titulo'], tarea['fecha'], tarea['icono'], tarea['color']);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCiclosActivos(ciclosActivos, fechaHoy),
                const SizedBox(height: 20),
                _buildSeccion("Actividades Recientes", [
                  ...activityProvider.actividadesRecientes.map((actividad) {
                    return _buildCard(actividad['titulo'], actividad['fecha'], actividad['icono'], actividad['color']);
                  })
                ]),
                const SizedBox(height: 20),
                _buildSeccion("Próximas Tareas", [
                  ...proximasTareas.take(mostrarTodasLasTareas ? proximasTareas.length : 3),
                  if (proximasTareas.length > 3)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          mostrarTodasLasTareas = !mostrarTodasLasTareas;
                        });
                      },
                      child: Text(mostrarTodasLasTareas ? "Mostrar menos" : "Mostrar más"),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCiclosActivos(List<String> ciclos, String fecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fecha,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 10),
        const Text(
          "Ciclos Activos:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ciclos.map((ciclo) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(label: Text(ciclo)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Column(children: children),
      ],
    );
  }

  Widget _buildCard(String titulo, String subtitulo, IconData icono, Color? color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icono, color: color),
        title: Text(titulo),
        subtitle: Text(subtitulo),
      ),
    );
  }
}
