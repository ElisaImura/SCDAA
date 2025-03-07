import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool mostrarTodasLasTareas = false;

  @override
  Widget build(BuildContext context) {
    List<String> ciclosActivos = ["Safra 2025", "Safrinha 2024", "Soja Lote 1", "Soja Lote 2"];
    String fechaHoy = DateFormat('EEEE, d MMMM y', 'es').format(DateTime.now());

    List<Widget> proximasTareas = [
      _buildCard("Fumigación", "Lote 1 - 26 Feb 2025", Icons.alarm, Colors.orange[700]),
      _buildCard("Riego programado", "Lote 4 - 28 Feb 2025", Icons.water_drop, Colors.blue[700]),
      _buildCard("Riego programado", "Lote 4 - 28 Feb 2025", Icons.water_drop, Colors.blue[700]),
      _buildCard("Nueva tarea", "Lote 5 - 1 Mar 2025", Icons.check_circle, Colors.purple[700]),
    ];

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
                  _buildCard("Siembra de maíz", "Lote 3 - 24 Feb 2025", Icons.assignment, Colors.green[700]),
                  _buildCard("Siembra de maíz", "Lote 3 - 24 Feb 2025", Icons.assignment, Colors.green[700]),
                  _buildCard("Cosecha de soja", "Lote 2 - 22 Feb 2025", Icons.agriculture, Colors.green[700]),
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