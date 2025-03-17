// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/screens/forms/edit_activity_screen.dart';
import 'package:provider/provider.dart';

class ActivityDetailScreen extends StatefulWidget {
  // Definimos el Map de actividad que recibimos como parámetro
  final Map<String, dynamic> actividad;

  // Constructor de la pantalla que recibe la actividad
  const ActivityDetailScreen({
    super.key, 
    required this.actividad, // Recibimos la actividad aquí
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Map<String, dynamic> actividadActual; // Para almacenar los datos actualizados

  @override
  void initState() {
    super.initState();
    actividadActual = widget.actividad; // Inicializamos con los datos actuales
  }

  void _navigateToEditActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(activityData: actividadActual),
      ),
    );

    if (result == true) {
      _fetchUpdatedActivity(); // Recargar los datos de la actividad
    }

    // ✅ Cuando se vuelve a CalendarScreen, también enviamos `true` si hubo cambios
    if (mounted) {
      Navigator.pop(context, true); 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 🔹 Usar `actividadActual` en lugar de `widget.actividad`
    String titulo = actividadActual['tipo_actividad']['tpAct_nombre'] ?? "Sin título";
    String fecha = actividadActual['act_fecha'] ?? "Fecha desconocida";
    String estado = (actividadActual['act_estado'] == 1)
        ? "Pendiente"
        : (actividadActual['act_estado'] == 2)
            ? "En curso"
            : "Finalizado";
    String descripcion = actividadActual['act_desc'] ?? "No hay detalles disponibles.";
    String ciclo = (actividadActual['ciclo'] != null && actividadActual['ciclo']['ci_id'] != null)
        ? "Ciclo: ${actividadActual['ciclo']['datos_ciclo']['ci_nombre']}"
        : "Sin ciclo";
    String lote = (actividadActual['ciclo'] != null && actividadActual['ciclo']['lote'] != null)
        ? actividadActual['ciclo']['lote']['lot_nombre']
        : "Sin lote";
    
    List<dynamic> insumos = actividadActual['ciclo']['insumos'] ?? [];
    int tipoActividadId = actividadActual['tpAct_id'];
    double? densidadSemilla = tipoActividadId == 3 ? actividadActual['ciclo']['sie_densidad'] : null;
    int? cantidadPlantas = tipoActividadId == 4 ? actividadActual['control_germinacion']['con_cant'] : null;
    int? vigor = tipoActividadId == 4 ? actividadActual['control_germinacion']['con_vigor'] : null;
    double? rendimiento = tipoActividadId == 6 ? actividadActual['ciclo']['datos_ciclo']['cos_rendi']?.toDouble() : null;
    double? humedad = tipoActividadId == 6 ? actividadActual['ciclo']['datos_ciclo']['cos_hume']?.toDouble() : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de la Actividad"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(fecha, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Estado: $estado", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.repeat, color: Colors.grey),
                const SizedBox(width: 8),
                Text(ciclo, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Lote: $lote", style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Descripción:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if ([1, 2, 3, 5].contains(tipoActividadId)) ...[
              const Text(
                "Insumos:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              insumos.isNotEmpty
                  ? Column(
                      children: insumos.toSet().toList().map((insumo) {
                        return ListTile(
                          leading: const Icon(Icons.inventory, color: Colors.blue),
                          title: Text(insumo['ins_desc']),
                          subtitle: Text(
                            "Cantidad: ${insumo['ins_cant']} L", // Unidades en litros
                          ),
                        );
                      }).toList(),
                    )
                  : const Text("No hay insumos registrados."),
              const SizedBox(height: 20),
            ],
            if (tipoActividadId == 3) ...[
              const Text(
                "Densidad de Semilla:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Densidad de Semilla: $densidadSemilla kg/ha"), // Mostrar la densidad de semilla
              const SizedBox(height: 20),
            ],
            if (tipoActividadId == 4) ...[
              const Text(
                "Control de Germinación:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Cantidad de plantas por ha: $cantidadPlantas"),
              Text("Vigor: $vigor"),
              const SizedBox(height: 20),
            ],
            if (tipoActividadId == 6) ...[
              const Text(
                "Detalles de Cosecha:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Rendimiento: $rendimiento kg/ha"),
              Text("Humedad: $humedad%"),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToEditActivity,
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                  label: const Text("Eliminar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fetchUpdatedActivity() async {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    final updatedActivity = await activityProvider.fetchActivityById(actividadActual['act_id']);

    print("Datos actualizados recibidos: $updatedActivity"); // ✅ Verifica qué devuelve la API

    if (updatedActivity != null) {
      setState(() {
        actividadActual = updatedActivity; // ✅ Actualizar los datos en la UI
      });
    }
  }
}
