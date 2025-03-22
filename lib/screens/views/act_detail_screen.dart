// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/providers/users_provider.dart';
import 'package:mspaa/screens/forms/edit_activity_screen.dart';
import 'package:provider/provider.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> actividad;

  const ActivityDetailScreen({
    super.key, 
    required this.actividad,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Map<String, dynamic> actividadActual;
  String responsable = "Cargando...";

  @override
  void initState() {
    super.initState();
    actividadActual = widget.actividad;
  
    if (actividadActual['ciclo'] != null && actividadActual['ciclo']['uss_id'] != null) {
      final ussId = actividadActual['ciclo']['uss_id'];
      Future.delayed(Duration.zero, () => _fetchResponsable(ussId));
    }
  }

  void _fetchResponsable(int ussId) async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    await usersProvider.fetchUserByID(ussId);

    if (mounted) {
      setState(() {
        responsable = usersProvider.userData?['uss_nombre'] ?? "Responsable no asignado";
      });
    }
  }

  void _navigateToEditActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditActivityScreen(activityData: actividadActual),
      ),
    );

    if (result == true) {
      _fetchUpdatedActivity();
    }

    if (mounted) {
      Navigator.pop(context, true); 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String titulo = actividadActual['tipo_actividad']?['tpAct_nombre'] ?? "Sin título";
    String fecha = actividadActual['act_fecha'] ?? "Fecha desconocida";
    String estado = (actividadActual['act_estado'] == 1)
        ? "Pendiente"
        : (actividadActual['act_estado'] == 2)
            ? "En curso"
            : "Finalizado";
    String descripcion = actividadActual['act_desc'] ?? "No hay detalles disponibles.";
    String ciclo = (actividadActual['ciclo'] != null && actividadActual['ciclo']['ci_id'] != null)
        ? "Ciclo: ${actividadActual['ciclo']['datos_ciclo']?['ci_nombre'] ?? 'Sin nombre'}"
        : "Sin ciclo";
    String lote = (actividadActual['ciclo'] != null && actividadActual['ciclo']['lote'] != null)
        ? actividadActual['ciclo']['lote']['lot_nombre'] ?? "Desconocido"
        : "Desconocido";
    
    List<dynamic> insumos = actividadActual['ciclo']?['insumos'] ?? [];
    int tipoActividadId = actividadActual['tpAct_id'] ?? 0;
    double? densidadSemilla = tipoActividadId == 3 
        ? actividadActual['ciclo'] != null && actividadActual['ciclo']['datos_ciclo']['sie_densidad'] != null
            ? actividadActual['ciclo']['datos_ciclo']['sie_densidad']?.toDouble() 
            : null 
        : null;
    int? cantidadPlantas = tipoActividadId == 4 
        ? actividadActual['control_germinacion'] != null && actividadActual['control_germinacion']['con_cant'] != null
            ? actividadActual['control_germinacion']['con_cant']
            : null 
        : null;
    int? vigor = tipoActividadId == 4 
        ? actividadActual['control_germinacion'] != null && actividadActual['control_germinacion']['con_vigor'] != null
            ? actividadActual['control_germinacion']['con_vigor']
            : null 
        : null;
    double? rendimiento = tipoActividadId == 6 
        ? actividadActual['ciclo'] != null && actividadActual['ciclo']['datos_ciclo'] != null && actividadActual['ciclo']['datos_ciclo']['cos_rendi'] != null
            ? actividadActual['ciclo']['datos_ciclo']['cos_rendi']?.toDouble() 
            : null 
        : null;
    double? humedad = tipoActividadId == 6 
        ? actividadActual['ciclo'] != null && actividadActual['ciclo']['datos_ciclo'] != null && actividadActual['ciclo']['datos_ciclo']['cos_hume'] != null
            ? actividadActual['ciclo']['datos_ciclo']['cos_hume']?.toDouble() 
            : null 
        : null;

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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Responsable: $responsable", style: const TextStyle(fontSize: 16)),
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
                            "Cantidad: ${insumo['ins_cant']} L",
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
              Text("Densidad de Semilla: ${densidadSemilla ?? 'No disponible'} kg/ha"),
              const SizedBox(height: 20),
            ],
            if (tipoActividadId == 4) ...[ 
              const Text(
                "Control de Germinación:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Cantidad de plantas por ha: ${cantidadPlantas ?? 'No disponible'}"),
              Text("Vigor: ${vigor ?? 'No disponible'}"),
              const SizedBox(height: 20),
            ],
            if (tipoActividadId == 6) ...[ 
              const Text(
                "Detalles de Cosecha:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Rendimiento: ${rendimiento ?? 'No disponible'} kg/ha"),
              Text("Humedad: ${humedad ?? 'No disponible'}%"),
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
                  onPressed: _showDeleteConfirmationDialog,
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

    print("Datos actualizados recibidos: $updatedActivity");

    if (updatedActivity != null) {
      setState(() {
        actividadActual = updatedActivity;
      });
    }
  }

  //Metodo para mostrar el dialogo de confirmación de eliminación
  void _showDeleteConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text("Esta acción eliminará permanentemente la actividad."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                // Llamar a la función para eliminar la actividad
                _deleteActivity();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Método de eliminación de actividad
  void _deleteActivity() async {
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    
    bool success = await activityProvider.deleteActivity(actividadActual['act_id']);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Actividad eliminada con éxito")));
      Navigator.pop(context, true); // Volver a la lista de actividades
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al eliminar la actividad")));
    }
  }

}
