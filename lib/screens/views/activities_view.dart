// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mspaa/providers/activity_provider.dart';
import 'package:mspaa/screens/views/act_detail_screen.dart';

class ActivitiesView extends StatefulWidget {
  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  @override
  void initState() {
    super.initState();
    // Fetch all activities when the view is initialized
    Provider.of<ActivityProvider>(context, listen: false).fetchAllActividades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding around the body
        child: Column(
          children: [
            Expanded(
              child: _buildActivitiesList(),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildActivitiesList() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        // Obtener las actividades del provider
        List<Map<String, dynamic>> activities = activityProvider.actividades;

        // Mostrar las actividades si están vacías
        if (activities.isEmpty) {
          return const Center(child: Text('No hay actividades disponibles.'));
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            // Información de la actividad
            var activity = activities[index];
            var ciclo = activity['ciclo']['datos_ciclo'];
            var lote = activity['ciclo']['lote'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),  // Rounded corners for card
              ),
              elevation: 6,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),  // Add padding inside ListTile
                title: Text(
                  activity['act_desc'] ?? 'Descripción no disponible',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                        SizedBox(width: 6),
                        Text('Fecha: ${activity['act_fecha']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.blueGrey, size: 18),
                        SizedBox(width: 6),
                        Text('Estado: ${_getActivityStateString(activity['act_estado'])}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.green, size: 18),
                        SizedBox(width: 6),
                        Text('Responsable: ${activity['ciclo']['act_ciclos'].isNotEmpty ? activity['ciclo']['act_ciclos'][0]['uss_nombre'] : 'Desconocido'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.crop, color: Colors.orange, size: 18),
                        SizedBox(width: 6),
                        Text('Ciclo: ${ciclo['ci_nombre']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 18),
                        SizedBox(width: 6),
                        Text('Lote: ${lote != null ? lote['lot_nombre'] : 'Desconocido'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailScreen(actividad: activity),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Función para obtener el nombre del estado de la actividad
  String _getActivityStateString(int state) {
    switch (state) {
      case 1:
        return 'Pendientes';
      case 2:
        return 'En progreso';
      case 3:
        return 'Terminados';
      default:
        return 'Desconocido';
    }
  }
}
