import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/cycle_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/activity_provider.dart';

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
    _loadData();
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    cycleProvider.fetchCiclosActivos();
    activityProvider.fetchActividadesRecientes();
    activityProvider.fetchTareas();
  }

  void _loadData() async {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    await cycleProvider.fetchCiclosActivos();
    await activityProvider.fetchActividadesRecientes();
    await activityProvider.fetchTareas();
    if (mounted) {
      setState(() {});
    }
  }

  String _getEstadoActividad(int estado) {
    switch (estado) {
      case 1:
        return "Pendiente";
      case 2:
        return "En Progreso";
      case 3:
        return "Finalizado";
      default:
        return "Desconocido";
    }
  }

  Color _getColorForEstado(int estado) {
    switch (estado) {
      case 1:
        return Colors.orange; // Pendiente
      case 2:
        return Colors.blue; // En Progreso
      case 3:
        return Colors.green; // Finalizado
      default:
        return Colors.grey; // Desconocido
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);
    String fechaHoy = DateFormat('EEEE, d MMMM y', 'es').format(DateTime.now());

    // Obtener las actividades recientes desde el provider
    List<Widget> actividadesRecientes = activityProvider.actividadesRecientes
        .map((actividad) {
          String tipoActividad = actividad['tipo_actividad']['tpAct_nombre'] ?? "Sin nombre";
          String loteNombre = actividad['ciclo']['lote'] != null
              ? actividad['ciclo']['lote']['lot_nombre']
              : "Desconocido";
          String fecha = actividad['act_fecha'] ?? "Fecha desconocida";
          String usuarioAsignado = actividad['ciclo']['act_ciclos']?.firstWhere(
            (actCiclo) => actCiclo['uss_nombre'] != null,
            orElse: () => {'uss_nombre': "Usuario desconocido"},
          )['uss_nombre'];
          int estadoInt = actividad['act_estado'] ?? 0;
          String estado = _getEstadoActividad(estadoInt);
          Color colorEstado = _getColorForEstado(estadoInt);

          Color color = _getColorForActivity(tipoActividad);
          IconData icono = _getIconForActivity(tipoActividad);

          return _buildCard(tipoActividad, loteNombre, fecha, usuarioAsignado, icono, color, estado: estado, colorEstado: colorEstado);
        })
        .toList();

    // Obtener las próximas tareas desde el provider
    List<Widget> proximasTareas = activityProvider.tareas
        .map((tarea) {
          String tipoActividad = tarea['tipo_actividad']['tpAct_nombre'] ?? "Sin nombre";
          String loteNombre = tarea['ciclo']['lote']['lot_nombre'] ?? "Lote desconocido";
          String fecha = tarea['act_fecha'] ?? "Fecha desconocida";
          String usuarioAsignado = tarea['ciclo']['act_ciclos']?.firstWhere(
            (actCiclo) => actCiclo['uss_nombre'] != null,
            orElse: () => {'uss_nombre': "Usuario desconocido"},
          )['uss_nombre'];
          int estadoInt = tarea['act_estado'] ?? 0;
          String estado = _getEstadoActividad(estadoInt);
          Color colorEstado = _getColorForEstado(estadoInt);

          Color color = _getColorForActivity(tipoActividad);
          IconData icono = _getIconForActivity(tipoActividad);

          return _buildCard(tipoActividad, loteNombre, fecha, usuarioAsignado, icono, color, estado: estado, colorEstado: colorEstado);
        })
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCiclosActivos(cycleProvider.ciclosActivos, fechaHoy),
                const SizedBox(height: 20),
                _buildSeccion("Actividades Recientes", actividadesRecientes.isEmpty
                    ? [const SizedBox(height: 10), Text("No hay actividades para mostrar.", style: TextStyle(fontSize: 16, color: Colors.grey))]
                    : actividadesRecientes),
                const SizedBox(height: 20),
                _buildSeccion("Próximas Tareas", proximasTareas.isEmpty
                    ? [const SizedBox(height: 10), Text("No hay tareas para mostrar.", style: TextStyle(fontSize: 16, color: Colors.grey))]
                    : [
                        ...proximasTareas.take(mostrarTodasLasTareas ? proximasTareas.length : 3),
                        if (proximasTareas.length > 3)
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  mostrarTodasLasTareas = !mostrarTodasLasTareas;
                                });
                              }
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

  IconData _getIconForActivity(String tipoActividad) {
    switch (tipoActividad) {
      case 'Desecación':
        return Icons.cloud_done;
      case 'Tratamiento de Semilla':
        return Icons.spa;
      case 'Siembra':
        return Icons.grain;
      case 'Control de Germinación':
        return Icons.local_florist;
      case 'Fumigación':
        return Icons.local_fire_department;
      case 'Cosecha':
        return Icons.agriculture;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForActivity(String tipoActividad) {
    switch (tipoActividad) {
      case 'Desecación':
        return Colors.blue;
      case 'Tratamiento de Semilla':
        return Colors.green;
      case 'Siembra':
        return Colors.orange;
      case 'Control de Germinación':
        return Colors.purple;
      case 'Fumigación':
        return Colors.red;
      case 'Cosecha':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCiclosActivos(List<dynamic> ciclos, String fecha) {
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
            children: ciclos.isEmpty
                ? [Text("No hay ciclos activos disponibles.")]
                : ciclos.map((ciclo) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(label: Text(ciclo['ci_nombre'] ?? "Ciclo desconocido")),
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

  Widget _buildCard(
      String titulo, String subtitulo, String fecha, String usuario, IconData icono, Color color, {String estado = "Desconocido", Color colorEstado = Colors.grey}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          ListTile(
            leading: Icon(icono, color: color),
            title: Text(titulo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lote: $subtitulo"),
                Text("Fecha: $fecha"),
                Text("Responsable: $usuario"),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Chip(
              label: Text(estado, style: TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: colorEstado,
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            ),
          ),
        ],
      ),
    );
  }
}
